import ballerina.lang.system;
import ballerina.lang.messages;
import ballerina.net.http;
import ballerina.net.ws;
import ballerina.doc;

@doc:Description {value:"WebSocket endpoint is defined as a composition of  BasePath + WebSocketUpgradePath."}
@http:configuration {
    basePath:"/endpoint",
    websocket :{
               upgradePath:"/foo",
               websocketService: "MyWSS"
    }
}
service<http> WebService {
    @http:resourceConfig {
        path:"/do",
        verbs:[http:verbs.GET ]
    }
    resource doSomething ( http:request req, http:response resp) {

    }
}

@ws:configuration {
    basePath:"/ws",
    idleTimeOutMillis:3000,
    subProtocols:["xml", "json", "chat"]
}
service<ws> MyWSS {
    resource onOpen(ws:Connection s) {
        system:println("New client connected to the server");
    }

    resource onTextMessage(ws:Connection con, ws:TextFrame frame) {
        system:println("client: " + messages:getStringPayload(m));
        con.pushText("you said " + frame.getText());
    }

    resource onBinaryMessage(ws:Connection con, ws:BinaryFrame frame) {
        system:println("client: " + messages:getStringPayload(m));
        con.pushBinary(frame.getBlob());
        var frame, e = con.ping();
    }

    resource onClose(ws:Connection con, int statusCode, string reason) {
        system:println("client left the server");
    }

    resource onPingMessage(ws:Connection con, ws:PingFrame frame) {

    }

    resource onError()

    resource onIdleTimeOut(Connection conn) {

    }
}
