//
//  DocViewController.swift
//  Document Core Data Relation
//
//  Created by Megan Wilson on 9/26/19.
//  Copyright © 2019 Megan Wilson. All rights reserved.
//

import UIKit

class DocViewController: UIViewController {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var contentText: UITextView!
    
    var document: Document?
    var category: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
               
               if let document = document {
                   let name = document.name
                   nameText.text = name
                   contentText.text = document.content
                   title = name
               }
    }
   
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }
    
    func notifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = nameText.text else {
                   notifyUser(message: "Document not saved.\nThe name is not accessible.")
                   return
               }
               
               let documentName = name.trimmingCharacters(in: .whitespaces)
               if (documentName == "") {
                   notifyUser(message: "Document not saved.\nA name is required.")
                   return
               }
               
               let content = contentText.text
               
               if document == nil {
                   if let category = category {
                       document = Document(name: documentName, content: content, category: category)
                   }
               }
               else {
                   if let category = category {
                       document?.update(name: documentName, content: content, category: category)
                   }
               }
               
               if let document = document {
                   do {
                       let managedContext = document.managedObjectContext
                       try managedContext?.save()
                   }
                   catch {
                       notifyUser(message: "Document not saved.\nAn error occured saving context.")
                   }
               } else {
                   notifyUser(message: "Document not saved.\nA Document entity could not be created.")
               }
               
               navigationController?.popViewController(animated: true)
           }
        
    @IBAction func nameChanged(_ sender: Any) {
        title = nameText.text
    }
    
    
}
