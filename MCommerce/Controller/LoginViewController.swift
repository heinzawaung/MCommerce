//
//  LoginViewController.swift
//  MCommerce
//
//  Created by Hein Zaw on 10/23/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import UIKit
import PKHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
  
    @IBAction func loginAction(_ sender: Any) {
        HUD.show(.progress)
      
        MCApi.sharedInstance().authenticate(email: emailTextField.text!, password: passwordTextField.text!) {
            (success, errorMessage) in
          
            if success {
                HUD.flash(.success, delay: 1.0){
                    finished in
                    UserDefaults.standard.setValue(true, forKey: "isLogin")
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabViewController") as? MainTabViewController
                    self.present(vc!, animated: true, completion: nil)
                }
                
                
            }else{
                HUD.flash(.error, delay: 0.1){ finished in
                    self.showAlert(title: "Sorry!", message: errorMessage )
                }
                
            }
            
            
        }
    }
    
    func showAlert(title: String,message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    

}
