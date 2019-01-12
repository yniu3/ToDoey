//
//  ViewController.swift
//  Todoey
//
//  Created by Helena on 1/7/19.
//  Copyright © 2019 HelenaNiu. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    
    //when we do call this we are certain that we already got a value from selectedCategory
    var selectedCategory : Category? {
        didSet{
            loadItems()
            tableView.rowHeight = 80
        }
    }

    
    //interface to file system using singleton (default) organized by using directory and domainMask(user home directory)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1//returns number of count in itemArray in tableview
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) //reuses 10 cells at a time
        
        if let item = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = item.title //populate the tableview
            
            //Ternary operator ==>
            // value = condition ? valueIfTure : valueIfFalse
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methodes
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        //Completion handler
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
           
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }

        alert.addAction(action)
        self.present(alert,animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manupulation Methods
    
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDelection = self.todoItems?[indexPath.row]{
            do {
                try self.realm.write {
                    realm.delete(itemForDelection)
                }
            } catch {
                print ("Error deleting item \(error)")
            }
        }
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //update the todoItems by the specified filter (realm functionality)
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
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
