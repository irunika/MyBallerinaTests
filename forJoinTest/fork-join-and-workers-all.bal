import ballerina.lang.system;
import ballerina.lang.strings;

function main(string[] args) {
    var a, b, c = testForkJoinAndWorkersInSameFunction(10, "hi", 20);
    system:println(a + b + c);
}

function testForkJoinAndWorkersInSameFunction (int forkJoinInt, string forkJoinStr, int w3Int)
                                                                                        (int, string, int) {
    int forkReturnInt;
    string forkReturnStr;
    fork {
        worker w1 {
            forkJoinInt = forkJoinInt * 2;
            forkJoinInt -> fork;
        }

        worker w2 {
            forkJoinStr = strings:toUpperCase(forkJoinStr);
            forkJoinStr  -> fork;
        }
    } join (all) (map results) {

        var resSet1, _ = (any[]) results["w1"];
        var res1, _ = (int) resSet1[0];
        forkReturnInt = res1;
        system:println("forkReturnInt: " + forkJoinInt);

        var resSet2, _ = (any[]) results["w2"];
        var res2, _ = (string) resSet2[0];
        forkReturnStr = res2;
        system:println("forkReturnStr: " + forkReturnStr);
    }

    int w3ReturnInt;
    w3ReturnInt <- w3;

    return forkReturnInt, forkReturnStr, w3ReturnInt;

    worker w3 {
        system:println("w3Int: " + w3Int);
        w3Int = w3Int * 2;
        w3Int -> default;
    }

}
