<?php
$str = "// General error
var Error: String?
var Fix: String?
var Exception: String?
var ReqURI: String?

// Which table?
var Table: String?
var Data: String?
var Where: String?
var Method: String?

// Inserted row
var info: String?
var rowID: String?

// if in debug mode
var Debug: String?

// Error at IP-Blocking
var FilePath: String?
";

$f = explode(PHP_EOL, $str);
foreach ($f as $fl) {
    if (substr($fl, 0, 3) == "var") {
        $e = explode(":", $fl);
        $e = substr($e[0], 4);
        // echo sprintf("%s = try values.decodeIfPresent(String.self, forKey: .%s)%s", $e, $e, PHP_EOL);
        // echo sprintf("*     parameter %s%s", $e, PHP_EOL);
        echo sprintf("&& %s == \"N/A\" ", $e);
    }
}
