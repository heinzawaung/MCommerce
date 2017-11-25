//
//  Category.swift
//  MCommerce
//
//  Created by Hein Zaw on 9/27/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object
    
{
    @objc dynamic var id :Int = 0
    @objc dynamic var parentId :Int = 0
    @objc dynamic var name :String = ""
    @objc dynamic var isSelect = false
    @objc dynamic var imageUrl :String?
    @objc dynamic var path :String?
    
    
}

