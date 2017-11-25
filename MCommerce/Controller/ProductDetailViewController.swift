//
//  ProductDetailViewController.swift
//  MCommerce
//
//  Created by Hein Zaw on 10/29/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import UIKit
import Auk

class ProductDetailViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var price: UILabel!
    
    
    
    var proudctPrice : String!
    var proudctId : Int!
    var productImages = [String]()
    var productDescription : String!
    
    var priceAmount : Int!
    var quantity = 1
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        productDescriptionLabel.text = productDescription
        price.text = proudctPrice
        for productImage in productImages {
          
            scrollView.auk.show(url: productImage)
        }
        
        totalPriceLabel.text = String(priceAmount)
        
       
        
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func decreaseQuantity(_ sender: Any) {
        if self.quantity <= 1{
            
        }else {
            self.quantity = self.quantity - 1 ;
            quantityLabel.text = String(self.quantity)
        }
        
        totalPriceLabel.text = String(priceAmount * quantity)
    }
    
  
    @IBAction func increaseQuantity(_ sender: Any) {
        
        self.quantity = self.quantity + 1 ;
        quantityLabel.text = String(self.quantity)
        
        totalPriceLabel.text = String(priceAmount * quantity)
        
    }
    
    @IBAction func addToCart(_ sender: Any) {
        print("add")
        MCApi.sharedInstance().addItemToCart(productId: proudctId, quantity: quantity){
            success ,cart in
            if success {
                if let tabItems = self.tabBarController?.tabBar.items as NSArray!
                {
                    let tabItem = tabItems[1] as! UITabBarItem
                    
                    if cart?.items.count != 0 {
                        tabItem.badgeValue = String(cart!.items.count)
                        tabItem.badgeColor = UIColor.orange
                    }else{
                        tabItem.badgeValue = nil
                    }
                    
                    
                }
            }
        }
    }
    
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
