package proxyserver;

import ballerina.net.ws;
import ballerina.lang.maps;

@ws:configuration {
    basePath: "/ws/proxy",
    subProtocols: ["xml", "json"],
    idleTimeOutSeconds: 10
}
service<ws> SimpleProxyServer {

    map<ws:Connection> clientConnsMap = {};

    resource onHandshake(ws:HandshakeConnection con) {
        ws:ClientConnector c = create ws:ClientConnector("ws://localhost:15500/websocket", "ClientService");
        ws:ClientConnectorConfig clientConnectorConfig = {parentConnectionID:con.connectionID};
        ws:Connection clientConn = c.connect(clientConnectorConfig);
        clientConnsMap[con.connectionID] = clientConn;
    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        var x, e = (ws:Connection) clientConnsMap[ws:getID(conn)];
        if (x != null) {
            ws:pushText(x , frame.text);
        }
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        var x, e = (ws:Connection) clientConnsMap[ws:getID(conn)];
        if (x != null) {
            ws:closeConnection(x, 1001, "Client closing connection");
        }
        maps:remove(clientConnsMap, ws:getID(conn));
    }
}
