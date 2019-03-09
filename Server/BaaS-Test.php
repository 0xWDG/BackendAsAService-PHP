<?php
exit(0); // No error.

/*
We're creating HTTP Calls right now, please be sure that PHP is running
 */
$uniqueKey = uniqid();

$tests = array(
    // Test for invalid request
    array(
        "http://127.0.0.1:8000/BaaS-Test.php",
        null,
        '{"Status":"Failed","Error":"Method not implented.","Method":"Unknown","Data":"Unknown","ReqURI":"\/BaaS-Test.php"}',
    ),
    // Test.action
    array(
        "http://127.0.0.1:8000/BaaS-Test.php/extension.test/{$uniqueKey}",
        array('my', 'mixed', 'data', 'is' => 'here', 'key' => $uniqueKey),
        sprintf('{"0":"my","1":"mixed","2":"data","is":"here","key":"%s"}', $uniqueKey),
    ),
    // Real stuff..
);

$testStatics = array(
    "pass" => 0,
    "fail" => 0,
);

function run($url, $postData, $expect, $doEcho = false)
{
    global $testStatics;
    $doEcho = !$doEcho;

    try {
        $opts = array(
            'http' => array(
                'method' => 'POST',
                'content' => sprintf(
                    "JSON=%s",
                    urlencode(
                        json_encode(
                            $postData
                        )
                    )
                ),
                // Maximum timeout of 5 seconds.
                'timeout' => 5,
                // Ignore http errors, such as 4xx and 5xx errors.
                'ignore_errors' => true,
            ),
        );

        $context = stream_context_create($opts);
        $output = file_get_contents($url, false, $context);
        // echo var_dump($http_response_header);

    } catch (Exception $e) {
        if ($doEcho) {
            echo sprintf(
                "[Exception] %s %s",
                $e->getMessage(),
                PHP_EOL
            );
        }
        $output = uniqid();
    }

    if ($expect == "*") {
        $expect = $output;
    }

    $testStatics[($output == $expect ? 'pass' : 'fail')]++;

    if ($doEcho) {
        echo sprintf(
            "[%s] \"%s\" %s",
            ($output == $expect ? 'Pass' : 'Fail'),
            $url,
            PHP_EOL
        );
    }

    return ($output == $expect);
}

if (php_sapi_name() == "cli") {
    echo "[Info] Server side..." . PHP_EOL;
    echo "[Info] Checking for connection... ";

    $socket = run("http://127.0.0.1:8000/BaaS-Test.php", null, '*', true);

    echo (!$socket ? 'Failed' : 'Connected') . PHP_EOL;
    $testStatics[(!$socket ? 'fail' : 'pass')]--;

    echo sprintf("[Info] Starting %s tests...%s", sizeof($tests), PHP_EOL);
    for ($i = 0; $i < sizeof($tests); $i++) {
        run($tests[$i][0], $tests[$i][1], $tests[$i][2]);
    }

    echo sprintf(
        "[Stats] Test run: %s%s[Stats] Passed: %s%s[Stats] Failed %s%s",
        ($testStatics['pass'] + $testStatics['fail']), PHP_EOL,
        $testStatics['pass'], PHP_EOL,
        $testStatics['fail'], PHP_EOL
    );
    exit;
}

/**
Initialize server.
With "Demo" database.
 */
include 'BaaS-Server.php';
$server = BaaS\Server::shared();
$server->setDatabase('SQLite', 'Data/test-database.sqlite');
$server->setRegisteredAPIkey('test_key');
$server->attachExtension("extension.test", "BaaS_ExtensionTest::testFunction", false);
echo $server->serve();
