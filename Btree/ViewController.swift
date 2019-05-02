//
//  ViewController.swift
//  braintree
//
//  Created by Dragon on 2019/4/10.
//  Copyright © 2019 Dragon. All rights reserved.
//

// this is main view controller to handle payment

import UIKit
import BraintreeDropIn
import Braintree

class ViewController: UIViewController {

    var braintreeClient : BTAPIClient!
    var request : BTDropInRequest!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.request =  BTDropInRequest()                                               // create Braintree request
        self.request.applePayDisabled = false                                           // set applepay enabled
        self.request.cardDisabled = false                                               // set card pay enabled
        self.request.paypalDisabled = false                                             // set paypal pay enabled
        self.request.amount = "200"                                                     // set pay amount as 10
    }
    @IBAction func onPurchase(_ sender: Any) {                                          // call generate_client_token.php backend service to get client token
        Utils.sendRequest("generate_client_token.php", .get, [:]) { (res, data) in      // got result from generate_client_token from backend
        if res {                                                                        // if it is succeed...
                let clientToken = data as! String                                       // convert token to string
                
                let dropIn = BTDropInController(authorization: clientToken, request: self.request)  // define drop in dialog
                { (controller, result, error) in                                        // get result from Braintree
                    if (error != nil) {                                                 // if it was failed
                        print(error)                                                    // print error
                        Utils.showToast(self.view, (error?.localizedDescription)!)      // show toast error
                    } else if (result?.isCancelled == true) {
                        Utils.showToast(self.view, Utils.str_cancel)                    // show toast if user cancels payment processing
                    } else if let result = result {                                     // proceed payment
                        
                        
                        
                        switch result.paymentOptionType {
                        case .applePay ,.payPal,.masterCard,.discover,.visa:
                            // Here Result success  check paymentMethod not nil if nil then user select applePay
                            if result.paymentMethod != nil{
                                controller.dismiss(animated: true, completion: nil)         // dismiss dropin dialog
                                //paymentMethod.nonce  You can use  nonce now
                                let nonce = result.paymentMethod?.nonce                     // catch nonce from result, nonce will be used to checkout in backend service - checkout.php
                                Utils.sendRequest("checkout.php", .post, ["paymentnonce":nonce!, "amount":200]) { (res, data) in
                                    // call checkout.php with nonce, amount to proceed checkout
                                    let result = data as? String ?? Utils.str_err_server    // get result from checkout.php backend
                                    Utils.showToast(self.view, result)                      // show result message as toast
                                }
                            }else{
                                
                                controller.dismiss(animated: true, completion: nil)             // dismiss dropin dialog
                                self.braintreeClient = BTAPIClient(authorization: clientToken)
                                
                                // call apple pay
                                let paymentRequest = self.paymentRequest()
                                
                                // Example: Promote PKPaymentAuthorizationViewController to optional so that we can verify
                                // that our paymentRequest is valid. Otherwise, an invalid paymentRequest would crash our app.
                                
                                if let vc = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                                    as PKPaymentAuthorizationViewController?
                                {
                                    vc.delegate = self
                                    self.present(vc, animated: true, completion: nil)
                                } else {
                                    Utils.showToast(self.view, "Payment request is invalid")
                                }
                                
                            }
                        default:
                            Utils.showToast(self.view, data as? String ?? Utils.str_err_server)
                        }
                    }
                }
                self.present(dropIn!, animated: true, completion: nil)              // show dropin dialog
            } else {
                Utils.showToast(self.view, data as? String ?? Utils.str_err_server) // show error toast if it was filaed to generate client token
            }
        }
    }
    
}

extension ViewController : PKPaymentAuthorizationViewControllerDelegate{
    
    func paymentRequest() -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "merchant.topstar.braintree";
        paymentRequest.supportedNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.visa, PKPaymentNetwork.masterCard];
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS;
        paymentRequest.countryCode = "GB"; // e.g. US
        paymentRequest.currencyCode = "GBP"; // e.g. USD
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Cristiano Ronaldo Shoes", amount: 200),
        ]
        return paymentRequest
    }
    
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Swift.Void){
        
        // Example: Tokenize the Apple Pay payment
        let applePayClient = BTApplePayClient(apiClient: braintreeClient!)
        applePayClient.tokenizeApplePay(payment) {
            (tokenizedApplePayPayment, error) in
            guard let tokenizedApplePayPayment = tokenizedApplePayPayment else {
                // Tokenization failed. Check `error` for the cause of the failure.
                
                // Indicate failure via completion callback.
                completion(PKPaymentAuthorizationStatus.failure)
                
                return
            }
            
            // Received a tokenized Apple Pay payment from Braintree.
            // If applicable, address information is accessible in `payment`.
            
            // Send the nonce to your server for processing.
            print("nonce = \(tokenizedApplePayPayment.nonce)")
            
            //  self.postNonceToServer(paymentMethodNonce: tokenizedApplePayPayment.nonce)
            // Then indicate success or failure via the completion callback, e.g.
            completion(PKPaymentAuthorizationStatus.success)
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
