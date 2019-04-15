<?php 
require_once 'lib/Braintree.php';


$gateway = new Braintree_Gateway([
    'environment' => "sandbox",
    'merchantId' => "6wfmsd37m4zy4j4s",
    'publicKey' => "29czh5n8z3p3pwc6",
    'privateKey' => "3f609c7a20d21024fab3f94e7ce12dab",
]);


$clientToken = $gateway->clientToken()->generate();
if ($clientToken) {
    $result = array('result' => true, 'data' => $clientToken);
    echo json_encode($result);
} else {
    $result = array('result' => false, 'data' => "Failed to fetch client token");
    echo json_encode($result);
}