import ballerina.net.http;
import ballerina.lang.messages;
import wsService;

@ws:configuration {
    basepath: "/ws/connect/remoteServer",
    port: 9090,
    subProtocols: ["xml", "json"]
}

map clientConnectionMap = {};

service<ws> ProxyServerSample {

    resource onOpen (ws:Connection conn) {
        ws:ClientConnector clientConn;

        if (conn.getSubProtocol() == "xml") {
            clientConn = create ClientConnector("ws://localhost:15500/remote-service",
                                                "CallBackService");
            clientConn.setSubProtocol("xml");
        } else {
            clientConn = create ClientConnector("ws://localhost:15500/remote-service",
                                                "CallBackService");
            clientConn.setSubProtocol("json")
        }

        clientConn.setParentConnection(conn);
        var clientConn, err = clientConn.connect();

        if (err != null) {
            conn.close(1011, "Internal error");
        }

        if (clientConn != null && err == null) {
            // Connecting to client is successful
            clientConnectionMap[conn.id] = (ws:Connection)clientConn;
        }
    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        ws:Connection clientConn = clientConnectionMap[conn.id];
        clientConn.pushText(frame.getText());
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        ws:Connection clientConn = clientConnectionMap[conn.id];
        clientConn.close(1001, "Client is going away");
    }
}

@ws:ClientService {}
service<ws> CallBackService  {

    resource onOpen(ws:Connection conn) {
        if (conn.hasParentConnection()) {
            system:println("Client connection successful");
        } else {
            conn.close(1011, "Internal error");
        }
    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        ws:Connection parentConn = conn.getParentConnetion();
        parentConn.pushText(frame.getText());
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        ws:Connection parentConn = conn.getParentConnetion();
        maps:remove(clientConnectionMap, parentConn.id);
        parentConn.close(1011, "Internal error");
    }
}
