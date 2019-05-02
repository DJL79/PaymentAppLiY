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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func onPurchase(_ sender: Any) {
        // call generate_client_token.php backend service to get client token
        Utils.sendRequest("generate_client_token.php", .get, [:]) { (res, data) in
            // got result from generate_client_token from backend
        if res {                                                                // if it is succeed...
                let clientToken = data as! String                               // convert token to string
                let request =  BTDropInRequest()                                // create Braintree request
                request.applePayDisabled = false                                // set applepay enabled
                request.cardDisabled = false                                    // set card pay enabled
                request.paypalDisabled = false                                  // set paypal pay enabled
                request.amount = "10"                                           // set pay amount as 10
                
                
                let dropIn = BTDropInController(authorization: clientToken, request: request)  // define drop in dialog
                { (controller, result, error) in
                    // get result from Braintree
                    if (error != nil) {  // if it was failed
                        print(error)    // print error
                        Utils.showToast(self.view, (error?.localizedDescription)!)  // show toast error
                    } else if (result?.isCancelled == true) {
                        Utils.showToast(self.view, Utils.str_cancel)                // show toast if user cancels payment processing
                    } else if let result = result {                                 // proceed payment
                        let nonce = result.paymentMethod?.nonce                     // catch nonce from result, nonce will be used to checkout in backend service - checkout.php
                        Utils.sendRequest("checkout.php", .post, ["paymentnonce":nonce!, "amount":200]) { (res, data) in
                            // call checkout.php with nonce, amount to proceed checkout
                            let result = data as? String ?? Utils.str_err_server    // get result from checkout.php backend
                            Utils.showToast(self.view, result)                      // show result message as toast
                        }
                        
                    }
                    controller.dismiss(animated: true, completion: nil)             // dismiss dropin dialog
                }
                self.present(dropIn!, animated: true, completion: nil)              // show dropin dialog
            } else {
                Utils.showToast(self.view, data as? String ?? Utils.str_err_server) // show error toast if it was filaed to generate client token
            }
        }
    }
    
}

