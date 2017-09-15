package simpleserver;

import ballerina.lang.system;
import ballerina.lang.maps;
import ballerina.net.ws;

@ws:configuration {
    basePath: "/ws/simple",
    subProtocols: ["xml", "json"],
    idleTimeOutSeconds: 10
}
service<ws> SimpleServer {

    resource onHandshake(ws:HandshakeConnection conn) {
        system:println("");
        system:println("Connection ID: " + conn.connectionID);
        system:println("Is connection secure: " + conn.isSecure);

        system:println("pre upgrade headers -> ");
        printHeaders(conn.upgradeHeaders);
    }

    resource onOpen(ws:Connection conn) {
        system:println("");
        system:println("New client connected: " + ws:getID(conn));
        system:println("Sub protocol: " + ws:getNegotiatedSubProtocol(conn));
        system:println("Is connection open: " + ws:isOpen(conn));
        system:println("Is connection secured: " + ws:isSecure(conn));
        system:println("Connection header: " + ws:getUpgradeHeader(conn, "Connection"));
        system:println("Upgrade headers -> " );
        printHeaders(ws:getUpgradeHeaders(conn));
    }

    resource onClose(ws:Connection conn, ws:CloseFrame closeFrame) {
        system:println("");
        system:println("Client left with status code " + closeFrame.statusCode + " because " + closeFrame.reason);
    }
}

function printHeaders(map headers) {
    string [] headerKeys = maps:keys(headers);
    int len = headerKeys.length;
    int i = 0;
    while (i < len) {
        var key, e = (string) headerKeys[i];
        var value, e = (string) headers[key];
        system:println(key + ": " + value);
        i = i + 1;
    }
}