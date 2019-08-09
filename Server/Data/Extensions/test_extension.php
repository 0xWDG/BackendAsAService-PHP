<?php
// BaaS Extension test.
class BaaS_ExtensionTest extends \BaaS\Server
{
    // Function
    public function testFunction($tableName, $BaaS)
    {
        // Baas is our object
        if (!is_object($BaaS)) {
            return "BaaS is not an object, cannot continue test";
        }

        // Encode JSON
        return json_encode(
            // Decode JSON
            json_decode(
                // JSON string
                $_POST['JSON'],

                // To array
                true
            )
        );
    }
}
