<?php 
require_once 'lib/Braintree.php';

$payment_nonce = $_POST["paymentnonce"];  // get nonce from app frontend
$amount = $_POST["amount"];     // get payable amount from app frontend

$gateway = new Braintree_Gateway([
    'environment' => "sandbox",
    'merchantId' => "6wfmsd37m4zy4j4s",
    'publicKey' => "29czh5n8z3p3pwc6",
    'privateKey' => "3f609c7a20d21024fab3f94e7ce12dab"
]);     // create Braintree gateway with your Braintree settings, this is sandbox environment

$result = $gateway->transaction()->sale([
    'amount' => $amount,
    'paymentMethodNonce' => $payment_nonce,
    'options' => [
        'submitForSettlement' => True
    ]
]);         // call transaction -> sale function to checkout with this amount, nonce



if ($result->success) {
	echo json_encode(array("result" => true, "data" => "Payment is successful"));  // return success message if payment was successful
} else {
    $retresponseText = $result->transaction->processorResponseText;
	echo json_encode(array("result" => false, "data" => $retresponseText));        // return error message if payment was failed

}