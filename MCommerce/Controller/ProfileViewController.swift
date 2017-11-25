//
//  ProfileViewController.swift
//  MCommerce
//
//  Created by Hein Zaw on 9/27/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//


import UIKit
import RealmSwift

class ProfileViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    
    @IBAction func signOut(_ sender: Any) {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "splash") as! SplashViewController
        
        self.dismiss(animated: true, completion: nil)
        //present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "order_cell")
        return cell!
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        MCApi.sharedInstance().loadOrderList(){
            success , catelist in
            
        }
        
    }

   

}
