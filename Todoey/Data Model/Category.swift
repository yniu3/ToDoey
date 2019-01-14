//
//  Category.swift
//  Todoey
//
//  Created by Helena on 1/11/19.
//  Copyright © 2019 HelenaNiu. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    
    @objc dynamic var name : String = ""
    
    @objc dynamic var color : String = ""
    
    //Spcify relationship with Item class
    let items = List<Item>()
//    let array : Array<Int> = [1,2,3]
    
}
