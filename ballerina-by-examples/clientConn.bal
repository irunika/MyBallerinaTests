import ballerina.net.ws;
import ballerina.lang.system;

@ws:configuration {
    basePath:"/basic/ws",
    port:9090,
    idleTimeoutInSeconds:10
}

service<ws> myService {

    ws:Connection clientConn;

    resource onHandshake(ws:HandshakeConnection conn) {
        ws:ClientConnector clientConnector = create ws:ClientConnector("wss://echo.websocket.org", "ClientService");
        ws:ClientConnectorConfig config = {parentConnectionID:conn.connectionID};
        clientConn = clientConnector.connect(config);
    }

    resource onOpen(ws:Connection conn) {
        system:println("New client connected");
        ws:pushText(conn, "Client connection successful");

    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        system:println("Text message: " + frame.text);
        ws:pushText(clientConn, frame.text);
    }
}

@ws:clientService {}
service<ws> ClientService {

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        system:println("Received text from remote server: " + frame.text);
        ws:pushText(ws:getParentConnection(conn), "Remote server: " + frame.text);
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        ws:closeConnection(ws:getParentConnection(conn), frame.statusCode, frame.reason);
    }

}