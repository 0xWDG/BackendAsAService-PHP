<?php
// Include BaaS-Server
include 'BaaS-Server.php';

// Initialize BaaS Server
$server = BaaS\Server::shared();

// always send this key in your post requests, otherwise it will not answer your request at all. (no error, b/c of bruteforcing)
$server->setDatabase(
    'MySQL',
    '127.0.0.1',
    'test',
    'root',
    ''
);
// $server->setDatabase(
//     'SQLite',
//     'Data/database.sqlite'
// );

// always send this key in your post requests, otherwise it will not answer your request at all. (no error, b/c of bruteforcing)
$server->setRegisteredAPIkey('§§DEVELOPMENT_UNSAFE_KEY§§');

// Set maximum invalid tries (invalid API key)
// Default: 3, probally high enough.
$server->setMaximumInvalidTries(3);

// Set reset time for invalid retries.
// In STRTIME format.
// Default: +24 hours
$server->setTriesTime("+24 hours");

// Set debug level (overwrites Maximum retries)
// Default: off
$server->setDebugmode(on);

// DO NEVER USE setAlwaysLoggedIn.
$server->setAlwaysLoggedIn(on);

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
