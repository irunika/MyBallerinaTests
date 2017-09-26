package proxyserver;

import ballerina.lang.system;
import ballerina.net.ws;

@ws:clientService {}
service<ws> ClientService {

    resource onTextMessage(ws:Connection conn, ws:TextFrame frame) {
        system:println("Text message");
        ws:Connection parentCon = ws:getParentConnection(conn);
        ws:pushText(parentCon, frame.text);
    }

    resource onBinaryMessage(ws:Connection conn, ws:BinaryFrame frame) {
        system:println("Binary message");
        ws:Connection parentCon = ws:getParentConnection(conn);
        ws:pushBinary(parentCon, frame.data);
    }

    resource onClose(ws:Connection conn, ws:CloseFrame frame) {
        ws:Connection parentCon = ws:getParentConnection(conn);
        ws:closeConnection(parentCon, 1001, "Server closing connection");
    }

}