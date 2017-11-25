//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Hein Zaw on 8/23/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import Foundation


extension MCApi{
    
    // MARK: Constants
    struct Constants {
        
        static let API_URL = "https://api.marketcloud.it/v0/"
        
        static let PUBLIC_KEY = "08b9e319-da7f-4080-86a7-53febdbfeb6c"
        static let SECRET_KEY = "QYSWGa2Y1zreY6JqvX-rK1479UDtLyDkscg8mwoDpPs-"
        
        struct Paths {
            static let USERS = "users"
            static let AUTHENTICATE = "users/authenticate"
            static let ADDRESS = "addresses"
            static let TOKENS = "tokens"
            static let CATEGORIES = "categories"
            static let PRODUCTS = "products"
            static let CARTS = "carts"
            static let ORDERS = "orders"
            
            
        }
        

    }
 


}
