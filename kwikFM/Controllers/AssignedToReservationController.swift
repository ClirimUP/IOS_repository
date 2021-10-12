//
//  AssignedToReservationController.swift
//  kwikFM
//
//  Created by MacOS on 03/11/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import UIKit

class AssignedToReservationController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var assignedToReservationTable: UITableView!
    @IBOutlet var endButton: UIButton!
    
    var assignedToReservationResults: [AssignedToReservation]!
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        assignedToReservationTable.reloadData()
    }
    
    /**
     
     => Inherited documentation:
     Called after the controller's view is loaded into memory.
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the color of the endButton when it's highlighted.
        endButton.setBackgroundColor(to: UIColor.gray, forState: .highlighted)
        
        // Remove the unnecessary empty lines from the table.
        assignedToReservationTable.tableFooterView = UIView()
    }
    
    /**
     
     => Inherited documentation:
     Tells the data source to return the number of rows in a given section of a table view.
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignedToReservationResults.count
    }
    
    /**
     
     => Inherited documentation:
     Asks the data source for a cell to insert in a particular location of the table view.
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let assignedToReservationCell = tableView.dequeueReusableCell(withIdentifier: "assignedToReservationCell", for: indexPath) as! MainTableViewCell
        
        let index: Int = indexPath.row
        
        assignedToReservationCell.titleLabel.text = String(assignedToReservationResults[index].furnitureName)
        assignedToReservationCell.detailLabel.text = assignedToReservationResults[index].reason
        
        if assignedToReservationResults[index].status == true {
            assignedToReservationCell.accessoryType = .checkmark
        }
        
        return assignedToReservationCell
    }
    
    /**
     
     Goes back to the root view controller (ScanningViewController).
     
     */
    @IBAction func goBackToStart(sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
