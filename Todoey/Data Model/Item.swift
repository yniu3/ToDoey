//
//  Item.swift
//  Todoey
//
//  Created by Helena on 1/11/19.
//  Copyright © 2019 HelenaNiu. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    
    //Defining Inverse relationship item with class Category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
