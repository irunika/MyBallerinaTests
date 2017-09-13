
import ballerina.net.http;

@http:configuration {basePath:"/passthrough"}
service<http> passthrough {

    @http:GET{}
    resource passthrough (message m) {
        http:ClientConnector nyseEP = create http:ClientConnector("http://localhost:9090");
        message response = http:ClientConnector.get(nyseEP, "/nyseStock/stocks", m);
        reply response;

    }

}
