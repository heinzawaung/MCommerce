
//
//  HomeViewController.swift
//  MCommerce
//
//  Created by Hein Zaw on 9/26/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import UIKit
import PKHUD
import RealmSwift
import Kingfisher


class HomeViewController: UIViewController {
    
    
    var count = 0
    let realm = try! Realm()

    @IBOutlet weak var tableView: UITableView!
    
    var categories: [Category]! = []
    var subCategories: [Category]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let cats = try! realm.objects(Category.self).filter("parentId == 0")
        for c in cats {
            categories.append(c)
        }
        
        tableView.reloadData()
      
        
        
        

        HUD.show(.progress)
        MCApi.sharedInstance().loadCategoryList(){
            success,categoryList in
            
            
            HUD.hide()
            
            
            if success {
                self.categories.removeAll()
                if let categoryList = categoryList {
                    for category in categoryList {
                        self.categories.append(category)
                    }
                }
            }
            
            
            self.tableView.reloadData()
          
            
        }
    
        HUD.show(.progress)
        MCApi.sharedInstance().getLastCreatedCart(){
            success , id in
            
            HUD.hide()
            if success {
                print("cart id \(id)")
                if let id = id {
                    UserDefaults.standard.setValue(id, forKey: "cart_id")
                    MCApi.sharedInstance().getCartDetail(id: id){
                        success , itemCount in
                        if success {
                            if let tabItems = self.tabBarController?.tabBar.items as NSArray!
                            {
                                
                                if itemCount != 0 {
                                    let tabItem = tabItems[1] as! UITabBarItem
                                    tabItem.badgeValue = String(itemCount)
                                    tabItem.badgeColor = UIColor.orange
                                }
                                
                            }
                        }
                    }
                }
            }else{
                print("create empty cart")
                MCApi.sharedInstance().createEmptyCart()
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


extension HomeViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let category = categories[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryViewCell") as! CategoryViewCell
        
        cell.name.text = category.name
        
        if let imageUrl = category.imageUrl{
            let url = URL(string: imageUrl)
            cell.categoryImageView.kf.setImage(with: url)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "SubCategoryViewController") as! SubCategoryViewController
        vc.parentId = categories[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return categories.count
    }
    
    
}
