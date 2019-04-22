//
//  ViewController.swift
//  braintree
//
//  Created by Dragon on 2019/4/10.
//  Copyright © 2019 Dragon. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func onPurchase(_ sender: Any) {
        Utils.sendRequest("generate_client_token.php", .get, [:]) { (res, data) in
            if res {
                let clientToken = data as! String
                let request =  BTDropInRequest()
                request.applePayDisabled = false
                request.cardDisabled = false
                request.paypalDisabled = false
                request.amount = "10"
                
                let dropIn = BTDropInController(authorization: clientToken, request: request)
                { (controller, result, error) in
                    if (error != nil) {
                        print(error)
                        Utils.showToast(self.view, (error?.localizedDescription)!)
                    } else if (result?.isCancelled == true) {
                        Utils.showToast(self.view, Utils.str_cancel)
                    } else if let result = result {
                        let nonce = result.paymentMethod?.nonce
                        Utils.sendRequest("checkout.php", .post, ["paymentnonce":nonce!, "amount":200]) { (res, data) in
                            let result = data as? String ?? Utils.str_err_server
                            Utils.showToast(self.view, result)
                        }
                        
                    }
                    controller.dismiss(animated: true, completion: nil)
                }
                self.present(dropIn!, animated: true, completion: nil)
            } else {
                Utils.showToast(self.view, data as? String ?? Utils.str_err_server)
            }
        }
    }
    
}

