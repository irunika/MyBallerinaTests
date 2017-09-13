import ballerina.lang.system;
import ballerina.lang.messages;
import ballerina.net.ws;
import ballerina.net.http;

@http:configuration {basePath:"/group"}
@ws:WebSocketUpgradePath {value:"/ws"}
service<ws> websocketEndpoint {

    @ws:OnOpen {}
    resource onOpen(message m) {
        system:println("New connection open");
    }

    @ws:OnTextMessage {}
    resource onTextMessage(message m) {
        string textReceived = messages:getStringPayload(m);
        system:println("Text received: " + textReceived);
        ws:pushText("You said: " + textReceived);
    }

    @ws:OnClose {}
    resource onClose(message m) {
        system:println("Connection closed");
    }

}