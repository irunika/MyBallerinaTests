package proxyserver;

import ballerina.net.ws;
import ballerina.lang.maps;
import ballerina.lang.errors;
import ballerina.lang.system;

@ws:configuration {
    basePath: "/ws/proxy",
    subProtocols: ["xml", "json"],
    idleTimeOutSeconds: 10,
    wssPort:5003,
    keyStoreFile:"${ballerina.home}/bre/security/wso2carbon.jks",
    keyStorePass:"wso2carbon",
    certPass:"wso2carbon"
}
service<ws> SimpleProxyServer {

    map clientConnMap = {};

    resource onHandshake(ws:HandshakeConnection con) {
        ws:ClientConnector c = create ws:ClientConnector("ws://localhost:15500/websocket", "ClientService");
        ws:ClientConnectorConfig clientConnectorConfig = {parentConnectionID:con.connectionID};
        ws:Connection clientConn;
        try {
            clientConn = c.connect(clientConnectorConfig);
        } catch (errors:Error err) {
            system:println("Error occcurred : " + err.msg);
            ws:cancelHandshake(con, 1001, "Cannot connect to remote server");
        }
        clientConnMap[con.connectionID] = clientConn;
    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        var x, e = (ws:Connection) clientConnMap[ws:getID(conn)];
        if (x != null) {
            ws:pushText(x, frame.text);
        }
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        var x, e = (ws:Connection) clientConnMap[ws:getID(conn)];
        if (x != null) {
            ws:closeConnection(x, 1001, "Client closing connection");
        }
        maps:remove(clientConnMap, ws:getID(conn));
    }
}
