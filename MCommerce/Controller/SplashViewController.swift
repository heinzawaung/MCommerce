//
//  SplashViewController.swift
//  MCommerce
//
//  Created by Hein Zaw on 10/23/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let isLogin = UserDefaults.standard.value(forKey: "isLogin") as? Bool
        
        if let isLogin = isLogin, isLogin == true {
            let email = UserDefaults.standard.value(forKey: "email") as! String
            let password = UserDefaults.standard.value(forKey: "password") as! String
            
            MCApi.sharedInstance().authenticate(email: email, password: password){
                status, errorMessage in
                
            }
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
            self.present(vc, animated: true, completion: nil)
            
        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginNaviViewController") as!        UINavigationController
            self.present(vc, animated: true, completion: nil)
            
        }
    }


}
