<?php 
require_once 'lib/Braintree.php';  // import Braintree PHP library


$gateway = new Braintree_Gateway([
    'environment' => "sandbox",
    'merchantId' => "6wfmsd37m4zy4j4s",
    'publicKey' => "29czh5n8z3p3pwc6",
    'privateKey' => "3f609c7a20d21024fab3f94e7ce12dab"
]);			// create braintree gateway with your Bt setting credentials.


$clientToken = $gateway->clientToken()->generate();		// generate client token with clientToken -> generate  function.
if ($clientToken) {				
    $result = array('result' => true, 'data' => $clientToken);
    echo json_encode($result);		// if client token was generated successfully, return token to app to generate nonce for payment
} else {
    $result = array('result' => false, 'data' => "Failed to fetch client token");   // if client token was not generated, return error message to app with json.
    echo json_encode($result);
}