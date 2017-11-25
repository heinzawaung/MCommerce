//
//  ProductCartItem.swift
//  MCommerce
//
//  Created by Hein Zaw on 11/12/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import Foundation
import RealmSwift


class ProductCartItem: Object{
    
    @objc dynamic var id :Int = 0
    @objc dynamic var has_variants :Int = 0
    @objc dynamic var name :String = ""
    @objc dynamic var display_price : String = ""
    @objc dynamic var product_description :String = ""
    @objc dynamic var price :Int = 0
    @objc dynamic var quantity :Int = 0
    var images = List<ProductImage>()
    
    
}
