<?php
/**
 * Set the namespace to 'BaaS'
 */
namespace BaaS;

/**
 * Class 'BaaS_Server'
 * Backend as a Service Server
 *
 * @version 1.0
 * @copyright Wesley de Groot
 * @package BaaS
 */
class Server
{
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
     * Set API Version
     *
     * @since 1.0
     * @var string $APIVer API Version
     */
    private $APIVer = "1.0";

    /**
     * is current user an Admin?
     *
     * @since 1.0
     * @var bool $isAdmin is it a admin
     */
    private $isAdmin = false;

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
     * Database Configuration
     *
     * @since 1.0
     * @var mixed database configuration
     */
    private $database = array(
        'path' => 'Data/database.sqlite',
        'type' => '',
        'name' => '',
        'user' => '',
        'pass' => '',
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
                $this->database['type'] = 'sqlite';

                // If host/path name is not empty
                if (!empty($hostOrPath)) {
                    // Check if the path is writeable
                    if (is_writable($hostOrPath)) {
                        // Set the path
                        $this->database['path'] = $hostOrPath;
                    } else {
                        // Error
                        $this->error = true;
                        // Path is not writeable
                        $this->errorMessage = "Path is not writeable";
                    }
                }
                break;

            case 'mysql':
                // Set database type to MySQL
                $this->database['type'] = 'mysql';

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
                    $this->database['host'] = $hostOrPath;
                }

                // If not empty
                if (!empty($databaseName)) {
                    // Set the database name
                    $this->database['name'] = $databaseName;
                }

                // If not empty
                if (!empty($username)) {
                    // Set the database username
                    $this->database['user'] = $username;
                }

                // Set the database password
                $this->database['pass'] = $password;
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
                        // Send new headers.
                        if (function_exists('http_response_code')) {
                            // Set header to forbidden
                            http_response_code(403);
                        } else {
                            // Fallback for older servers.
                            header("HTTP/1.0 403 Forbidden");
                        }

                        // Say wrong APIKey
                        header("API-Key: Invalid");

                        // blocked.
                        echo (
                            json_encode(
                                array(
                                    'Warning' => sprintf(
                                        "You are blocked from using this service."
                                    ),
                                    'DETAILS' => sprintf(
                                        "BaaS/%s, Connection: Close, IP-Address: %s",
                                        $this->APIVer, $_SERVER['REMOTE_ADDR']
                                    ),
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
                        exit(0);

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
        if (function_exists('http_response_code')) {
            // Set header to forbidden
            http_response_code(403);
        } else {
            // Fallback for older servers.
            header("HTTP/1.0 403 Forbidden");
        }

        // Say wrong APIKey
        header("API-Key: Invalid");

        echo (
            json_encode(
                array(
                    'WARNING' => sprintf(
                        "You are using an invalid API key for this service."
                    ),
                    'DETAILS' => sprintf(
                        "BaaS/%s, Connection: Close, IP-Address: %s",
                        $this->APIVer, $_SERVER['REMOTE_ADDR']
                    ),
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
        exit(0);

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
            "/(FROM|INTO|FROM|TABLE) (`)?([a-zA-Z0-9]+)(`)?/i",
            $SQLString,
            $match
        );
        // ^ Probally not the best Regex... it works fine.

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
                            preg_replace("/`/", "\\`", $tableName)
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
                        preg_replace("/`/", "\\`", $tableName)
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
        // Check if there is a DATABASE_TYPE defined.
        if ($this->error) {
            return json_encode(
                array(
                    // Database type is missing
                    "Error" => !empty($this->errorMessage)
                    ? $this->errorMessage
                    : "No database type is selected",
                    // Show a fix
                    "Fix" => "Check the documentation!",
                )
            );
        }

        if ($this->dbConfig['type'] == "mysql") {
            // Check if there is a $this->dbConfig['host'] defined.
            if (!empty($this->dbConfig['host'])) {
                // Missing, so return a error.
                return json_encode(
                    array(
                        // Database host is missing
                        "Error" => "No database host is entered",
                        // Show a fix
                        "Fix" => "Please select a valid database host",
                    )
                );
            }
            // Check if there is a $this->dbConfig['name'] defined.
            if (!empty($this->dbConfig['name'])) {
                // Missing, so return a error.
                return json_encode(
                    array(
                        // Database name is missing
                        "Error" => "No database name is entered",
                        // Show a fix
                        "Fix" => "Please select a valid database name",
                    )
                );
            }
            // Check if there is a $this->dbConfig['user'] defined.
            if (!empty($this->dbConfig['user'])) {
                // Missing, so return a error.
                return json_encode(
                    array(
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
                    // File path is not writeable
                    "Error" => "File path is not writeable",
                    // Show file path
                    "FilePath" => $this->blockFilePath,
                )
            );
        }

        // Reset old attempts
        $this->resetOldAttempts();

        if (preg_match_all("/db\.admin(\/?)(.*)/", $_SERVER['REQUEST_URI'], $action)) {
            // Run "DBAdmin"
            return $this->DBAdmin(
                // If no action then show index
                empty($action[2][0]) ? 'index' : $action[2][0]
            );
        }

        // No admin action, so we'll need to check the API KEY
        $this->checkAPIKey();

        // Handle /row.get/xxx methods
        if (preg_match_all("/row\.get(\/?)(.*)/", $_SERVER['REQUEST_URI'], $action)) {
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
        if (preg_match_all("/row\.set(\/?)(.*)/", $_SERVER['REQUEST_URI'], $action)) {
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
        if (preg_match_all("/row\.delete(\/?)(.*)/", $_SERVER['REQUEST_URI'], $action)) {
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
        if (preg_match_all("/row\.insert(\/?)(.*)/", $_SERVER['REQUEST_URI'], $action)) {
            // If /row.insert/MAYNOTBEEMPTY is nog empty
            if (!empty($action[2][0])) {
                // Parse and echo
                return $this->rowInsert(
                    // With value xxx
                    $action[2][0]
                );
            }
        }
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

        if (!is_array($decodedJSON) ||
            sizeof($decodedJSON) < 1) {
            return array(
                "Error" => "Please post JSON",
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
            case 'get':
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
            case 'set':
                // Check if we have values
                if (!isset($decodedJSON['values'])) {
                    // Return error message
                    return json_encode(
                        array(
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
                        // Invalid request
                        "Error" => "Invalid request",
                        // Invalid action
                        "Request" => $action,
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
                            preg_replace("/`/", "\\`", $firstParameter),
                            $paramID
                        );

                        // Append paramID with value to our array
                        $bindings[$paramID] = $decodedJSON['values'][$i][1];
                    } else {
                        // Show error
                        return json_encode(
                            array(
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
                                    preg_replace("/`/", "\\`", $firstParameter),
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
                                    preg_replace("/`/", "\\`", $firstParameter),
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
                                    preg_replace("/`/", "\\`", $firstParameter),
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
            "/{%Title%}/",
            $task,
            $adminTemplate
        );

        // Replace Contents
        $adminTemplate = preg_replace(
            "/{%Contents%}/",
            "Welcome Database Admin ($task).",
            $adminTemplate
        );

        // Checks if admin is logged in
        if ($this->isAdmin) {
            // Admin is logged in

            // Replace {%inOut%} to out (Logout)
            $adminTemplate = preg_replace(
                "/{%inOut%}/",
                "out",
                $adminTemplate
            );
        } else {
            // Admin is not logged in

            // Replace {%inOut%} to in (Login)
            $adminTemplate = preg_replace(
                "/{%inOut%}/",
                "in",
                $adminTemplate
            );

            // Hide administration links
            $adminTemplate = preg_replace(
                "/{%USER_LOGGEDIN%}(?s).*{%END_USER_LOGGEDIN%}/mi",
                "",
                $adminTemplate
            );
        }

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
                "Error" => sprintf(
                    "Table \"%s\" does not exists",
                    $table
                ),
                "Table" => $table,
                "Request" => $_SERVER['REQUEST_URI'],
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
                '/:' . $bindKey . '/',
                '?',
                $newQuery,
                1,
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
        if (defined('DATABASE_TYPE')) {
            // If it is SQLite and there is a $this->database['path']
            if ($this->dbConfig['type'] == "sqlite" &&
                !empty($this->database['path'])) {
                try {
                    // Try to create/load a SQLite database
                    $this->db = new \PDO(
                        // sqlite:DBName.sqlite
                        sprintf(
                            // sqlite:DBName.sqlite
                            'sqlite:%s',
                            // Database Path
                            $this->database['path']
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
        // Check if the table exists
        if (!$this->tableExists($action)) {
            // Return a error, it does not exists.
            return array(
                "Error" => sprintf(
                    "Table \"%s\" does not exists",
                    $table
                ),
                "Table" => $table,
                "Request" => $_SERVER['REQUEST_URI'],
            );
        }

        if (!isset($_POST['JSON'])) {
            return array(
                "Error" => "Please post JSON",
                "Fix" => "Post JSON",
            );
        }

        /**
         * @var mixed JSON Data
         */
        $decodedJSON = json_decode($_POST['JSON'], true);

        if (!is_array($decodedJSON) ||
            sizeof($decodedJSON) < 1) {
            return array(
                "Error" => "Please post JSON",
                "Fix" => "Failed to decode JSON",
            );
        }

        return json_encode(
            $this->getTableFields($action)
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
                preg_replace("/`/", "\\`", $tableName)
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
                "X-Powered-By: BaaS/%s%s (https://github.com/wdg/BaaS)",
                $this->APIVer,
                $this->debugmode ? ' (Debugmode)' : ''
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
            $this->BFfile,
            $_SERVER['REMOTE_ADDR']
        );

        // Checks isAdmin state
        $this->isAdmin = $this->isLoggedInAsAdmin();

        // If exists (DATABASE_TYPE)
        if (defined('DATABASE_TYPE')) {
            // Try it
            try {
                // Connect to our SQLite database
                if ($this->dbConfig['type'] == "mysql") {
                    // If defined $this->dbConfig['host'], $this->dbConfig['name'],
                    // $this->dbConfig['user'], $this->dbConfig['pass']WORD
                    if (!empty($this->dbConfig['host']) &&
                        !empty($this->dbConfig['name']) &&
                        !empty($this->dbConfig['user']) &&
                        !empty($this->dbConfig['pass'])) {
                        // Then let's try to connect!
                        $this->db = new \PDO(
                            // mysql:host=$this->dbConfig['host'];
                            // dbname=$this->dbConfig['name'];charset=UTF8
                            sprintf(
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
                    if (!empty($this->database['path'])) {
                        // Try to create/load a SQLite database
                        $this->db = new \PDO(
                            // sqlite:DBName.sqlite
                            sprintf(
                                // sqlite:DBName.sqlite
                                'sqlite:%s',
                                // Database Path
                                $this->database['path']
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
        }
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
                // Show error message
                "Error" => "Uncought exception!",
                // Show the exceptional message
                "Exception" => $exception,
            )
        );
    }
}

// define on = true
define('on', true);

// define off = false
define('off', false);

// define auto = true
define('auto', true);
