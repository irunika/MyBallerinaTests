import ballerina.net.http;
import ballerina.net.ws;
import ballerina.lang.messages;
import ballerina.lang.system;

@http:configuration {basePath:"/client-connector"}
@ws:WebSocketUpgradePath {value:"/ws"}
service<ws> serverConnector {

    int i = 0;
    ws:ClientConnector c = create ws:ClientConnector("ws://localhost:15500/websocket", "clientService");

    @ws:OnOpen {}
    resource onOpen(message m) {
        i = i +1;
        system:println("No of connections: " + i);
    }

    @ws:OnTextMessage {}
    resource onText(message m) {
        string textReceived = messages:getStringPayload(m);

        if ("closeMe" == textReceived) {
            system:println("Removing the connection...");
            ws:closeConnection();
        } else {
            c.pushText(messages:getStringPayload(m));
        }
    }
}


@ws:ClientService {}
service<ws> clientService {

    @ws:OnTextMessage {}
    resource ontext(message m) {
        ws:pushText("client service : " + messages:getStringPayload(m));
    }

    @ws:OnClose {}
    resource onClose(message m) {
        system:println("Closed client connection");
    }
}
