//
//  Utils.swift
//  tasaquww
//
//  Created by TopStar on 2/15/18.
//  Copyright © 2018 TopStar. All rights reserved.
//

import Foundation
import Alamofire
import NVActivityIndicatorView
import UIKit
import Toast_Swift

class Utils{
    
    // set base url to call web service
    
    static var base_url = "http://Your Local IP Address/Backend/"
    
    // strings
    
    static var str_err_server = "Something went wrong."
    static var str_cancel = "You just canceled the checkout."
    static var str_payment_success = "You payment was successful."
    
    // show progress dialog
    static var activityData = ActivityData(size: nil,message: nil,messageFont: nil,messageSpacing: nil,type: .ballRotateChase,color: UIColor.init(red: 58/255.0, green: 64/255.0, blue: 140/255.0, alpha: 0.8),padding: nil,displayTimeThreshold: nil,minimumDisplayTime: nil,backgroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0),textColor: UIColor.init(red: 58/255.0, green: 64/255.0, blue: 140/255.0, alpha: 0.8))
    static func showProgress(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(self.activityData,nil)
    }
    static func hideProgress(){
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
    
    // show toast
    static func showToast(_ view:UIView, _ string:String){
        view.makeToast(string)
    }
    
    // show alert
    static func showAlert(_ title:String, _ message:String, _ vc:UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    // send http request to server with alamofire
    static func sendRequest(_ url : String , _ method : HTTPMethod ,_ parameters:[String:Any], completion: @escaping (Bool, Any) -> Void) {
        Alamofire.request(base_url + url , method : method , parameters : parameters).validate().responseJSON { response in
            print(response.value)
            switch response.result {
            case .success:
                if let result = response.value as? [String:Any], let res = result["result"] as? Bool{
                    completion(res, result["data"] as Any)
                } else {
                    completion(false,[:])
                }
            case .failure:
                completion(false,[:])
            }
        }
    }
    
    
    // save/get value to/from Userdefault
    static func setPreference(_ key : String, _ value : String){
        UserDefaults.standard.set(value, forKey: key)
    }
    static func getPreference(_ key : String) -> String{
        if let value = UserDefaults.standard.string(forKey: key) {
            return value
        }
        return ""
    }
}
