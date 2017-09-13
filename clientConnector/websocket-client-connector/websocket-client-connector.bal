import ballerina.lang.system;
import ballerina.lang.messages;
import ballerina.doc;
import ballerina.net.http;
import ballerina.net.ws;

@http:configuration {basePath:"/client-connector"}
@ws:WebSocketUpgradePath {value:"/ws"}
service<ws> serverConnector {


    @doc:Description {value:"This is where the messages from WebSocket clients are received."}
    @ws:OnTextMessage {}
    resource onText(ws:Connection conn, ws:Frame m) {

        ws:ClientConnector ctr = create ws:ClientConnector("ws://localhost:15500/websocket", "clientService", conn);

        string textReceived = messages:getStringPayload(m);

        if ("closeMe" == textReceived) {
            system:println("Removing the connection...");
            ws:closeConnection();
        } else {
            system:println("Client connector sending message: " +
                           messages:getStringPayload(m));
            ctr.pushText(messages:getStringPayload(m));
        }
    }

    @ws:OnBinaryMessage {}
    resource onBinaryMessage(message m) {
        system:println("server service binary");
        ws:ClientConnector.pushBinary(con, messages:getBinaryPayload(m));
    }
}


@doc:Description {value:"This is the client service for WebSocket client connector con mentioned above."}
@ws:ClientService {}
service<ws> clientService {

    @ws:OnTextMessage {}
    resource onText(message m) {
        system:println("client service string: " + messages:getStringPayload(m));
        // Sends message back to the client who sent the message from the server connector.
        ws:pushText("client service: " + messages:getStringPayload(m));
    }

    @ws:OnBinaryMessage {}
    resource onBinayMessage(message m) {
        blob b = messages:getBinaryPayload(m);
        system:println("client service binary");
        ws:pushBinary(b);
    }

    @ws:OnClose {}
    resource onClose(message m) {
        system:println("Closed client connection");
    }

    Regx x = {regx:"regx", isCompiled:true}
}

struct Regx {
    const string regex;
    const boolean isCompiled;
}
