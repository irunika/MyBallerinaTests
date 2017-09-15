package chatapp;

import ballerina.lang.system;
import ballerina.net.ws;

@ws:configuration {
    basePath: "/ws/hello",
    subProtocols: ["xml", "json"],
    idleTimeOutSeconds: 60
}
service<ws> ChatApp {

    ws:Connection[] conns = [];

    resource onHandshake(ws:HandshakeConnection con) {
        system:println("On pre connection");
    }

    resource onOpen(ws:Connection conn) {
        system:println("New connection with sub protocol: " + ws:getNegotiatedSubProtocol(conn));
        conns[conns.length] = conn;
    }

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        system:println(frame.text);
        broadcast(conns, frame.text);

    }

    resource onIdleTimeout(ws:Connection conn) {
        system:println("Idle timeout: " + ws:getID(conn));
        ws:pushText(conn, "closing connection");
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        system:println("Client left: " + ws:getID(conn));
        broadcast(conns, "user left");
        system:println("Close code: " + frame.statusCode);
        system:println("Close reason: " + frame.reason);
    }
}

function broadcast(ws:Connection[] conns, string text) {
    int i = 0;
    int len = conns.length;
    while (i < len) {
        ws:pushText(conns[i], text);
        i = i + 1;
    }
}
