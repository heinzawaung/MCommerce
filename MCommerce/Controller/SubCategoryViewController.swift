//
//  SubCategoryViewController.swift
//  MCommerce
//
//  Created by Hein Zaw on 10/26/17.
//  Copyright © 2017 Hein Zaw. All rights reserved.
//

import UIKit
import RealmSwift

class SubCategoryViewController: UIViewController {

    var parentId : Int?
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    
    var subCategories: [Category]! = []
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let parentId = parentId {
            let cats = try! realm.objects(Category.self).filter("parentId == \(parentId)")
            for c in cats {
                subCategories.append(c)
            }
            
            tableView.reloadData()
        }
    }

   
}

extension SubCategoryViewController: UITableViewDelegate,UITableViewDataSource{
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let category = subCategories[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryViewCell") as! CategoryViewCell
        
        cell.name.text = category.name
        
        if let imageUrl = category.imageUrl{
            let url = URL(string: imageUrl)
            cell.categoryImageView.kf.setImage(with: url)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        vc.categoryPath = subCategories[indexPath.row].path
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return subCategories.count
    }
    
}
