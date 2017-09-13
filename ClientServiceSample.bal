
@ws:configuration {
    basepath: "/ws/connect/remoteServer",
    port: 9090,
}
service<ws> ClientServiceSample {

    map clientConnectionMap = {};

    resource onOpen (ws:Connection conn) {
        ws:ClientConnector clientConn =
        create ClientConnector("ws://localhost:15500/cliet-responder", "CallBackService");
        clientConn.setSubProtocol("echo");
        var clientConn, err = clientConn.connect();

        if (err != null) {
            system:println("Error occurred during connecting to the remote server");
            conn.close(1011, "Internal error occurred");
        }

        if (clientConn != null && err == null) {
            system:println("Connected to remote server successfully");
            clientConnectionMap[conn.id] = (ws:Connection)clientConn;
        }
    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        ws:Connection clientConn = clientConnectionMap[conn.id];

        if (clientConn.isOpen) {
            clientConn.pushText(frame.getText());
        } else {
            maps:remove(clientConnectionMap, conn.id);
            conn.close(1011, "Internal error occurred");
        }
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        ws:Connection clientConn = clientConnectionMap[conn.id];
        clientConn.close(1001, "Client is going away");
    }
}

@ws:ClientService {}
service<ws> CallBackService  {

    resource onOpen(ws:Connection conn) {
        system:println("Client connection successful");
    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        system:println("Remote server says: " + frame.getText());
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        system:println("Client connection closed");
        system:println("Status code: " + frame.statusCode);
        system:println("Close reason: " + frame.reason);
    }
}