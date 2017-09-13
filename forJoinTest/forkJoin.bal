import ballerina.lang.system;

function main (string[] args) {

    fork {
        worker w1 {
            int x = 10;
            system:println("worker 1");
            x -> fork;
        }

        worker w2 {
            string y = "hi";
            system:println("Worker 2");
            y  -> fork;
        }
    } join (all) (map results) {

        if (results["w1"] != null) {
            var resSet1, _ = (any[]) results["w1"];
            var res1, _ = (int) resSet1[0];
            system:println("worker 1: " + res1);
        }

        if (results["w2"] != null) {
            var resSet2, _ = (any[]) results["w2"];
            var res2, _ = (string) resSet2[0];
            system:println("worker 2: " + res2);
        }
    }

    worker w3 {
        system:println("Worker 3");
    }

    worker w4 {
        system:println("Worker 4");
    }
}
