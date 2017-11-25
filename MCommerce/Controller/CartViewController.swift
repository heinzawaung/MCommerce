//
//  CartViewController.swift
//  MCommerce
//
//  Created by Hein Zaw on 11/9/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import UIKit
import PKHUD
import RealmSwift

class CartViewController: UIViewController,UITableViewDataSource ,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cartTotalLabel: UILabel!
    var productItems : [ProductCartItem]! = []
    let realm = try! Realm()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    @IBAction func checkout(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ShippingAddressVC") as! ShippingAddressViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateUI(cart:Cart)  {
        self.cartTotalLabel.text = cart.display_total
        
        self.productItems.removeAll()
        
        
        for item in (cart.items){
            self.productItems.append(item)
            
        }
        self.tableView.reloadData()
        
        if let tabItems = self.tabBarController?.tabBar.items as NSArray!
        {
            let tabItem = tabItems[1] as! UITabBarItem
            
            if cart.items.count != 0 {
                tabItem.badgeValue = String(cart.items.count)
                tabItem.badgeColor = UIColor.orange
            }else{
                tabItem.badgeValue = nil
            }
        
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let savedCart = self.realm.objects(Cart.self).first
        if let savedCart = savedCart {
            updateUI(cart: savedCart)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell") as! CartCell
        
        let productItem = productItems[indexPath.row]
        cell.name.text = productItem.name
        
        let url = URL(string:  productItem.images[0].image)
        cell.productImage.kf.setImage(with: url)
        
        cell.price.text = productItem.display_price
        cell.quantity.text = String(productItem.quantity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let productItem = productItems[indexPath.row]
            MCApi.sharedInstance().removeItemFromCart(productId: productItem.id) {
                success , cart in
                if success {
                    self.updateUI(cart: cart!)
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
   
   

}
