import ballerina.net.ws;

@ws:configuration {
    basePath: "/chat/{chat-room}/{user-name}",
    port: 9090,
    subProtocols: ["chat-room"]
}
service<ws> ChatApp {

    map chatRooms = {};

    resource onOpen(ws:Connection conn) {
        string chatRoomName = conn.pathParams["chat-room"];
        if (chatRooms[chatRoomName] == null) {
            map connections = {conn.id: conn};
            chatRooms[chatRoomName] = connections;
            conn.pushText("You created chat room " + chatRoomName);
        } else {
            map connections = chatRooms[chatRoomName];
            broadcastText(connections,
                          conn.pathParams["user-name"] +
                                        "connected to the chat");
            connections[conn.id] = conn;
            conn.pushText("You connected to chat room " + chatRoomName);
        }
    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        string chatRoomName = chatRooms[conn.pathParams["chat-room"]];
        string userName = chatRooms[conn.pathParams["user-name"]];
        string msg = userName + ": " + frame.getText();
        broadcastText(chatRooms[chatRoomName], msg);
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        string chatRoomName = chatRooms[conn.pathParams["chat-room"]];
        string userName = chatRooms[conn.pathParams["user-name"]];
        map connections = chatRooms[chatRoomName];
        maps:remove(connections, conn.id);

        string msg = userName + " left the chat";
        broadcastText(connections, msg);
    }
}

function broadcastText (map connections, string msg)  {
    connections, msg -> broadcastWorker;

    worker broadcastWorker {
        map connections;
        string msg;
        connections, msg <- default;

        int i = 0;
        while (i < maps:length(connections)) {
            ws:Connection conn = connections[connKeys[i]];
            conn.pushText(msg);
            i = i + 1;
        }

    }
}

function broadcastText (map connections, string msg)  {
    int i = 0;
    int mapLength = maps:length(connections);
    string[] connKeys = maps:keys(connections);
    while (i < mapLength) {
        ws:Connection conn = connections[connKeys[i]];
        conn.pushText(msg);
        i = i + 1;
    }
}

