//
//  CategoryViewController.swift
//  Document Core Data Relation
//
//  Created by Megan Wilson on 9/26/19.
//  Copyright © 2019 Megan Wilson. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var categoryTableView: UITableView!
    
    var categories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Categories"
    }
    
    
    @IBAction func add(_ sender: Any) {
        let alert = UIAlertController(title: "Add Category", message: "Enter new category name.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertAction.Style.default, handler: {
            (alertAction) -> Void in
            if let textField = alert.textFields?[0], let name = textField.text {
                let categoryName = name.trimmingCharacters(in: .whitespaces)
                if (categoryName == "") {
                    self.notifyUser(message: "Category was not created.\nThe name can not be empty.")
                    return
                }
                self.addCat(name: categoryName)
            } else {
                self.notifyUser(message: "Category was npt created.\nThe name was not accessible.")
                return
            }
            
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "category name"
            textField.isSecureTextEntry = false
            
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchCategories(searchString: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
       
       func notifyUser(message: String) { // done
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))

           self.present(alert, animated: true, completion: nil)
       }
       
       func addCat(name: String) {
           // check if category by that name already exists
           if (categoryExists(name: name)) {
               notifyUser(message: "The category \(name) already exists.")
               return
           }
           
           let category = Category(name: name)
           
           if let category = category {
               do {
                   let managedObjectContext = category.managedObjectContext
                   try managedObjectContext?.save()
               } catch {
                   print("Category was not saved.")
               }
           } else {
               print("Category was not created.")
           }
           
           fetchCategories(searchString: "")
       }
       
       func fetchCategories(searchString: String) {
           guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
               return
           }
           let managedContext = appDelegate.persistentContainer.viewContext
           let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
           fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
           do {
               if (searchString != "") {
                   fetchRequest.predicate = NSPredicate(format: "name contains[c] %@", searchString)
               }
               categories = try managedContext.fetch(fetchRequest)
               categoryTableView.reloadData()
           } catch {
               print("Fetch could not be performed")
           }
       }
       func categoryExists(name: String) -> Bool {
           guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, name != "" else {
               return false
           }
           let managedContext = appDelegate.persistentContainer.viewContext
           let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
           do {
               fetchRequest.predicate = NSPredicate(format: "name == %@", name)
               let results = try managedContext.fetch(fetchRequest)
               if results.count > 0 {
                   return true
               } else {
                   return false
               }
           } catch {
               return false
           }
       }
       
       func confirmDeleteCat(at indexPath: IndexPath) {
           let category = categories[indexPath.row]
           
           if let documentSet = category.documents, documentSet.count > 0 {
               // confirm deletion
               let name = category.name ?? "Category"
            let alert = UIAlertController(title: "Delete Category", message: "\(name) contains documents. Are you sure you want to delete it?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
                   (alertAction) -> Void in
                   // handle cancellation of deletion
                   self.categoryTableView.reloadData()
               }))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: {
                   (alertAction) -> Void in
                   // handle deletion here
                   self.deleteCat(at: indexPath)
               }))
               self.present(alert, animated: true, completion: nil)
               
           } else {
               deleteCat(at: indexPath)
           }
       }
       
      func change(at indexPath: IndexPath) { //done
          let category = categories[indexPath.row]
       let alert = UIAlertController(title: "Edit Category", message: "Enter a new category name.", preferredStyle: UIAlertController.Style.alert)
       alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
       alert.addAction(UIAlertAction(title: "Submit", style: UIAlertAction.Style.default, handler: {
              (alertAction) -> Void in
              if let textField = alert.textFields?[0], let name = textField.text {
                  let categoryName = name.trimmingCharacters(in: .whitespaces)
                  if (categoryName == "") {
                      self.notifyUser(message: "Category name was not changed.\nPlease enter a name.")
                      return
                  }
                  
                  if (categoryName == category.name) {
                      // Nothing to change, new name is old name.
                      // Do this check before checking that categoryExists,
                      // otherwise if category name doesn't change error about already existing will occur.
                      return
                  }
                  
                  if (self.categoryExists(name: categoryName)) {
                      self.notifyUser(message: "Category name not changed.\n\(categoryName) already exists.")
                      return
                  }
                  
                  self.updateCat(at: indexPath, name: categoryName)
              } else {
                  self.notifyUser(message: "Category name was not changed.\nThe name could not be accessed.")
                  return
              }
              
          }))
          alert.addTextField(configurationHandler: {(textField: UITextField!) in
              textField.placeholder = "Category name"
              textField.isSecureTextEntry = false
              textField.text = category.name
              
          })
          self.present(alert, animated: true, completion: nil)
      }
       
       func deleteCat(at indexPath: IndexPath) {
           let category = categories[indexPath.row]
           
           if let managedObjectContext = category.managedObjectContext {
               managedObjectContext.delete(category)
               
               do {
                   try managedObjectContext.save()
                   self.categories.remove(at: indexPath.row)
                   categoryTableView.deleteRows(at: [indexPath], with: .automatic)
               } catch {
                   print("Delete failed: \(error).")
                   categoryTableView.reloadData()
               }
           }
       }
       
       func updateCat(at indexPath: IndexPath, name: String) {
           let category = categories[indexPath.row]
           category.name = name
           
           if let managedObjectContext = category.managedObjectContext {
               do {
                   try managedObjectContext.save()
                   fetchCategories(searchString: "")
               } catch {
                   print("Update failed.")
                   categoryTableView.reloadData()
               }
           }
       }
       
       func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return categories.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
           
           let category = categories[indexPath.row]
           cell.textLabel?.text = category.name
           
           return cell
       }
       
       func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
           let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
               action, index in
               self.confirmDeleteCat(at: indexPath)
           }
           
           let edit = UITableViewRowAction(style: .default, title: "Edit") {
               action, index in
               self.change(at: indexPath)
           }
           edit.backgroundColor = UIColor.blue
       
           return [delete, edit]
       }
       
       
       
       // need to insert
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if let destination = segue.destination as? DocsViewController,
               let row = categoryTableView.indexPathForSelectedRow?.row {
               destination.category = categories[row]
           }
       }
       
    

}
