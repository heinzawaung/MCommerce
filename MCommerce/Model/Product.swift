//
//  Product.swift
//  MCommerce
//
//  Created by Hein Zaw on 9/27/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import Foundation
import RealmSwift

class ProductImage: Object {
    @objc dynamic var image :String = ""
}

class Product: Object
    

{
    @objc dynamic var id :Int = 0
    @objc dynamic var has_variants :Int = 0
    @objc dynamic var name :String = ""
    @objc dynamic var display_price : String = ""
    @objc dynamic var product_description :String = ""
    @objc dynamic var price :Int = 0
    var images = List<ProductImage>()
    
    //@objc dynamic var variants :[ProductVariant]?
  
    
    
    
    
    
}

