//
//  MCApi.swift
//  Virtual Tourist
//
//  Created by Hein Zaw on 8/23/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Realm
import RealmSwift


class MCApi : NSObject{
    
    let realm = try! Realm()
    
    func registerUser(email:String,name:String, password:String, completion: @escaping ((_ sucess: Bool, _ errorMessage:String?) -> Void)){
        
        let parameters: Parameters = [
            "email": email,
            "name": name,
            "password":password
        ]
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY
            
        ]
        
        let url = Constants.API_URL + Constants.Paths.USERS
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headerRequest)
          
            .responseJSON { (response) -> Void in
                
                guard response.result.isSuccess else {
                    print(response.error.debugDescription)
                    completion(false,"Cannot connect to server")
                    return
                }
                
                guard let value = response.result.value as? [String:AnyObject] else{
                    completion(false,"Cannot connect to server")
                    return
                }
                print(value)
                
                
                guard let status = value["status"] as? Bool , status else{
                    
                    if let error = value["errors"] as? [[String:AnyObject]]{
                        let message = error[0]["message"] as! String
                        completion(false,message)
                        return
                    }
                    
                    completion(false,"Authentication Fail!")
                    return
                }
                
                self.authenticate(email: email, password: password) {
                    success,errorMessage in
                    
                    if success {
                        completion(true,nil)
                        
                    }else{
                        completion(false,errorMessage)
                        
                        
                    }
                }
                
                
                
               
        }
        
    }

    func authenticate(email:String, password:String, completion: @escaping ((_ sucess: Bool, _ errorMessage:String?) -> Void)) {
        
        //let token = UserDefaults.standard.value(forKey: "token") as! String
        
        let parameters: Parameters = [
            "email": email,
            "password":password
        ]
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY
            
        ]
        
        let url = Constants.API_URL + Constants.Paths.AUTHENTICATE
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headerRequest)
          
            .responseJSON { (response) -> Void in
                
                guard response.result.isSuccess else {
                    print(response.error.debugDescription)
                    completion(false,"Cannot connect to server")
                    return
                }
                
                guard let value = response.result.value as? [String:AnyObject] else{
                    completion(false,"Cannot connect to server")
                    return
                }
                
                guard let status = value["status"] as? Bool , status else{
                    
                    if let error = value["errors"] as? [[String:AnyObject]]{
                        let message = error[0]["message"] as! String
                        completion(false,message)
                        return
                    }
                    
                    completion(false,"Authentication Fail!")
                    return
                }
                
               
               
                
                if let data = value["data"] as? [String:Any]{
                    
                    if let token = data["token"] as? String{
                        
                        UserDefaults.standard.setValue(email, forKey: "email")
                        UserDefaults.standard.setValue(password, forKey: "password")
                        UserDefaults.standard.set(token, forKey: "token")
                        completion(true,nil)
                        
                    }
                }
                
        }
        
    }
    
    func getLastCreatedCart(completion: @escaping ((_ sucess: Bool, _ id:Int?) -> Void)){
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY + ":" + token
        ]
        
        let url = Constants.API_URL + Constants.Paths.CARTS
        
        Alamofire.request(url, method: .get , encoding: JSONEncoding.default, headers: headerRequest)
            // .validate()
            .responseJSON { (response) -> Void in
                print(response.result.description)
                guard response.result.isSuccess else {
                    completion(false,nil)
                    return
                }
                
                
                
                if let value = response.result.value as? [String:AnyObject] {
                    print(value)
                    if let data = value["data"] as? [String:AnyObject]{
                        if let id = data["id"] as? Int{
                            completion(true,id)
                        }else{
                            completion(false,nil)
                        }
                    }else{
                        completion(false,nil)
                    }
                }else{
                    completion(false,nil)
                }
                
        }
        
    }
    
    func getCartDetail(id:Int,completion: @escaping ((_ sucess: Bool, _ itemCount:Int) -> Void)){
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY + ":" + token
        ]
        
        
        if let id = UserDefaults.standard.value(forKey: "cart_id") as? Int {
            let url = Constants.API_URL + Constants.Paths.CARTS + "/" + String(id)
            
            Alamofire.request(url, method: .get , encoding: JSONEncoding.default, headers: headerRequest)
                // .validate()
                .responseJSON { (response) -> Void in
                    print(response.result.description)
                    guard response.result.isSuccess else {
                        completion(false,0)
                        return
                    }
                    
                    self.saveCart(response:response){
                        success, cart in
                        completion(success,(cart?.items.count)!)
                    }
                    
                  
                    
            }
        }
        
        
        
    }
    
    func saveCart(response :DataResponse<Any>, completion: @escaping ((_ sucess: Bool, _ cart:Cart?) -> Void)) {
        if let value = response.result.value as? [String:AnyObject] {
            
            let cart = self.realm.objects(Cart.self)
            try! self.realm.write {
                self.realm.delete(cart)
            }
            if let data = value["data"] as? [String:AnyObject]{
                let id = data["id"] as! Int
                let display_total = data["display_total"] as! String
                
                let cart = Cart()
                cart.id = id
                cart.display_total = display_total
                
                let items = data["items"] as! [[String:AnyObject]]
                for item in items {
                    let product = ProductCartItem()
                    
                    product.id = item["id"] as! Int
                    product.name = item["name"] as! String
                    product.price = item["price"] as! Int
                    product.display_price = item["display_price"] as! String
                    product.quantity = item["quantity"] as! Int
                    
                    
                    if let imageArray = item["images"] as? [String] {
                        
                        
                        for image in imageArray{
                            let proudctImage = ProductImage()
                            proudctImage.image = image
                            product.images.append(proudctImage)
                        }
                        
                    }else{
                        
                    }
                    cart.items.append(product)
                    
                }
                
                try! self.realm.write {
                    self.realm.add(cart)
                }
                
                let savedCart = self.realm.objects(Cart.self).first
                
                completion(true,savedCart)
                
                
            }else{
                completion(false,nil)
            }
        }else{
            completion(false,nil)
        }
    }
    
    func createEmptyCart(){
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        let parameters: Parameters = [
            :
        ]
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY + ":" + token
        ]
        
        print(headerRequest)
        let url = Constants.API_URL + Constants.Paths.CARTS
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headerRequest)
           // .validate()
            .responseJSON { (response) -> Void in
                print(response.result.description)
                guard response.result.isSuccess else {
                
                    return
                }
                
                print(response.result.value)
               
        }
                
    }
    
    func addItemToCart(productId:Int, quantity:Int, completion: @escaping ((_ sucess: Bool, _ cart :Cart?) -> Void)){
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        if let id = UserDefaults.standard.value(forKey: "cart_id") as? Int {
            let url = Constants.API_URL + Constants.Paths.CARTS + "/" + String(id)
            
            let parameters = [
                "op" : "add",
                "items": [
                    [
                        "product_id" : productId,
                        "quantity": quantity
                        
                    ]
                ]
                ] as [String : Any]
            
            let headerRequest: HTTPHeaders = [
                "accept": "application/json",
                "Content-Type": "application/json",
                "authorization": Constants.PUBLIC_KEY + ":" + token
            ]
            
          
            
            
            Alamofire.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headerRequest)
                // .validate()
                .responseJSON { (response) -> Void in
                    print(response.result.description)
                    guard response.result.isSuccess else {
                        completion(false,nil)
                        return
                    }
                    
                    print(response.result.value)
                    
                    self.saveCart(response: response){
                        success , cart in
                        completion(success,cart)
                    }
                    
                    
                    
            }
        }
        
    }
    
    func removeItemFromCart(productId:Int, completion: @escaping ((_ sucess: Bool, _ cart:Cart?) -> Void)){
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        if let id = UserDefaults.standard.value(forKey: "cart_id") as? Int {
            let url = Constants.API_URL + Constants.Paths.CARTS + "/" + String(id)
            
            let parameters = [
                "op" : "remove",
                "items": [
                    [
                        "product_id" : productId
                       
                    ]
                ]
                ] as [String : Any]
            
            let headerRequest: HTTPHeaders = [
                "accept": "application/json",
                "Content-Type": "application/json",
                "authorization": Constants.PUBLIC_KEY + ":" + token
            ]
            
            
            Alamofire.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headerRequest)
                // .validate()
                .responseJSON { (response) -> Void in
                    print(response.result.description)
                    guard response.result.isSuccess else {
                        completion(false,nil)
                        return
                    }
                
                    
                    self.saveCart(response: response){
                        success , cart in
                        completion(success,cart)
                        
                    }
                    
                   
                    
            }
        }
        
    }
    
    
    func loadCategoryList(completion: @escaping (( _:Bool , _ :Results<Category>?) -> Void)) {
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY + ":" + token
        ]
        
        let url = Constants.API_URL + Constants.Paths.CATEGORIES
        
        Alamofire.request(url, method: .get, headers: headerRequest)
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    completion(false,nil)
                    return
                }
                
                print(response.result.value)
                if let value = response.result.value as? [String:AnyObject] {
                    

                    let categories = self.realm.objects(Category.self)
                    try! self.realm.write {
                        self.realm.delete(categories)
                    }
                    
                    
                    let data = value["data"] as! [[String:AnyObject]]
                    
                    for categoryJSON in data {
                        
                        let category = Category()
                        
                        category.id = categoryJSON["id"] as! Int
                        category.name = categoryJSON["name"] as! String
                        category.imageUrl = categoryJSON["image_url"] as? String
                        category.path = categoryJSON["path"] as? String
                        
                        if let parentId = categoryJSON["parent_id"] as? Int {
                            category.parentId = parentId
                        }else{
                            category.parentId = 0
                        }
                        
                        try! self.realm.write {
                            self.realm.add(category)
                        }
                        
                    }
                    
                    let cats = try! self.realm.objects(Category.self).filter("parentId == 0")
                    completion(true,cats)
                    return
                    
                    
                }
               
        }
        
    }
    
    func loadOrderList(completion: @escaping (( _:Bool , _ :Results<Category>?) -> Void)) {
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY + ":" + token
        ]
        
        let url = Constants.API_URL + Constants.Paths.ORDERS
        
        Alamofire.request(url, method: .get, headers: headerRequest)
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    completion(false,nil)
                    return
                }
                
                print(response.result.value)
                if let value = response.result.value as? [String:AnyObject] {
                    
                    
                    let categories = self.realm.objects(Category.self)
                    try! self.realm.write {
                        self.realm.delete(categories)
                    }
                    
                    
                    let data = value["data"] as! [[String:AnyObject]]
                    
                    for orderJSON in data {
                        
                       
                        
                    }
                    
                   
                    return
                    
                    
                }
                
        }
        
    }
    
    func createAddress(name:String, email:String, country:String, city:String, address1:String, postalCode:String, completion: @escaping ((_ sucess: Bool, _ errorMessage :String?, _ addressId: Int?) -> Void)) {
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        let parameters: Parameters = [
            "full_name": name,
            "email": email,
            "country": country,
            "city": city,
            "address1": address1,
            "postal_code":postalCode
        ]
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY + ":" + token
            
        ]
        
        let url = Constants.API_URL + Constants.Paths.ADDRESS
        
       
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headerRequest)
            
            .responseJSON { (response) -> Void in
                
                print(response)
                
                guard response.result.isSuccess else {
                    print(response.error.debugDescription)
                    completion(false,"Cannot connect to server",nil)
                    return
                }
                
                guard let value = response.result.value as? [String:AnyObject] else{
                    completion(false,"Cannot connect to server",nil)
                    return
                }
                
                guard let status = value["status"] as? Int , status == 1 else{
                    
                    if let error = value["errors"] as? [[String:AnyObject]]{
                        let message = error[0]["message"] as! String
                        completion(false,message,nil)
                        return
                    }
                    
                    
                    return
                }
                
                
                if let data = value["data"] as? [String:Any]{
                    
                    if let id = data["id"] as? Int{
                        
                        completion(true,nil,id)
                        
                    }
                }
                
        }
        
    }
    
    func createOrder(cardId:Int, shippingAddressId:Int, billingAddressId:Int, completion: @escaping ((_ sucess: Bool, _ :String?) -> Void)) {
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        let parameters: Parameters = [
            "cart_id": cardId,
            "shipping_address_id": shippingAddressId,
            "billing_address_id ": billingAddressId
        ]
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY + ":" + token
            
        ]
        
        let url = Constants.API_URL + Constants.Paths.ORDERS
        
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headerRequest)
            
            .responseJSON { (response) -> Void in
                
                print(response)
                
                guard response.result.isSuccess else {
                    print(response.error.debugDescription)
                    completion(false,"Cannot connect to server")
                    return
                }
                
                guard let value = response.result.value as? [String:AnyObject] else{
                    completion(false,"Cannot connect to server")
                    return
                }
                
                guard let status = value["status"] as? Int , status == 1 else{
                    
                    if let error = value["errors"] as? [[String:AnyObject]]{
                        let message = error[0]["message"] as! String
                        completion(false,message)
                        return
                    }
                    
                    
                    return
                }
                
                
                if let data = value["data"] as? [String:Any]{
                    
                    if let id = data["id"] as? Int{
                        
                        print("id \(id)")
                        completion(true,nil)
                        
                        
                    }
                }
                
        }
        
    }
    
    func loadProductList(by categoryPath :String, completion: @escaping (( _:Bool , _ :Results<Product>?) -> Void)) {
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        let headerRequest: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
            "authorization": Constants.PUBLIC_KEY + ":" + token
        ]
        
        
        
        let param = "?category=" + categoryPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
       
        
        let url = Constants.API_URL + Constants.Paths.PRODUCTS + param
        
        
        Alamofire.request(url, method: .get, headers: headerRequest)
            
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    completion(false,nil)
                    print(response.error.debugDescription)
                    return
                }
                
                if let value = response.result.value as? [String:AnyObject] {
                    
                    
                    let products = self.realm.objects(Product.self)
                    try! self.realm.write {
                        self.realm.delete(products)
                    }
                    
                    print(value)
                    
                    
                    let data = value["data"] as! [[String:AnyObject]]
                    
                    for productJSON in data {
                        
                        let product = Product()
                        
                        product.id = productJSON["id"] as! Int
                        product.name = productJSON["name"] as! String
                        product.price = productJSON["price"] as! Int
                        product.display_price = productJSON["display_price"] as! String
                        
                       
                        if let imageArray = productJSON["images"] as? [String] {
                           
                            
                            for image in imageArray{
                                let proudctImage = ProductImage()
                                proudctImage.image = image
                                
                               
                                product.images.append(proudctImage)
                            }
                            
                        }else{
                            
                        }
                        
                        try! self.realm.write {
                            self.realm.add(product)
                        }
                        
                    }
                    
                    
                    
                    let prods = try! self.realm.objects(Product.self)
                    completion(true,prods)
                    
                   
                    return
                    
                    
                }
                
                
                print(response.result.value)
        }
        
    }

    class func sharedInstance() -> MCApi {
        struct Singleton {
            static var sharedInstance = MCApi()
        }
        return Singleton.sharedInstance
    }
    
    func sha256(_ data: Data) -> Data? {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
        CC_SHA256((data as NSData).bytes, CC_LONG(data.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
        return res as Data
    }
    
    func sha256String(_ str: String) -> String? {
        guard
            let data = str.data(using: String.Encoding.utf8),
            let shaData = sha256(data)
            else { return nil }
        let rc = shaData.base64EncodedString(options: [])
        return rc
    }
}

