//
//  PropertiesViewController.swift
//  kwikFM
//
//  Created by MacOS on 19/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import UIKit

class PropertiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet var mainTableView: UITableView!
    
    var properties: [FurnitureProperties]!
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        mainTableView.reloadData()
    }
    
    /**
     
     => Inherited documentation:
     Called after the controller's view is loaded into memory.
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.tableFooterView = UIView()
    }
    
    /**
     
     => Inherited documentation:
     Tells the data source to return the number of rows in a given section of a table view.
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    /**
     
     => Inherited documentation:
     Asks the data source for a cell to insert in a particular location of the table view.
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let propertiesCell = tableView.dequeueReusableCell(withIdentifier: "propertiesCell", for: indexPath) as! MainTableViewCell
        
        let index: Int = indexPath.row
        
        propertiesCell.titleLabel.text = properties[index].name
        
        if properties[index].type == "checkbox" {
            propertiesCell.detailLabel.isHidden = true
            
            if properties[index].input == "true" || properties[index].input == "1" {
                propertiesCell.accessoryType = .checkmark
            }
        }
        
        propertiesCell.detailLabel.text = properties[index].input
        
        return propertiesCell
    }
}
