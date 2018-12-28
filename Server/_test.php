<?php
$g = stream_context_create(
    array(
        "ssl" => array(
            "capture_peer_cert" => true,
        ),
    )
);

$r = stream_socket_client(
    "ssl://www.google.com:443",
    $errno,
    $errstr,
    30,
    STREAM_CLIENT_CONNECT,
    $g
);

$cont = stream_context_get_params($r);
$publicCertificate = openssl_pkey_get_public($cont["options"]["ssl"]["peer_certificate"]);
$keyData = openssl_pkey_get_details($publicCertificate);
print_r($keyData);

$encoded = openssl_digest($keyData['key'], 'sha256');
print_r($encoded);

$encoded = base64_encode($encoded);
print_r($encoded);

if ($encoded != "g/x+k/qAa7HgzA1rYUH/O6U2oMODfE1Q6wETqTLcx/w=") {
    echo "FAILED" . PHP_EOL;
    echo "GOT: " . $encoded . PHP_EOL;
    echo "NEEDED: g/x+k/qAa7HgzA1rYUH/O6U2oMODfE1Q6wETqTLcx/w=" . PHP_EOL;
    exit;
}

echo "The public key is: " . $encoded . PHP_EOL;
exit;
//Base64(SHA256(SubjectPublicKeyInfo))
?>
openssl s_client -connect www.google.com:443 -showcerts < /dev/null | openssl x509 -outform DER > google.der
openssl x509 -pubkey -noout -in google.der -inform DER | openssl rsa -outform DER -pubin -in /dev/stdin 2>/dev/null > googlekey.der
python -sBc "from __future__ import print_function;import hashlib;print(hashlib.sha256(open('googlekey.der','rb').read()).digest(), end='')" | base64
