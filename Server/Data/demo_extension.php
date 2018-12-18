<?php
// Basic Extension
class myExtension extends \BaaS\Server
{
    // Function
    public function myFunction($tableName, $BaaS)
    {
        // Baas is our object
        if (!is_object($BaaS)) {
            return "BaaS is not an object, cannot continue test";
        }

        // Best way.
        $sSql = sprintf(
            // Query
            "INSERT INTO `%s` (name) VALUES (:name);",

            // Secure the input
            $BaaS->escapeString(preg_replace("/`/", "\\`", $tableName))
        );

        // Execute Query
        $result = $BaaS->queryWithParameters(
            // Query
            $sSql,

            // Parameter bindings
            array(
                "name" => "MySuperRandomName",
            )
        );

        // Get the result
        if ($result->Status == "Failed") {
            // something happend
            print_r($result);

            // Return to BaaS Server.
            return "Table does not exists!";
        } else {
            // All ok.
            print_r($result);

            // Return to BaaS Server.
            return "Hi";
        }
    }
}
