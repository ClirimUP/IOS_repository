//
//  ReservationDetailsViewController.swift
//  kwikFM
//
//  Created by MacOS on 30/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import UIKit

class ReservationDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var reservationDetailsTable: UITableView!
    @IBOutlet var assignButton: UIButton!
    
    var reservationDetails: Reservation!
    private var details = [String?]()
    private var detailsKeys = [String]()
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        reservationDetailsTable.reloadData()
    }
    
    /**
     
     => Inherited documentation:
     Called after the controller's view is loaded into memory.
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the color of the assignButton when it's highlighted.
        assignButton.setBackgroundColor(to: UIColor.gray, forState: .highlighted)
        
        // Remove the unnecessary empty lines from the table.
        reservationDetailsTable.tableFooterView = UIView()
        
        details = [
            reservationDetails.customer,
            reservationDetails.timelineId,
            reservationDetails.designation,
            DateConverter.convertToReadable(date: reservationDetails.created),
            DateConverter.convertToReadable(date: reservationDetails.updated),
            DateConverter.convertToShort(date: reservationDetails.reproach_date),
            reservationDetails.status.uppercased(),
            reservationDetails.comment
        ]
        detailsKeys = [
            LocalizedStrings.customer,
            LocalizedStrings.timelineId,
            LocalizedStrings.designation,
            LocalizedStrings.created,
            LocalizedStrings.updated,
            LocalizedStrings.reproachDate,
            LocalizedStrings.status,
            LocalizedStrings.comment
        ]
    }
    
    /**
     
     => Inherited documentation:
     Tells the data source to return the number of rows in a given section of a table view.
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    /**
     
     => Inherited documentation:
     Asks the data source for a cell to insert in a particular location of the table view.
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reservationsDetailsCell = tableView.dequeueReusableCell(withIdentifier: "reservationDetailsCell", for: indexPath) as! MainTableViewCell
        
        let index: Int = indexPath.row
        
        reservationsDetailsCell.titleLabel.text = detailsKeys[index]
        
        if details[index] != nil {
            reservationsDetailsCell.detailLabel.text = details[index]
        }        
        
        return reservationsDetailsCell
    }
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that a segue is about to be performed.
     
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BatchScanningController {
            let viewController = segue.destination as! BatchScanningController
            viewController.reservationId = reservationDetails.id
        }
    }
}
