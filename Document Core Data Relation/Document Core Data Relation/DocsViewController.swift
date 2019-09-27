//
//  DocsViewController.swift
//  Document Core Data Relation
//
//  Created by Megan Wilson on 9/26/19.
//  Copyright © 2019 Megan Wilson. All rights reserved.
//

import UIKit

class DocsViewController: UIViewController {

    @IBOutlet weak var docsTableView: UITableView!
    
    var category: Category?
    var documents = [Document]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = category?.name ?? ""
               
               dateFormatter.dateStyle = .medium
               dateFormatter.timeStyle = .medium
    }
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }
    override func viewWillAppear(_ animated: Bool) {
           updateDocumentsArray()
           docsTableView.reloadData()
       }
       
       func notifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
           
           self.present(alert, animated: true, completion: nil)
       }
       
       func updateDocumentsArray() {
           documents = category?.documents?.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as? [Document] ?? [Document]()
       }
       
       
       func deleteDoc(at indexPath: IndexPath) {
           let document = documents[indexPath.row]
           
           if let managedObjectContext = document.managedObjectContext {
               managedObjectContext.delete(document)
               
               do {
                   try managedObjectContext.save()
                   self.documents.remove(at: indexPath.row)
                   docsTableView.deleteRows(at: [indexPath], with: .automatic)
               } catch {
                   notifyUser(message: "Delete failed.")
                   docsTableView.reloadData()
               }
           }
       }
       
       func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return documents.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath)
           
           if let cell = cell as? DocumentTableViewCell {
               let document = documents[indexPath.row]
               cell.nameLabel.text = document.name
               cell.sizeLabel.text = String(document.size)
               if let modifiedDate = document.modifiedDate {
                   cell.dateLabel.text = dateFormatter.string(from: modifiedDate)
               } else {
                   cell.dateLabel.text = "unknown"
               }
           }
           
           return cell
       }
       
       func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
           let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
               action, index in
               self.deleteDoc(at: indexPath)
           }
           
           return [delete]
       }
       
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if let destination = segue.destination as? DocViewController,
               let segueIdentifier = segue.identifier {
               destination.category = category
               if (segueIdentifier == "existingDocument") {
                   if let row = docsTableView.indexPathForSelectedRow?.row {
                       destination.document = documents[row]
                   }
               }
           }
       }
       


}
