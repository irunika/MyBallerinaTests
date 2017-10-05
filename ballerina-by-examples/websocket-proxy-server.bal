import ballerina.net.ws;
import ballerina.lang.maps;

@ws:configuration {
    basePath: "/proxy/ws",
    port:9090
}
service<ws> SimpleProxyServer {

    map clientConnMap = {};

    resource onHandshake(ws:HandshakeConnection con) {
        ws:ClientConnector c = create ws:ClientConnector("wss://echo.websocket.org", "ClientService");
        ws:ClientConnectorConfig clientConnectorConfig = {parentConnectionID:con.connectionID};
        try {
            ws:Connection clientConn = c.connect(clientConnectorConfig);
            clientConnMap[con.connectionID] = clientConn;
        } catch (errors:Error err) {
            ws:cancelHandshake(con, 1001, "Cannot connect to remote server");
        }
    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        ws:Connection clientCon;
        clientCon, _ = (ws:Connection) clientConnMap[ws:getID(conn)];
        ws:pushText(clientCon, frame.text);
    }

    resource onBinaryMessage(ws:Connection conn, ws:BinaryFrame frame) {
        ws:Connection clientConn;
        clientConn, _ = (ws:Connection) clientConnMap[ws:getID(conn)];
        ws:pushBinary(clientConn, frame.data);
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        ws:Connection clientConn;
        clientConn, _ = (ws:Connection) clientConnMap[ws:getID(conn)];
        ws:closeConnection(clientConn, 1001, "Client closing connection");
        maps:remove(clientConnMap, ws:getID(conn));
    }
}


@ws:clientService {}
service<ws> ClientService {

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        ws:Connection parentConn = ws:getParentConnection(conn);
        ws:pushText(parentConn, frame.text);
    }

    resource onBinaryMessage(ws:Connection conn, ws:BinaryFrame frame) {
        ws:Connection parentConn = ws:getParentConnection(conn);
        ws:pushBinary(parentConn, frame.data);
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        ws:Connection parentConn = ws:getParentConnection(conn);
        ws:closeConnection(parentConn, 1001, "Server closing connection");
    }

}
