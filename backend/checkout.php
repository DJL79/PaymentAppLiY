<?php 
require_once 'lib/Braintree.php';

$payment_nonce = $_POST["paymentnonce"];
$amount = $_POST["amount"];

$gateway = new Braintree_Gateway([
    'environment' => "sandbox",
    'merchantId' => "6wfmsd37m4zy4j4s",
    'publicKey' => "29czh5n8z3p3pwc6",
    'privateKey' => "3f609c7a20d21024fab3f94e7ce12dab"
]);

$result = $gateway->transaction()->sale([
    'amount' => $amount,
    'paymentMethodNonce' => $payment_nonce,
    'options' => [
        'submitForSettlement' => True
    ]
]);


if ($result->success) {
	echo json_encode(array("result" => true, "data" => "Payment is successful"));
} else {
    $retresponseText = $result->transaction->processorResponseText;
	echo json_encode(array("result" => false, "data" => $retresponseText));

}