//
//  ViewController.swift
//  Todoey
//
//  Created by Helena on 1/7/19.
//  Copyright © 2019 HelenaNiu. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    //when we do call this we are certain that we already got a value from selectedCategory
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    //let defaults = UserDefaults.standard
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //interface to file system using singleton (default) organized by using directory and domainMask(user home directory)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist") //it's an array. Print the first one
        
//        //Prints the path of where the file is stored
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
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
        savedItems()
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        

//        //Updating the value to be string "Completed" once you click on the cell.REMEMBER TO SAVE CONTEXT!*saveItems()* b/c everything is still in context/staged mode.
//        itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        //Completion handler
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //what will hapen when user clicks on the Add Item button on our UIAlert
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory 
            
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
        
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) { //*with* is external parameter, *request* is internal parameter, and *Item.fetchRequest()* is the default value in case the parameter part is empty
        //In this case we have to specify the data type as well as the entity - Item
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //Optional binding for additonalPredicate
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        //add the search querary to our request
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) //the left hand *title* contains anything that you type in the search bar

        //sort the data that we get back
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] //returns an array with only contain a single item
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    //This delegate method will be triggered if the text(s) changed inthe search bar at any point
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            //This inforces assignment of running in the forground
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
