//
//  ViewController.swift
//  Todoey
//
//  Created by Helena on 1/7/19.
//  Copyright © 2019 HelenaNiu. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    
    //interface to file system using singleton (default) organized by using directory and domainMask(user home directory)
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist") //it's an array. Print the first one
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(dataFilePath)

//        //Theses are hardcoded items in the Array upon load
//        let newItem = Item()
//        newItem.title = "Find Mike"
//        itemArray.append(newItem)
//
//        let newItem2 = Item()
//        newItem2.title = "Buy Eggos"
//        itemArray.append(newItem2)
//
//        let newItem3 = Item()
//        newItem3.title = "Destory Demogorgon"
//        itemArray.append(newItem3)
        
//        //Repulling array from our saved persistent array
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
        
        loadItems()
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count //returns number of count in itemArray in tableview
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) //reuses 10 cells at a time
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title //populate the tableview
        
        //Ternary operator ==>
        // value = condition ? valueIfTure : valueIfFalse
        
//        cell.accessoryType = item.done == true ?  .checkmark : .none
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARk - TableView Delegate Methodes
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        //some fancy shit that says toggle the boolean on its value
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
//        if itemArray[indexPath.row].done == false{
//           itemArray[indexPath.row].done = true
//        } else {
//            itemArray[indexPath.row].done = false
//        }
        
        savedItems()
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "test", preferredStyle: .alert)
        //Completion handler
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will hapen when user clicks on the Add Item button on our UIAlert
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)//text will never be nil because even an empty string is a string.
            
//            //This a sandbox that saves your ass when app gets terminated by user, OS, or updates
//            self.defaults.set(self.itemArray, forKey: "TodoListArray")

            self.savedItems() //Encode custom items into plist
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods
    
    func savedItems() {
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print ("Error encoding item array, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems() {

        if let data = try? Data(contentsOf: dataFilePath!) { //Optional binding
            let decoder = PropertyListDecoder()
            
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
        
    }
    
}


