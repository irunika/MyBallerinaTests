
import ballerina.net.ws;
import ballerina.net.http;
import ballerina.lang.messages;

@http:configuration {basePath:"/group"}
@ws:WebSocketUpgradePath {value:"/ws"}
service<ws> connectionGroup  {

    @ws:OnTextMessage {}
    resource onText(message m) {
        string  text = messages:getStringPayload(m);
        sendMessage(text);
    }
}

function sendMessage(string text) {
    ws:pushText(text);
}