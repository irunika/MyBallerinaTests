package myProject;

import ballerina.lang.messages;
import ballerina.net.ws;
import ballerina.net.http;

@http:configuration {basePath:"/myPath"}
@ws:WebSocketUpgradePath {value:"/receiver"}
service <ws> RealTimeService {
    @ws:OnOpen {}
    resource onOpen(message m) {
        ws:addConnectionToGroup("receivers");
    }
}

@http:configuration {basePath:"/myPath"}
@ws:WebSocketUpgradePath {value:"/sender"}
service<ws> myConnector  {

    @ws:OnTextMessage {}
    resource onText(message m) {
        ws:pushTextToGroup("receivers", messages:getStringPayload(m));
    }
}