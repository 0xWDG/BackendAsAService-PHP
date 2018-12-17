<?php
/**
 * Set the namespace to 'BaaS'
 */
namespace BaaS;

/**
 * Class 'Server'
 * Backend as a Service Server (BaaS Server)
 *
 * @version 1.0
 * @copyright Wesley de Groot (https://wesleydegroot.nl), et al.
 * @link https://github.com/wdg/BaaS
 * @url https://github.com/wdg/BaaS
 * @package BaaS
 */
class Server
{
    /**
     * BaaS version
     *
     * This one will never be exposed to the outside world.
     *
     * @since 1.0
     * @var string $version BaaS Version number
     */
    private $version = "1.0";

    /**
     * BaaS build
     *
     * This one will never be exposed to the outside world.
     *
     * @since 1.0
     * @var string $build BaaS build number
     */
    private $build = "181207 Beta";

    /**
     * Set API Version
     *
     * The API Version which we'll use to connect to.
     *
     * @since 1.0
     * @var string $APIVer API Version
     */
    private $APIVer = "1.0";

    /**
     * Debugmode
     *
     * @since 1.0
     * @var bool $debugmode set debug mode
     */
    private $debugmode = false;

    /**
     * Automatic translation
     *
     * @since 1.0
     * @var bool $translate set automatic translation on(auto)/off
     */
    private $translate = true;

    /**
     * API Key
     *
     * @since 1.0
     * @var string $APIKey the API key
     */
    private $APIKey = "invalid";

    /**
     * Maximum retries
     *
     * @since 1.0
     * @var integer $triesMaximum maximum tries
     */
    private $triesMaximum = 3;

    /**
     * Time befor resetting the maximum retries
     *
     * @since 1.0
     * @var string $triesTime time to reset maximum tries
     */
    private $tiesTime = "+24 hours";

    /**
     * Save file location.
     *
     * @since 1.0
     * @var string $BFfile File location
     */
    private $BFfile = "BFlog/%s.txt";

    /**
     * Save file directory.
     *
     * @since 1.0
     * @var string $blockFilePath Directory location
     */
    private $blockFilePath = "BFlog/";

    /**
     * is current user an Admin?
     *
     * @since 1.0
     * @var bool $isAdmin is it a admin
     */
    private $isAdmin = false;

    /**
     * Are we running on a cli (command line interface)
     *
     * @since 1.0
     * @var bool $isCLI is it a cli?
     */
    private $isCLI = (PHP_SAPI === 'cli');

    /**
     * Is there a error
     *
     * @since 1.0
     * @var bool $error is there a error
     */
    private $error = false;

    /**
     * What is the error message
     *
     * @since 1.0
     * @var string $errorMessage error message
     */
    private $errorMessage = "";

    /**
     * Save files to database?
     *
     * @since 1.0
     * @var string $saveFilesToDatabase Save files to the database?
     */
    private $saveFilesToDatabase = true;

    /**
     * Database Configuration
     *
     * @since 1.0
     * @var mixed $database database configuration
     */
    private $dbConfig = array(
        // Database Path
        'path' => 'Data/database.sqlite',

        // Database Type
        'type' => '',

        // Database Name
        'name' => '',

        // Database Username
        'user' => '',

        // Database Password
        'pass' => '',
    );

    /**
     * HTTP Protocol
     *
     * @since 1.0
     * @var string $protocol The protocol
     */
    private $protocol = 'HTTP/1.1';

    /**
     * return HTTP codes
     *
     * @since 1.0
     * @var string|array $errorCode Return this error codes
     */
    private $errorCode = array(
        // HTTP 406 = Not Acceptable
        'blocked' => 406,

        // HTTP 501 = Not Implemented
        'invalidRequest' => 501,

        // HTTP 200 = OK
        'ok' => 200,
    );

    /**
     * Defaults fields
     *
     * The fields which may be missing on insertion
     *
     * @since 1.0
     * @var string|array $errorCode Return this error codes
     */
    private $defaultFields = array(
        // ID field
        "id",

        // Latitude field
        "latitude",

        // Longitude field
        "longitude",
    );

    /**
     * Set database configuration
     *
     * @since 1.0
     * @param string $type mysql/sqlite
     * @param string $hostOrPath Host or Path name
     * @param string $databaseName Database name
     * @param string $username username
     * @param string $password Password
     * @return void
     */
    public function setDatabase($type, $hostOrPath = '', $databaseName = '', $username = '', $password = '')
    {
        // Set error = no
        $this->error = false;

        // Error message empty
        $this->errorMessage = "";

        // Check database type
        switch (strtolower($type)) {
            // database type is SQLite
            case 'sqlite':
                // Set database type to SQLite
                $this->dbConfig['type'] = 'sqlite';

                // If host/path name is not empty
                if (!empty($hostOrPath)) {
                    // Check if the path is writeable
                    if (is_writable($hostOrPath) || touch($hostOrPath)) {
                        // Set the path
                        $this->dbConfig['path'] = $hostOrPath;
                    } else {
                        // Error
                        $this->error = true;
                        // Path is not writeable
                        $this->errorMessage = sprintf(
                            "Path \"%s\" is not writeable",
                            $hostOrPath
                        );
                    }
                }
                break;

            case 'mysql':
                // Set database type to MySQL
                $this->dbConfig['type'] = 'mysql';

                // Check if required information is not missing
                if (empty($hostOrPath)) {
                    // Error
                    $this->error = true;
                    // Missing hostname and username!
                    $this->errorMessage = "Missing hostname";
                }

                // Check if required information is not missing
                if (empty($username)) {
                    // Error
                    $this->error = true;
                    // Missing hostname and username!
                    $this->errorMessage = "Missing username";
                }

                // Check if required information is not missing
                if (empty($databaseName)) {
                    // Error
                    $this->error = true;
                    // Missing hostname and username!
                    $this->errorMessage = "Missing database name.";
                }

                // If not empty
                if (!empty($hostOrPath)) {
                    // Set the database host
                    $this->dbConfig['host'] = $hostOrPath;
                }

                // If not empty
                if (!empty($databaseName)) {
                    // Set the database name
                    $this->dbConfig['name'] = $databaseName;
                }

                // If not empty
                if (!empty($username)) {
                    // Set the database username
                    $this->dbConfig['user'] = $username;
                }

                // Set the database password
                $this->dbConfig['pass'] = $password;
                break;

            default:
                // Oops a error
                $this->error = false;

                // Set the error message
                $this->errorMessage = sprintf(
                    "Database type %s does not exists",
                    $type
                );
                break;
        }
    }

    /**
     * Check API Key
     *
     * @since 1.0
     * @internal
     * @return bool
     */
    private function checkAPIKey()
    {
        // First check if the key is not invalid.
        if ($this->APIKey == "invalid") {
            // Return invalid key
            return false;
        }

        // Find a quick way to disable bruteforcing.
        if (file_exists($this->BFfile)) {
            // If the file contents > maximum tries
            if ((int) file_get_contents($this->BFfile) >= $this->triesMaximum) {
                // If current time > Max. Tries. time + File modified time
                if (time() > strtotime($this->triesTime, filemtime($this->BFfile))) {
                    // Try to unlink the file
                    @unlink($this->BFfile);
                } else {
                    // Check if not in debug mode
                    if (!$this->debugmode) {
                        $this->set_http_code($this->errorCode['blocked']);

                        // Say wrong APIKey
                        header("API-Key: Invalid");

                        // blocked.
                        echo (
                            json_encode(
                                array(
                                    // Send Status
                                    "Status" => "Failed",

                                    // Send the warning message
                                    'Warning' => "You are blocked from using this service.",

                                    // Send some details
                                    'Details' => sprintf(
                                        "BaaS/%s, Connection: Close, IP-Address: %s",
                                        $this->APIVer, $_SERVER['REMOTE_ADDR']
                                    ),

                                    // Return the API Key
                                    'APIKey' => (
                                        isset($_POST['APIKey'])
                                        ? $_POST['APIKey']
                                        :
                                        (
                                            json_decode($_POST['JSON'])->APIKey
                                            ? json_decode($_POST['JSON'])->APIKey
                                            : 'None prodived'
                                        )
                                    ),
                                )
                            )
                        );

                        // Exit
                        // 0 means no error, since we'll want to output the error.
                        exit($this->$isCLI ? 1 : 0);

                        // You're still blocked
                        return false;
                    }
                }
            }
        }

        // Check if the key is valid
        if (isset($_POST['APIKey'])) {
            // if POST APIKey equals APIKey
            if ($_POST['APIKey'] === $this->APIKey) {
                // APIKey is valid
                return true;
            }
        }

        // Check if the key is valid, the JSON way.
        if (isset($_POST['JSON'])) {
            // if POST JSON APIKey equals APIKey
            if (json_decode($_POST['JSON'])->APIKey === $this->APIKey) {
                // APIKey is valid
                return true;
            }
        }

        // Something happend :)
        $this->setAttempt($_SERVER['REMOTE_ADDR']);

        // Send new headers.
        $this->set_http_code($this->errorCode['blocked']);

        // Say wrong APIKey
        header("API-Key: Invalid");

        echo (
            json_encode(
                array(
                    // Send Status
                    "Status" => "Failed",

                    // Send warning
                    'Warning' => "You are using an invalid API key for this service.",

                    // Send details
                    'Details' => sprintf(
                        "BaaS/%s, Connection: Close, IP-Address: %s",
                        $this->APIVer, $_SERVER['REMOTE_ADDR']
                    ),

                    // Send API key back
                    'APIKey' => (
                        isset($_POST['APIKey']) ? $_POST['APIKey'] : (
                            json_decode($_POST['JSON'])->APIKey ? json_decode($_POST['JSON'])->APIKey : 'None prodived'
                        )
                    ),
                )
            )
        );

        // Exit
        // 0 means no error, since we'll want to output the error.
        exit($this->$isCLI ? 1 : 0);

        return false;
    }

    /**
     * Get tablename from SQL Query.
     *
     * Supported:
     * <pre>
     *     SELECT WHATEVER FROM WHERE  ...
     *     INSERT * INTO X VALUES ()
     *     DELETE FROM X WHERE ...
     *     CREATE TABLE X ()
     * </pre>
     *
     * @since 1.0
     * @param string $SQLString The SQL Query
     * @return string the table name
     */
    private function tableFromSQLString($SQLString)
    {
        // Check if we can find the table, from the SQL Command
        // Supported:
        //   SELECT WHATEVER FROM WHERE  ...
        //   INSERT * INTO X VALUES ()
        //   DELETE FROM X WHERE ...
        //   CREATE TABLE X ()
        preg_match_all(
            // Regular expression
            "/(FROM|INTO|FROM|TABLE) (`)?([a-zA-Z0-9]+)(`)?/i",

            // Matches the Query?
            $SQLString,

            // Return matches
            $match
        );

        // There's a match!
        if (isset($match[3][0])) {
            // And check if it is not empty.
            if (!empty($match[3][0])) {
                // Found table name!
                return $match[3][0];
            }
        }

        // Something Happend...
        return "Error";
    }

    /**
     * Does our table exists?
     *
     * @since 1.0
     * @param String $tableName table name
     */
    private function tableExists($tableName)
    {
        if (!isset($this->db)) {
            echo json_encode(
                array(
                    // Send Status
                    "Status" => "Failed",

                    // Send error message
                    "Error" => "Not connected to a database",

                    // Send how-to-fix
                    "Fix" => "Please check the database configuration",

                    // Send debug text if debugmode is on.
                    "Debug" => ($this->debugmode ? $this->dbConfig : 'Off'),
                )
            );

            exit($this->$isCLI ? 1 : 0);
        }

        // Check database type
        if ($this->dbConfig['type'] == "mysql") {
            // Return
            return (
                // Query
                $this->db->query(
                    // Internal select DB method
                    sprintf(
                        // Select count(*)
                        "SELECT count(*) FROM information_schema.tables WHERE table_name = '%s'",

                        // Santisize input
                        $this->escapeString(
                            preg_replace(
                                // `
                                "/`/",

                                // \`
                                "\\`",

                                // tableName
                                $tableName
                            )
                        )
                    )
                    // FetchColumns is more then 0 then the table exists.
                )->fetchColumn() > 0
            );
        }

        // We'll going SQLite
        return (
            // Query
            $this->db->query(
                // Internal select DB method
                sprintf(
                    // Select count(*)
                    "select count(*) FROM `sqlite_master` WHERE `type`='table' AND `name`='%s'",

                    // Santisize input
                    $this->escapeString(
                        preg_replace(
                            // `
                            "/`/",

                            // \`
                            "\\`",

                            // tableName
                            $tableName
                        )
                    )
                )
                // FetchColumns is more then 0 then the table exists.
            )->fetchColumn() > 0
        );
    }

    /**
     * Set the debugmode
     *
     * @since 1.0
     * @param bool $status On or Off
     */
    public function setDebugmode($status)
    {
        // Set the debugmode
        $this->debugmode = $status;
    }

    /**
     * Set the API Key
     *
     * @since 1.0
     * @param string $newAPIKey API Key
     */
    public function setRegisteredAPIKey($newAPIKey)
    {
        // Set the API Key
        $this->APIKey = $newAPIKey;
    }

    /**
     * Set Maximum tries
     *
     * @since 1.0
     * @param int $setMaximumTries Maximum tries
     */
    public function setMaximumInvalidTries($setMaximumTries)
    {
        // Set Maximum tries
        $this->triesMaximum = $setMaximumTries;
    }

    /**
     * Set Maximum tries (in time)
     *
     * @since 1.0
     * @param string $setTriesTime Time in strtotime format
     */
    public function setTriesTime($setTriesTime)
    {
        // Set Maximum tries (in time)
        $this->triesTime = $setTriesTime;
    }

    /**
     * Set invalid attempt
     *
     * @since 1.0
     * @param string $IPAddress the ip address
     */
    private function setAttempt($IPAddress)
    {
        // set tries to 1
        $tries = 0;

        // if we have a archive read it.
        if (file_exists($this->BFfile)) {
            // get tries as int.
            $tries = (int) file_get_contents($this->BFfile);
        }

        // try +1
        $tries++;

        // Do not save anymore if more then 3 attempts registered.
        if ($tries < $this->triesMaximum) {
            // save try count
            file_put_contents($this->BFfile, $tries);
        }
    }

    /**
     * Set always logged in
     *
     * @since 1.0
     * @param bool $onOff On or Off
     */
    public function setAlwaysLoggedIn($onOff)
    {
        // Check if debugmode = on, and $onOff = true
        if ($this->debugmode && $onOff) {
            // Say's i'm logged in
            $this->isAdmin = true;

            // Create fake adminUserLoggedToken
            $_SESSION['adminUserLoggedToken'] = uniqid();
        }
    }

    /**
     * Reset old login attempts
     * @since 1.0
     */
    private function resetOldAttempts()
    {
        // Create a list with all blocked users.
        $blockedList = glob(
            // Get correct file path
            sprintf(
                // BFDir/%s.txt
                $this->BFfile,
                // %s = *
                "*"
            )
        );

        // Walk trough the blocked IP-list
        for ($i = 0; $i < sizeof($blockedList); $i++) {
            // If the time is more then the maximum
            if (time() > strtotime($this->triesTime, filemtime($blockedList[$i]))) {
                // Reset the login attempt.
                unlink($blockedList[$i]);
            }
        }
    }

    /**
     * Serve the BaaS Server.
     *
     * @since 1.0
     * @return mixed|string Page contents (JSON/HTML)
     */
    public function serve()
    {
        // If exists (DATABASE_TYPE)
        if (!empty($this->dbConfig['type'])) {
            // Try it
            try {
                // Connect to our SQLite database
                if ($this->dbConfig['type'] == "mysql") {
                    // If defined $this->dbConfig['host'], $this->dbConfig['name'],
                    // $this->dbConfig['user']
                    if (!empty($this->dbConfig['host']) &&
                        !empty($this->dbConfig['name']) &&
                        !empty($this->dbConfig['user'])) {
                        // Then let's try to connect!
                        $this->db = new \PDO(
                            sprintf(
                                // mysql:host=$this->dbConfig['host'];
                                // dbname=$this->dbConfig['name'];charset=UTF8
                                "mysql:host=%s;dbname=%s;charset=UTF8",

                                // Host
                                $this->dbConfig['host'],

                                // DB Name
                                $this->dbConfig['name']
                            ),

                            // Username
                            $this->dbConfig['user'],

                            // Password
                            $this->dbConfig['pass']
                        );
                    }
                } else {
                    // SQLite!
                    if (!empty($this->dbConfig['path'])) {
                        // Try to create/load a SQLite database
                        $this->db = new \PDO(
                            // sqlite:DBName.sqlite
                            sprintf(
                                // sqlite:DBName.sqlite
                                'sqlite:%s',

                                // Database Path
                                $this->dbConfig['path']
                            )
                        );
                    }
                }
                // Set the error mode
                $this->db->setAttribute(
                    // Set the error mode
                    \PDO::ATTR_ERRMODE,

                    // To Trow Exceptions.
                    \PDO::ERRMODE_EXCEPTION
                );
            } catch (PDOException $e) {
                // Handle the exception
                return $this->handleException($e);
            }
        } else {
            echo json_encode(
                array(
                    // Send Status
                    "Status" => "Failed",

                    // Send Error message
                    "Error" => "Missing server type, cannot continue.",

                    // Send how-to-fix
                    "Fix" => "Please review your configuration settings",
                )
            );
        }

        if (!isset($this->db)) {
            echo json_encode(
                array(
                    // Send Status
                    "Status" => "Failed",

                    // Send Error message
                    "Error" => sprintf("Failed to connect to the %s database", $this->dbConfig['type']),

                    // Send how-to-fix
                    "Fix" => "Please review your configuration settings",

                    // Send server information
                    "Server" => array(
                        // Send server type
                        "Type" => $this->dbConfig['type'],

                        // Send server status
                        "Status" => (
                            $this->dbConfig['type'] == 'mysql'
                            ? $this->isTheServerAvailable($this->dbConfig['host'])
                            : 'N/A'
                        ),
                    ),
                )
            );

            exit($this->$isCLI ? 1 : 0);
        }

        // Check if there is a DATABASE_TYPE defined.
        if ($this->error) {
            return json_encode(
                array(
                    // Send Status
                    "Status" => "Failed",

                    // Database type is missing
                    "Error" => !empty($this->errorMessage)
                    ? $this->errorMessage
                    : "No database type is selected",

                    // Show a fix
                    "Fix" => "Check the documentation!",
                )
            );
        }

        if (empty($this->dbConfig['type'])) {
            return json_encode(
                array(
                    // Send Status
                    "Status" => "Failed",

                    // Send error message
                    "Error" => "Not connected to a database!",

                    // Send how-to-fix
                    "Fix" => "Set database configuration.",

                    // Send server/database type
                    "Type" => $this->dbConfig['type'],
                )
            );
        }

        if ($this->dbConfig['type'] == "mysql") {
            // Check if there is a $this->dbConfig['host'] defined.
            if (empty($this->dbConfig['host'])) {
                // Missing, so return a error.
                return json_encode(
                    array(
                        // Send Status
                        "Status" => "Failed",

                        // Database host is missing
                        "Error" => "No database host is entered",

                        // Show a fix
                        "Fix" => "Please select a valid database host",
                    )
                );
            }
            // Check if there is a $this->dbConfig['name'] defined.
            if (empty($this->dbConfig['name'])) {
                // Missing, so return a error.
                return json_encode(
                    array(
                        // Send Status
                        "Status" => "Failed",

                        // Database name is missing
                        "Error" => "No database name is entered",

                        // Show a fix
                        "Fix" => "Please select a valid database name",
                    )
                );
            }
            // Check if there is a $this->dbConfig['user'] defined.
            if (empty($this->dbConfig['user'])) {
                // Missing, so return a error.
                return json_encode(
                    array(
                        // Send Status
                        "Status" => "Failed",

                        // Database user is missing
                        "Error" => "No database user is entered",

                        // Show a fix
                        "Fix" => "Please select a valid database user",
                    )
                );
            }
        }

        // Check if block file path is writeable
        if (!is_writeable($this->blockFilePath)) {
            // Re chmod
            @chmod($this->blockFilePath, 0777);
        }

        // Check if block file path is writeable
        if (!is_writeable($this->blockFilePath)) {
            // error, we cannot continue now.
            return json_encode(
                array(
                    // Send Status
                    "Status" => "Failed",

                    // File path is not writeable
                    "Error" => "File path is not writeable",

                    // Show file path
                    "FilePath" => $this->blockFilePath,
                )
            );
        }

        // Reset old attempts
        $this->resetOldAttempts();

        // Handle /db.admin/ methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/db\.admin(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // Run "DBAdmin"
            return $this->DBAdmin(
                // If no action then show index
                empty($action[2][0]) ? 'index' : $action[2][0]
            );
        }

        // Handle /row.get/xxx methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/row\.get(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // check the API KEY
            $this->checkAPIKey();

            // If /row.get/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Run "rowAction"
                return $this->rowAction(
                    // With value xxx
                    $action[2][0],

                    // It's a get action
                    "get"
                );
            }
        }

        // Handle /row.set/xxx methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/row\.set(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // check the API KEY
            $this->checkAPIKey();

            // If /row.set/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Parse and echo
                return $this->rowAction(
                    // With value xxx
                    $action[2][0],

                    // It's a set action
                    "set"
                );
            }
        }

        // Handle /row.delete/xxx methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/row\.delete(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // check the API KEY
            $this->checkAPIKey();

            // If /row.delete/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Parse and echo
                return $this->rowAction(
                    // With value xxx
                    $action[2][0],

                    // It's a delete action
                    "delete"
                );
            }
        }

        // Handle /row.insert/xxx methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/row\.insert(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // check the API KEY
            $this->checkAPIKey();

            // If /row.insert/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Parse and echo
                return $this->rowInsert(
                    // With value xxx
                    $action[2][0]
                );
            }
        }

        // Handle /table.create/xxx methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/table\.create(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // check the API KEY
            $this->checkAPIKey();

            // If /table.create/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Parse and echo
                return $this->tableCreate(
                    // With value xxx
                    $action[2][0]
                );
            }
        }

        // Handle /table.append/xxx methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/table\.append(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // check the API KEY
            $this->checkAPIKey();

            // If /table.append/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Parse and echo
                return $this->tableAppend(
                    // With value xxx
                    $action[2][0]
                );
            }
        }

        // Handle /table.empty/xxx methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/table\.empty(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // check the API KEY
            $this->checkAPIKey();

            // If /table.empty/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Parse and echo
                return $this->tableEmpty(
                    // With value xxx
                    $action[2][0]
                );
            }
        }

        // Handle /table.remove/xxx methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/table\.remove(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // check the API KEY
            $this->checkAPIKey();

            // If /table.remove/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Parse and echo
                return $this->tableRemove(
                    // With value xxx
                    $action[2][0]
                );
            }
        }

        // Handle /table.rename/xxx methods
        if (
            preg_match_all(
                // escape "." and allow everything after "/"
                "/table\.rename(\/?)(.*)/",

                // The current requested url
                $_SERVER['REQUEST_URI'],

                // Save to $action
                $action
            )
        ) {
            // check the API KEY
            $this->checkAPIKey();

            // If /table.rename/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Parse and echo
                return $this->tableRename(
                    // With value xxx
                    $action[2][0]
                );
            }
        }

        // Oh, dear, that is a invalid request.
        return $this->invalidRequest();
    }

    /**
     * Invalid request
     *
     * @since 1.0
     * @param string $request the type/value
     * @return string JSON Error.
     */
    private function invalidRequest($request = 'Unknown')
    {
        // Set HTTP status code
        $this->set_http_code($this->errorCode['invalidRequest']);

        // Explode the "uri" split all /'es
        $requestedURI = explode("/", $_SERVER['REQUEST_URI']);

        // Get current method
        $method = (sizeof($requestedURI) > 2) ? $requestedURI[sizeof($requestedURI) - 2] : 'Unknown';

        // Display error to the user
        return json_encode(
            array(
                // Send Status
                "Status" => "Failed",

                // Error Message
                "Error" => "Method not implented.",

                // Get current Method
                "Method" => $method,

                // Wit. data
                "Data" => $request,

                // Requested URI
                "ReqURI" => $_SERVER['REQUEST_URI'],
            )
        );
    }

    /**
     * Create table
     *
     * @since 1.0
     * @param string $tableName the table name
     * @return mixed
     */
    private function tableCreate($tableName)
    {
        /*
        CREATE TABLE `x` (
        `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
        `latitude` text DEFAULT NULL,
        `longitude` text DEFAULT NULL,
        `x` text DEFAULT NULL,
        PRIMARY KEY (`id`)
        ) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1
         */
        $sSql = sprintf(
            // Create table.
            "CREATE TABLE `%s` (\n",

            // Escape the database
            $this->escapeString(
                // Replace insecure fields
                preg_replace(
                    // `
                    "/`/",

                    // to \\`
                    "\\`",

                    // in $databaseName
                    $databaseName
                )
            )
        );

        // Append default fields.
        // id (auto incrementing)
        $sSql .= sprintf(
            "`id` int(11) unsigned NOT NULL AUTO_INCREMENT,\n"
        );

        // latitude
        $sSql .= sprintf(
            "`latitude` text DEFAULT NULL,\n"
        );

        // longitude
        $sSql .= sprintf(
            "`longitude` text DEFAULT NULL,\n"
        );

        //TODO: Real fields instead of fakes.
        $fields = array(
            'a',
            'b',
            'c',
        );

        // Loop trough the fields
        foreach ($fields as $field) {
            // Check if a field is not in the of pre-reserved fields.
            if (!in_array($field, $this->defaultFields)) {
                $sSql .= sprintf(
                    // `field` text default nullable
                    "`%s` text DEFAULT NULL,\n",

                    // Replace insecure text
                    preg_replace(
                        // `
                        "/`/",

                        // to \\`
                        "\\`",

                        // in $field
                        $field
                    )
                );
            }
        }

        // set the primary key.
        $sSql .= sprintf(
            "PRIMARY KEY (`id`)"
        );

        // End the create query.
        $sSql .= sprintf(
            ") ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;"
        );

        // Exit with the sql command.
        print_r($sSql);exit;

        return $this->invalidRequest($tableName);
    }

    /**
     * Append column to table
     *
     * @since 1.0
     * @param string $tableName the table name
     * @return mixed
     */
    private function tableAppend($tableName)
    {
        $sSql = sprintf(
            // Create table.
            "ALTER TABLE `%s` APPEND (\n",

            // Escape the database
            $this->escapeString(
                // Replace insecure fields
                preg_replace(
                    // `
                    "/`/",

                    // to \\`
                    "\\`",

                    // in $databaseName
                    $databaseName
                )
            )
        );

        return $this->invalidRequest($tableName);
    }

    /**
     * Empty table
     *
     * @since 1.0
     * @param string $tableName the table name
     * @return mixed
     */
    private function tableEmpty($tableName)
    {
        $sSql = sprintf(
            // Create table.
            "TRUNCATE TABLE `%s`;\n",

            // Escape the database
            $this->escapeString(
                // Replace insecure fields
                preg_replace(
                    // `
                    "/`/",

                    // to \\`
                    "\\`",

                    // in $databaseName
                    $databaseName
                )
            )
        );

        return $this->invalidRequest($tableName);
    }

    /**
     * Remove table
     *
     * @since 1.0
     * @param string $tableName the table name
     * @return mixed
     */
    private function tableRemove($tableName)
    {
        $sSql = sprintf(
            // Create table.
            "DROP TABLE `%s`;\n",

            // Escape the database
            $this->escapeString(
                // Replace insecure fields
                preg_replace(
                    // `
                    "/`/",

                    // to \\`
                    "\\`",

                    // in $databaseName
                    $databaseName
                )
            )
        );

        return $this->invalidRequest($tableName);
    }

    /**
     * Rename table
     *
     * @since 1.0
     * @param string $tableName the table name
     * @return mixed
     */
    private function tableRename($tableName)
    {
        $sSql = sprintf(
            // Create table.
            "RENAME TABLE `%s` TO `%s`;\n",

            // Escape the database
            $this->escapeString(
                // Replace insecure fields
                preg_replace(
                    // `
                    "/`/",

                    // to \\`
                    "\\`",

                    // in $databaseName
                    $databaseName
                )
            ),

            // new Table Name
            $newName = 'x'
        );

        return $this->invalidRequest($tableName);
    }

    /**
     * SQL query
     *
     * @since 1.0
     * @param string $query the SQL Query
     * @return mixed
     */
    private function query($query)
    {
        // Execute the query
        return $this->db->query($query);
    }

    /**
     * Escape SQL query
     *
     * @since 1.0
     * @param string $insecureInput the unsecure SQL Query
     * @return string the (more)secure SQL Query
     */
    private function escapeString($insecureInput)
    {
        // Replace unsafe characters
        return str_replace(
            // Unsafe
            array("\\", "\x00", "\n", "\r", "'", '"', "\x1a"),

            // Sanitized
            array("\\\\", "\\0", "\\n", "\\r", "\'", '\"', "\\Z"),

            // Original input
            $insecureInput
        );
    }

    /**
     * Row Set/Get/Delete
     *
     * This function translates the user input to a understandable value for the database
     *
     * @since 1.0
     * @param string $databaseName
     * @internal
     * @return mixed
     */
    private function rowAction($databaseName, $action = "get")
    {
        // First, decode the JSON input.
        $decodedJSON = json_decode(
            // JSON input
            $_POST['JSON'],

            // to array
            true
        );

        // If the size of decoded JSON < 1 or not a array
        if (!is_array($decodedJSON) || sizeof($decodedJSON) < 1) {
            // return error
            return array(
                // Send Status
                "Status" => "Failed",

                // Send error
                "Error" => "Please post JSON",

                // Send how-to-fix
                "Fix" => "Failed to decode JSON",
            );
        }

        // Create empty bindings array
        $bindings = array();

        // Start creating the SQL command!
        $SQLcommand = "";

        // What do we need to do?
        switch ($action) {
            // Get something
            // row.get
            case 'get' :
                $SQLcommand = sprintf(
                    // Select .. FROM `database`
                    "SELECT %s FROM `%s`",

                    // Select * (all)
                    "*",

                    // Escape the database
                    $this->escapeString(
                        // Replace insecure fields
                        preg_replace(
                            // `
                            "/`/",

                            // to \\`
                            "\\`",

                            // in $databaseName
                            $databaseName
                        )
                    )
                );
                break;

            // Set/Update something
            // row.set
            case 'set':
                // Check if we have values
                if (!isset($decodedJSON['values'])) {
                    // Return error message
                    return json_encode(
                        array(
                            // Send Status
                            "Status" => "Failed",

                            // Missing value
                            "Error" => "Can not update nothing",

                            // Which one?
                            "Fix" => "Use: values[[key, value]]",
                        )
                    );
                }

                $SQLcommand = sprintf(
                    // Select .. FROM `database`
                    "UPDATE `%s` SET ",

                    // Escape the database
                    $this->escapeString(
                        // Replace insecure fields
                        preg_replace(
                            // `
                            "/`/",

                            // to \\`
                            "\\`",

                            // in $databaseName
                            $databaseName
                        )
                    )
                );
                break;

            // Delete something
            // row.delete
            case 'delete':
                $SQLcommand = sprintf(
                    // Select .. FROM `database`
                    "DELETE FROM `%s`",
                    // Escape the database
                    $this->escapeString(
                        // Replace insecure fields
                        preg_replace(
                            // `
                            "/`/",

                            // to \\`
                            "\\`",

                            // in $databaseName
                            $databaseName
                        )
                    )
                );
                break;

            // This should never happen
            default:
                // JSON encode
                return json_encode(
                    // Error messages
                    array(
                        // Send Status
                        "Status" => "Failed",

                        // Invalid request
                        "Error" => "Invalid request",

                        // Invalid action
                        "ReqURI" => $action,
                    )
                );
                break;
        }

        // Check if "where" exists!
        if (isset($decodedJSON['values'])) {
            // Check if we have values
            if (is_array($decodedJSON['values'])) {
                // Parse trough our values
                for ($i = 0; $i < sizeof($decodedJSON['values']); $i++) {
                    // Check if there were enough values sended
                    if (sizeof($decodedJSON['values'][$i]) == 1) {
                        // If i is more then 0 append a , seporator
                        if ($i > 0) {
                            // Append seporator
                            $SQLcommand .= ', ';
                        }

                        // Create for every statement a Parameter ID.
                        $paramID = "x" . uniqid();

                        // First parameter cleanup.
                        $firstParameter = trim(
                            strip_tags(
                                $decodedJSON['values'][$i][0]
                            )
                        );

                        // Append `%s` = :paramID
                        // values %s = firstParameter
                        $SQLcommand .= sprintf(
                            "`%s` = :%s",
                            preg_replace(
                                // Replace `
                                "/`/",

                                // With \`
                                "\\`",

                                // in
                                $firstParameter
                            ),
                            $paramID
                        );

                        // Append paramID with value to our array
                        $bindings[$paramID] = $decodedJSON['values'][$i][1];
                    } else {
                        // Show error
                        return json_encode(
                            array(
                                // Send Status
                                "Status" => "Failed",

                                // Show error
                                "Error" => "Incorrect number of (set) parameters [Expected: 2]",

                                // Return sended values
                                "Where" => $decodedJSON['values'][$i],
                            )
                        );
                    }
                }
            }
        }

        // Check if "where" exists!
        if (isset($decodedJSON['where'])) {
            // Check if it is a "array"
            if (is_array($decodedJSON['where'])) {
                // Append " WHERE " to the SQL command
                $SQLcommand .= " WHERE ";

                // needs to be a sub-array
                // [xxx, eq, xxx]
                // [xxx, neq, xyz]
                // [xxx, like, xx]
                // [lat,lon, location, maxRangeInKM]
                //
                // Translate.
                // SELECT KEY FROM DATABASE WHERE
                // ...

                // Loop trough all "where" statements
                for ($i = 0; $i < sizeof($decodedJSON['where']); $i++) {
                    if (sizeof($decodedJSON['where'][$i]) == 3) {
                        // Create for every statement a Parameter ID.
                        $paramID = "x" . uniqid();

                        // If we are more then id 0 then
                        if ($i > 0) {
                            // append " AND" to SQL command
                            $SQLcommand .= " AND ";
                        }

                        // Switch type (eq, neq, loc, like) (lowercased)
                        switch (strtolower($decodedJSON['where'][$i][1])) {
                            // Equals to
                            case 'eq':
                            case '=':
                                // First parameter cleanup.
                                $firstParameter = trim(
                                    strip_tags(
                                        $decodedJSON['where'][$i][0]
                                    )
                                );

                                // Append `%s` = :paramID
                                // where %s = firstParameter
                                $SQLcommand .= sprintf(
                                    "`%s` = :%s",
                                    preg_replace(
                                        // Replace `
                                        "/`/",

                                        // With \`
                                        "\\`",

                                        // in
                                        $firstParameter
                                    ),
                                    $paramID
                                );

                                // Append paramID with value to our array
                                $bindings[$paramID] = $decodedJSON['where'][$i][2];
                                break;

                            // Not equals to
                            case 'neq':
                            case '!=':
                                // First parameter cleanup.
                                $firstParameter = trim(
                                    strip_tags(
                                        $decodedJSON['where'][$i][0]
                                    )
                                );

                                // Append `%s` != :paramID
                                // where %s = firstParameter
                                $SQLcommand .= sprintf(
                                    "`%s` != :%s",
                                    preg_replace(
                                        // Replace `
                                        "/`/",

                                        // With \`
                                        "\\`",

                                        // in
                                        $firstParameter
                                    ),
                                    $paramID
                                );

                                // Append paramID with value to our array
                                $bindings[$paramID] = $decodedJSON['where'][$i][2];
                                break;

                            // Like
                            case 'like':
                                // First parameter cleanup.
                                $firstParameter = trim(
                                    strip_tags(
                                        $decodedJSON['where'][$i][0]
                                    )
                                );

                                // Append `%s` LIKE :paramID
                                // where %s = firstParameter
                                $SQLcommand .= sprintf(
                                    "`%s` LIKE :%s",
                                    preg_replace(
                                        // Replace `
                                        "/`/",

                                        // With \`
                                        "\\`",

                                        // in
                                        $firstParameter
                                    ),
                                    $paramID
                                );

                                // Append paramID with value to our array
                                $bindings[$paramID] = $decodedJSON['where'][$i][2];
                                break;

                            // Search by location, this one is interesting.
                            case 'loc':
                            case 'location':
                                // Explode "lat,lon" seperator = ,
                                $locationData = explode(",", $decodedJSON['where'][$i][0]);

                                // Create a unique Parameter ID for lat
                                $latParamID = "x" . uniqid();

                                // Create a unique Parameter ID for lon
                                $lonParamID = "x" . uniqid();

                                // Create a unique Parameter ID for Distance
                                $disParamID = "x" . uniqid();

                                if ($this->dbConfig['type'] == "sqlite") {
                                    // Append our special function to the SQL command
                                    // distance(latitude, longitude, $lat, $lon) is a custom function.
                                    $SQLcommand .= sprintf(
                                        "distance(latitude, longitude, :%s, :%s) < :%s",

                                        // Latitude Parameter ID
                                        $latParamID,

                                        // Longitude Parameter ID
                                        $lonParamID,

                                        // Distance Parameter ID
                                        $disParamID
                                    );
                                } else {
                                    // Append our special calculatoion function to the SQL command
                                    $SQLcommand .= sprintf(
                                        "ST_Distance(point (latitude, longitude), point (:%s, :%s)) < :%s",

                                        // Latitude Parameter ID
                                        $latParamID,

                                        // Longitude Parameter ID
                                        $lonParamID,

                                        // Distance Parameter ID
                                        $disParamID
                                    );
                                }

                                // Append latitude Parameter ID to our array
                                $bindings[$latParamID] = $locationData[0];

                                // Append longitude Parameter ID to our array
                                $bindings[$lonParamID] = $locationData[1];

                                // Append distance Parameter ID to our array
                                $bindings[$disParamID] = $decodedJSON['where'][$i][2];
                                break;

                            // We did not regonize this command
                            default:
                                // This should never happen.
                                // But, you are never sure what will happen.

                                // Check if we have created a " AND ".
                                if (substr($SQLcommand, -5) == " AND ") {
                                    // Ok, let's remove it.
                                    $SQLcommand = substr($SQLcommand, 0, -5);
                                }
                                break;
                        }
                    } else {
                        // Show error
                        return json_encode(
                            array(
                                // Send Status
                                "Status" => "Failed",

                                // Show error
                                "Error" => "Incorrect number of (where) parameters [Expected: 3]",

                                // Return values
                                "Where" => $decodedJSON['where'][$i],
                            )
                        );
                    }
                }
            }
        }

        // Do we have a limit?
        if (isset($decodedJSON['limit'])) {
            // Is the limit numeric?
            if (is_numeric($decodedJSON['limit'])) {
                // Append the LIMIT {value} to our SQL Command
                $SQLcommand .= sprintf(" LIMIT %s", $decodedJSON['limit']);
            }
        }

        // And add a termination.
        $SQLcommand .= ";";

        // Transfer everything to JSON!
        return json_encode(
            // Execute our command, with our parameters
            $this->queryWithParameters(
                // SQL Command
                $SQLcommand,

                // Our bindings
                $bindings
            )
        );
    }

    /**
     * Function for SQL to calculate distance between 2 coordination points
     *
     * @since 1.0
     * @internal
     * @param int $lat1 Latitude 1
     * @param int $lon1 Longitude 1
     * @param int $lat2 Latitude 2
     * @param int $lon2 Longitude 2
     * @return int Distance in kilometers
     */
    public function sqlDistanceFunction($lat1 = 0, $lon1 = 0, $lat2 = 0, $lon2 = 0)
    {
        // convert lat1 into radian
        $lat1rad = deg2rad($lat1);

        // convert lat2 into radian
        $lat2rad = deg2rad($lat2);

        // apply the spherical law of cosines to our latitudes and longitudes,
        // and set the result appropriately
        // 6378.1 is the approximate radius of the earth in kilometres
        return acos(
            sin($lat1rad) * sin($lat2rad) +
            cos($lat1rad) * cos($lat2rad) * cos(deg2rad($lon2) - deg2rad($lon1))
        ) * 6378.1;
    }

    /**
     * Create the Database Admin Web Interface
     *
     * @since 1.0
     * @param string $task Task to execute.
     * @return string Database Admin Webinterface
     */
    private function DBAdmin($task = "index")
    {
        // Rewrite header to text/html utf8
        header("Content-type: text/html; charset=ut8");

        // Get minified layout
        $adminTemplate = file_get_contents("Data/layout.html");

        // Replace title
        $adminTemplate = preg_replace(
            // Replace {%Title%}
            "/{%Title%}/",

            // With
            $task,

            // In admin template
            $adminTemplate
        );

        // Checks if admin is logged in
        if ($this->isAdmin) {
            // Admin is logged in

            // Replace {%inOut%} to out (Logout)
            $adminTemplate = preg_replace(
                // Replace {%inOut%}
                "/{%inOut%}/",

                // With
                "out",

                // In admin template
                $adminTemplate
            );
        } else {
            // Admin is not logged in

            // Replace {%inOut%} to in (Login)
            $adminTemplate = preg_replace(
                // Replace {%inOut%}
                "/{%inOut%}/",

                // With
                "in",

                // In admin template
                $adminTemplate
            );

            // Hide administration links
            $adminTemplate = preg_replace(
                // Replace {%USER_LOGGEDIN%}
                "/{%USER_LOGGEDIN%}(?s).*{%END_USER_LOGGEDIN%}/mi",

                // With
                "",

                // In admin template
                $adminTemplate
            );
        }

        // Replace BaaS_Version
        $adminTemplate = preg_replace(
            // Replace {%BaaS_Version%}
            "/{%BaaS_Version%}/",

            // With
            $this->version,

            // In admin template
            $adminTemplate
        );

        // Replace BaaS_Build
        $adminTemplate = preg_replace(
            // Replace {%BaaS_Build%}
            "/{%BaaS_Build%}/",

            // With
            $this->build,

            // In admin template
            $adminTemplate
        );

        // Replace BaaS_API_Version
        $adminTemplate = preg_replace(
            // Replace {%BaaS_API_Version%}
            "/{%BaaS_API_Version%}/",

            // With
            $this->APIVer,

            // In admin template
            $adminTemplate
        );

        // create a search array
        $search = array(
            // strip whitespaces after tags, except space
            '/\>[^\S ]+/s',

            // strip whitespaces before tags, except space
            '/[^\S ]+\</s',

            // shorten multiple whitespace sequences
            '/(\s)+/s',

            // Remove HTML comments
            '/<!--(.|\s)*?-->/',

            // Remove all spaces after and before elements
            '/\s?(,|:|;|>|}|{|>|<)\s?/',
        );

        // create a replace array
        $replace = array(
            // strip whitespaces after tags, except space
            '>',
            // strip whitespaces before tags, except space
            '<',
            // shorten multiple whitespace sequences
            '\\1',
            // Remove HTML comments
            '',
            // Remove all spaces after and before elements
            '\\1',
        );

        // Minify template and return.
        $adminTemplate = preg_replace(
            // the search array
            $search,

            // the replace array
            $replace,

            // In admin template
            $adminTemplate
        );

        // Replace Contents
        $adminTemplate = preg_replace(
            // Replace {%Contents%}
            "/{%Contents%}/",

            // With...
            "Welcome Database Admin ($task).",

            // In admin template
            $adminTemplate
        );

        // Return admin template
        return $adminTemplate;
    }

    /**
     * Is the current user a admin?
     *
     * @since 1.0
     * @param bool $destroy Destroy session?
     * @return bool Logged in state
     */
    private function isLoggedInAsAdmin($destroy = false)
    {
        // Start session, if not already started
        session_start();

        // Need to destroy?
        if ($destroy) {
            // Check if a login token exists
            if (isset($_SESSION['adminUserLoggedToken'])) {
                // Destroy it.
                unset($_SESSION['adminUserLoggedToken']);
            }

            // Destroy session
            session_destroy();
        }

        // Check if a login token exists
        if (isset($_SESSION['adminUserLoggedToken'])) {
            // Check if the token isn't empty
            if (!empty($_SESSION['adminUserLoggedToken'])) {
                // user is Logged in
                return true;
            }
        }

        // Not logged in
        return false;
    }

    /**
     * SQL Query with parameters
     *
     * @since 1.0
     * @param string $query Query text
     * @param array|string $parameters Query parameters
     * @return bool Query executed
     */
    private function queryWithParameters($query, $parameters)
    {
        // Get the table from the SQL Query.
        $table = $this->tableFromSQLString($query);

        // Check if table exists...
        if (!$this->tableExists($table)) {
            return array(
                // Send Status
                "Status" => "Failed",

                // Send error
                "Error" => sprintf(
                    "Table \"%s\" does not exists",
                    $table
                ),

                // Send table
                "Table" => $table,

                // Send request uri
                "ReqURI" => $_SERVER['REQUEST_URI'],
            );
        }

        // If the database type is SQLite then
        if ($this->dbConfig['type'] == "sqlite") {
            // Append our custom function
            $this->db->sqliteCreateFunction(
                // Distance
                'DISTANCE',

                // Distance calculation function
                'BaaS\Server::sqlDistanceFunction',

                // Custom function expect 4 parameters
                4
            );
        }

        try {
            /**
             * Prepared statement
             * @var $stmt callable SQL Statement
             */
            $stmt = $this->db->prepare($query);
        } catch (PDOException $e) {
            // Handle the exception
            return $this->handleException($e);
        }

        /**
         * Walk trough parameters
         */
        foreach ($parameters as $bindKey => $bindValue) {
            /**
             * Bind values
             */
            $stmt->bindValue(
                // :key
                $bindKey,

                // value
                $bindValue,

                // Type (Only text supported right now)
                ($this->dbConfig['type'] == "sqlite" ? SQLITE3_TEXT : \PDO::PARAM_STR)
            );
        }

        try {
            /**
             * Executed statement
             * @var $stmt callable SQL Statement
             */
            $stmt->execute();
        } catch (PDOException $e) {
            // Handle the exception
            return $this->handleException($e);
        }

        /**
         * fetched content
         * @var [string]
         */
        $fechedData = $stmt->fetchAll();

        /**
         * data check, If less then 1
         * then skip.
         */
        if (sizeof($fechedData) > 1) {
            /**
             * We've got values
             */
            return $fechedData;
        }

        /**
         * Didn't got values
         * Retry in another way
         */

        /**
         * Query
         * @var string
         */
        $newQuery = $query;

        /**
         * Parameter values
         * @var array
         */
        $values = array();

        /**
         * Walk trough parameters
         */
        foreach ($parameters as $bindKey => $bindValue) {
            /**
             * Replace parameter bindings :parameter to ?
             * @var string
             */
            $newQuery = preg_replace(
                // :bindKey
                '/:' . $bindKey . '/',

                // to ?
                '?',

                // In new Query
                $newQuery,

                // one time
                1,

                // Count
                $count
            );

            /**
             * Append parameter values!
             */
            $values[] = $bindValue;
        }

        /**
         * Prepare for the second time
         * @var [type]
         */
        try {
            $new = $this->db->prepare($newQuery);
        } catch (PDOException $e) {
            // Handle the exception
            return $this->handleException($e);
        }

        /**
         * Execute with parameter values
         */
        $new->execute($values);

        /**
         * Fetch contents
         * @var [string]
         */
        $fechedData = $new->fetch(\PDO::FETCH_BOTH);

        /**
         * data check, If less then 1
         * then skip.
         */
        if (sizeof($fechedData) > 1) {
            /**
             * We've got values
             * hack it togheter.
             */
            return array(
                0 => $fechedData,
            );
        }

        /**
         * Failed, or no data found.
         */
        return false;
    }

    /**
     * Fix for Travis CI
     * @return array empty.
     */
    public function __sleep()
    {
        /* FIX TRAVIS */
        return array();
    }

    /**
     * Fix for Travis CI
     * @return void
     */
    public function __wakeup()
    {
        // If there is defined a DATABASE_TYPE
        if (!empty($this->dbConfig['type'])) {
            // If it is SQLite and there is a $this->dbConfig['path']
            if ($this->dbConfig['type'] == "sqlite" &&
                !empty($this->dbConfig['path'])) {
                try {
                    // Try to create/load a SQLite database
                    $this->db = new \PDO(
                        // sqlite:DBName.sqlite
                        sprintf(
                            // sqlite:DBName.sqlite
                            'sqlite:%s',

                            // Database Path
                            $this->dbConfig['path']
                        )
                    );

                    // Set the error mode
                    $this->db->setAttribute(
                        // Set the error mode
                        \PDO::ATTR_ERRMODE,

                        // To Trow Exceptions.
                        \PDO::ERRMODE_EXCEPTION
                    );
                } catch (PDOException $e) {
                    // Handle the exception
                    return $this->handleException($e);
                }
            }
        }
    }

    /**
     * Insert row
     *
     * @parameter string $tableName the table name
     * @parameter bool $asJSON as JSON string?
     * @return array|string Fieldnames
     */
    private function rowInsert($action)
    {
        // row.insert
        // Check if the table exists
        if (!$this->tableExists($action)) {
            // Return a error, it does not exists.
            return array(
                // Send Status
                "Status" => "Failed",

                // Table ... does not exists
                "Error" => sprintf(
                    "Table \"%s\" does not exists",
                    $table
                ),

                // Table
                "Table" => $table,

                // Request
                "ReqURI" => $_SERVER['REQUEST_URI'],
            );
        }

        // Check if we got some data
        if (!isset($_POST['JSON'])) {
            // Return a error
            return array(
                // Send Status
                "Status" => "Failed",

                // No JSON
                "Error" => "Please post JSON",

                // No JSON
                "Fix" => "Post JSON",
            );
        }

        /**
         * @var mixed JSON Data
         */
        $decodedJSON = json_decode($_POST['JSON'], true);

        // Check if we have undecoded the JSON
        if (!is_array($decodedJSON) || sizeof($decodedJSON) < 1) {
            // Could not decode
            return array(
                // Send Status
                "Status" => "Failed",

                // Error message
                "Error" => "Please post valid JSON",

                // Fix
                "Fix" => "Failed to decode JSON",
            );
        }

        // Insert info ..
        $SQLcommand = sprintf(
            "INSERT INTO `%s` (",
            // Escape the database
            $this->escapeString(
                // Replace insecure fields
                preg_replace(
                    // `
                    "/`/",

                    // to \\`
                    "\\`",

                    // in $databaseName
                    $action
                )
            )
        );

        // Create empty string for values
        $SQLValues = "";

        // Get the current table fields / columns
        $tableFields = $this->getTableFields($action);

        // Comparing fields.
        for ($i = 0; $i < sizeof($tableFields); $i++) {
            // If not exists field, and may not be ignored
            if (!isset($decodedJSON['values'][$tableFields[$i]]) &&
                !in_array($tableFields[$i], $this->defaultFields)) {
                // Return the error
                return json_encode(
                    array(
                        // Send Status
                        "Status" => "Failed",

                        // Send error message
                        "Error" => "Missing required parameter",

                        // Send missing parameter
                        "Parameter" => $tableFields[$i],

                        // Send how to fix
                        "Fix" => sprintf(
                            "Provide parameter \"%s\".",
                            $tableFields[$i]
                        ),
                    )
                );
            } else {
                // Check if field is not ID
                if ($tableFields[$i] != 'id') {
                    // Append to SQL command string
                    $SQLcommand .= sprintf(
                        "`%s`, ",
                        $tableFields[$i]
                    );

                    // Append to value string
                    $SQLValues .= sprintf(
                        "'%s', ",
                        $this->escapeString(
                            preg_replace(
                                // Replace '
                                "/'/",

                                // With \'
                                "\\'",

                                // In JSONData[values][field]
                                $decodedJSON['values'][$tableFields[$i]]
                            )
                        )
                    );
                }
            }
        }

        // INSERT INTO ... (....) VALUES (....);
        $SQLcommand = sprintf(
            // Create the string
            "%s) VALUES (%s);",

            // Remove the extra ", " (2 characters) so 0, -2
            substr($SQLcommand, 0, -2),

            // Remove the extra ", " (2 characters) so 0, -2
            substr($SQLValues, 0, -2)
        );

        // Run the query
        $action = $this->db->query($SQLcommand);

        // Get the row ID
        $insertID = $this->db->lastInsertId();

        // Check if insertion passed
        if ($action) {
            // Return
            return json_encode(
                array(
                    // Send Status
                    "Status" => "Success",

                    // Send info
                    "Info" => "Row inserted",

                    // Send RowID
                    "RowID" => $insertID,
                )
            );
        }

        // Failed...
        return json_encode(
            array(
                // Send Status
                "Status" => "Failed",

                // Send Error message
                "Error" => "Could not insert row",

                // Send how-to-fix
                "Fix" => "Please try again later",

                // Append debug fields (if debugmode is true)
                "Debug" => ($this->debugmode ? $SQLcommand : 'Off'),
            )
        );
    }

    /**
     * Get table fields (columns)
     *
     * @parameter string $tableName the table name
     * @parameter bool $asJSON as JSON string?
     * @return array|string Fieldnames
     */
    private function getTableFields($tableName, $asJSON = false)
    {
        // Create a empty array
        $fields = array();

        // our SQL query
        $query = sprintf(
            // Query
            "SHOW columns from `%s`;",

            // Replace %s with tableName
            $this->escapeString(
                // Escape `
                preg_replace(
                    // Replace `
                    "/`/",

                    // With \`
                    "\\`",

                    // in
                    $tableName)

            )
        );

        // Run query.
        $rawFields = $this->db->query($query)->fetchAll();

        // Walk trough the values
        for ($i = 0; $i < sizeof($rawFields); $i++) {
            // Append value to fields
            $fields[] = $rawFields[$i][0];
        }

        // Return the fields as json or array
        return $asJSON ? json_encode($fields) : $fields;
    }

    /**
     * Creates a Shared Instance
     *
     * @return callable Instance
     */
    public static function shared()
    {
        /**
         * @var mixed
         */
        static $inst = null;

        if ($inst === null) {
            // Create the instance
            $inst = new \BaaS\Server();
        }

        // Return our instance
        return $inst;
    }

    /**
     * Construct the class.
     *
     * @since 1.0
     */
    public function __construct()
    {
        // Get the HTTP Protocol
        $this->protocol = (
            isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'HTTP/1.1'
        );

        // Create a temporary array
        $checkWritePermissions = explode("/", $this->BFfile);

        // Create a empty string
        $this->blockFilePath = "";

        // Loop trough the temporary array -1
        for ($i = 0; $i < (sizeof($checkWritePermissions) - 1); $i++) {
            // Append to the this->blockFilePath.
            $this->blockFilePath .= sprintf("%s/", $checkWritePermissions[$i]);
        }

        // If there is a / in the begin, place it back.
        if (substr($this->BFfile, 0, 1) == "/") {
            // Append / in the beginning, and overwrite path
            $this->blockFilePath = sprintf("/%s", $blockFilePath);
        }

        // X-Powered-By: BaaS/version
        // Overwrite PHP
        header(
            sprintf(
                "X-Powered-By: BaaS/%s (https://github.com/wdg/BaaS)",

                // API Version
                $this->APIVer
            )
        );

        // Set the content type
        header("Content-type: application/json; charset=UTF-8");

        // Do not sniff (change) our content type ever
        header("X-Content-Type-Options: nosniff");

        // Protect XSS
        header("X-XSS-Protection: 1; mode=block");

        // Disable prefetch
        header("X-DNS-Prefetch-Control: off");

        // Don't give our referer ever
        header("Referrer-Policy: no-referrer");

        // Expire page after 10 seconds.
        header(
            sprintf(
                // Expire after %s
                "Expires: %s",

                // %s = current time + 10 seconds
                gmdate('D, d M Y H:i:s \G\M\T', time() + 10)
            )
        );

        // Disable caching
        header("Cache-Control: no-cache");

        // Close the connection immediately
        header("Connection: close");

        // Set the "Block" file
        $this->BFfile = sprintf(
            // Block file
            $this->BFfile,

            // Replace %s with current IP-Address
            $_SERVER['REMOTE_ADDR']
        );

        // Checks isAdmin state
        $this->isAdmin = $this->isLoggedInAsAdmin();
    }

    /**
     * Is the server available?
     *
     * @since 1.0
     * @param string $serverAddr Server address
     * @return mixed|string Offline/Online
     */
    private function isTheServerAvailable($serverAddr)
    {
        // Connect to the MySQL Server
        $fp = fsockopen($serverAddr, 3306, $errno, $errstr);

        // Return offline, or online
        return (!$fp ? 'Offline' : 'Online');
    }

    /**
     * Deal with exceptions.
     *
     * @since 1.0
     * @param callable $exception throwed exception
     * @return mixed|string JSON String with error (if available)
     */
    private function handleException($exception)
    {
        // This is a PDO Exception
        if ($exception instanceof PDOException) {
            // Return the error in JSON
            return json_encode(
                array(
                    // Send Status
                    "Status" => "Failed",

                    // Show error message
                    "Error" => "PDOException happend!",

                    // Show the exception
                    "Exception" => $exception->getMessage(),
                )
            );
        }

        // This is a Normal Exception
        if ($exception instanceof Exception) {
            // Return the error in JSON
            return json_encode(
                array(
                    // Send Status
                    "Status" => "Failed",

                    // Show error message
                    "Error" => "Exception happend!",

                    // Show the exception
                    "Exception" => $exception->getMessage(),
                )
            );
        }

        // This is Exceptional...
        return json_encode(
            // Return the error in JSON
            array(
                // Send Status
                "Status" => "Failed",

                // Show error message
                "Error" => "Uncought exception!",

                // Show the exceptional message
                "Exception" => $exception,
            )
        );
    }

    /**
     * Set the HTTP Status Code
     *
     * @since 1.0
     * @param int $code HTTP Status Code
     */
    private function set_http_code($code = 200)
    {
        switch ($code) {
            case 100:
                $text = 'Continue';
                break;
            case 101:
                $text = 'Switching Protocols';
                break;
            case 200:
                $text = 'OK';
                break;
            case 201:
                $text = 'Created';
                break;
            case 202:
                $text = 'Accepted';
                break;
            case 203:
                $text = 'Non-Authoritative Information';
                break;
            case 204:
                $text = 'No Content';
                break;
            case 205:
                $text = 'Reset Content';
                break;
            case 206:
                $text = 'Partial Content';
                break;
            case 300:
                $text = 'Multiple Choices';
                break;
            case 301:
                $text = 'Moved Permanently';
                break;
            case 302:
                $text = 'Moved Temporarily';
                break;
            case 303:
                $text = 'See Other';
                break;
            case 304:
                $text = 'Not Modified';
                break;
            case 305:
                $text = 'Use Proxy';
                break;
            case 400:
                $text = 'Bad Request';
                break;
            case 401:
                $text = 'Unauthorized';
                break;
            case 402:
                $text = 'Payment Required';
                break;
            case 403:
                $text = 'Forbidden';
                break;
            case 404:
                $text = 'Not Found';
                break;
            case 405:
                $text = 'Method Not Allowed';
                break;
            case 406:
                $text = 'Not Acceptable';
                break;
            case 407:
                $text = 'Proxy Authentication Required';
                break;
            case 408:
                $text = 'Request Time-out';
                break;
            case 409:
                $text = 'Conflict';
                break;
            case 410:
                $text = 'Gone';
                break;
            case 411:
                $text = 'Length Required';
                break;
            case 412:
                $text = 'Precondition Failed';
                break;
            case 413:
                $text = 'Request Entity Too Large';
                break;
            case 414:
                $text = 'Request-URI Too Large';
                break;
            case 415:
                $text = 'Unsupported Media Type';
                break;
            case 500:
                $text = 'Internal Server Error';
                break;
            case 501:
                $text = 'Not Implemented';
                break;
            case 502:
                $text = 'Bad Gateway';
                break;
            case 503:
                $text = 'Service Unavailable';
                break;
            case 504:
                $text = 'Gateway Time-out';
                break;
            case 505:
                $text = 'HTTP Version not supported';
                break;
            default:
                $code = 200;
                $text = 'OK';
                break;
        }

        // set response code
        if (function_exists('http_response_code')) {
            // set response code
            http_response_code($code);
        } else {
            // set response code
            // Fallback for older servers.
            header(
                // PROTOCOL CODE TEXT
                "%s %s %s",

                // Protocol
                $this->protocol,

                // HTTP-Code
                $code,

                // HTTP-Text
                $text
            );
        }
    }
}
