<?php
// Include BaaS-Server
include 'BaaS-Server.php';

// Initialize BaaS Server
$server = BaaS\Server::shared();

// Set Connection type
$server->setDatabase(
    // Type
    'MySQL',
    // Host
    '127.0.0.1',
    // Database name
    'test',
    // Username
    'root',
    // Password
    ''
);
// $server->setDatabase(
//     // Type
//     'SQLite',
//     // Database Path
//     'Data/database.sqlite'
// );

// always send this key in your post requests, otherwise it will not answer your request at all. (no error, b/c of bruteforcing)
$server->setRegisteredAPIkey('DEVELOPMENT_UNSAFE_KEY');

// Set maximum invalid tries (invalid API key)
// Default: 3, probally high enough.
$server->setMaximumInvalidTries(3);

// Set reset time for invalid retries.
// In STRTIME format.
// Default: +24 hours
$server->setTriesTime("+24 hours");

// Set debug level (overwrites Maximum retries)
// Default: off
$server->setDebugmode(true);

// Set server's email address to send emails from
$server->setEmailAddress("BaaS@wdg.codes");

// Set server's activation page (register, reset password, activate)
// This must be public (see BaaS_Actions.php for a example).
// If you want to use the default one. comment bellow
// $server->setUserActionAddress("http://127.0.0.1/BaaS_Actions.php");

// Attach and load Extension.
$server->attachExtension(
    // Extension URL
    "test.extension",

    // Callable extension function.
    // See: Data/demo_extension.php
    "myExtension::myFunction",

    // API Key Required? (optional parameter, defaults to true)
    true
);

// Serve
echo $server->serve();

if (!headers_sent()) {
    // Debug me.
    print_r(
        array(
            $_SERVER['REQUEST_URI'],
            $_POST,
        )
    );
}
