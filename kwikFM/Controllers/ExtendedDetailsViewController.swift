//
//  ExtendedDetailsViewController.swift
//  kwikFM
//
//  Created by MacOS on 09/11/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import UIKit

class ExtendedDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var moreDetailsTableView: UITableView!
    
    var furnitureMoreDetails: [String?]!
    
    let furnitureMoreDetailsKeys = [
        LocalizedStrings.category,
        LocalizedStrings.created,
        LocalizedStrings.updated,
        LocalizedStrings.diameter,
        LocalizedStrings.length,
        LocalizedStrings.minimum_holding,
        LocalizedStrings.model,
        LocalizedStrings.height,
        LocalizedStrings.not_assembled,
        LocalizedStrings.stock,
        LocalizedStrings.width,
        LocalizedStrings.comment
    ]
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        moreDetailsTableView.reloadData()
    }
    
    /**
     
     => Inherited documentation:
     Called after the controller's view is loaded into memory.
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moreDetailsTableView.tableFooterView = UIView()
    }
    
    /**
     
     => Inherited documentation:
     Tells the data source to return the number of rows in a given section of a table view.
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return furnitureMoreDetailsKeys.count
    }
    
    /**
     
     => Inherited documentation:
     Asks the data source for a cell to insert in a particular location of the table view.
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let moreDetailsCell = tableView.dequeueReusableCell(withIdentifier: "moreDetailsCell", for: indexPath) as! MainTableViewCell
        
        let index: Int = indexPath.row
        
        if furnitureMoreDetails[index] != nil {
            moreDetailsCell.detailLabel.text = furnitureMoreDetails[index]
        }
        
        moreDetailsCell.titleLabel.text = furnitureMoreDetailsKeys[index]
        
        return moreDetailsCell
    }
}
