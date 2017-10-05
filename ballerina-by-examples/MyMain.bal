import ballerina.lang.system;
import ballerina.lang.maps;

function main(string [] args) {
    map m = {};
    m["x"] = "a";
    m["y"] = "b";
    m["z"] = "c";
    string [] keys = maps:keys(m);
    int len = lengthof keys;
    int i = 0;
    while (i < len) {
        string key = keys[i];
        var val, e = (string) m[key];
        //string val;
        //val, _ = (string) m[key];
        system:println(key + ": " + val);
        i = i + 1;
    }
   //printMapValues(m);
}

function printMapValues(map m) {
    string [] keys = maps:keys(m);
    int len = lengthof keys;
    int i = 0;
    while (i < len) {
        string key = keys[i];
        var val, e = (string) m[key];
        system:println(key + ": " + val);
        i = i + 1;
    }
}
