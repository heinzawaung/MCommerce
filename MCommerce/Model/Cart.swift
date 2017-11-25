//
//  Cart.swift
//  MCommerce
//
//  Created by Hein Zaw on 9/27/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import Foundation
import RealmSwift

class Cart: Object
    
{
    @objc dynamic var id :Int = 0
    @objc dynamic var display_total :String = ""
    
    let items = List<ProductCartItem>()
    
    
}
