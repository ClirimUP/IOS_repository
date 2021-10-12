//
//  ReservationsViewController.swift
//  kwikFM
//
//  Created by MacOS on 27/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import UIKit

class ReservationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet var reservationsTable: UITableView!
    
    var reservations: [Reservation]!
    private var reservation: Reservation! = nil
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredReservations = [Reservation]()
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        reservationsTable.reloadData()
    }
    
    /**
     
     => Inherited documentation:
     Called after the controller's view is loaded into memory.
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reservationsTable.tableFooterView = UIView()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = LocalizedStrings.searchReservations
        searchController.searchBar.sizeToFit()
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Place the search bar view to the tableview headerview.
            reservationsTable.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
    }
    
    /**
     
     => Inherited documentation:
     Tells the data source to return the number of rows in a given section of a table view.
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredReservations.count
        }
        
        return reservations.count
    }
    
    /**
     
     => Inherited documentation:
     Asks the data source for a cell to insert in a particular location of the table view.
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reservationsCell = tableView.dequeueReusableCell(withIdentifier: "reservationsCell", for: indexPath) as! MainTableViewCell
        
        let index: Int = indexPath.row
        
        let reservation: Reservation
        
        if isFiltering() {
            reservation = filteredReservations[index]
        } else {
            reservation = reservations[index]
        }
        
        reservationsCell.titleLabel.text = "R" + String(reservation.id)
        reservationsCell.detailLabel.text = reservation.designation
        
        return reservationsCell
    }
    
    /**
     
     => Inherited documentation:
     Tells the delegate that the specified row is now selected.
     
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index: Int = indexPath.row
        
        if isFiltering() {
            self.reservation = filteredReservations[index]
        } else {
            self.reservation = reservations[index]
        }
        self.performSegue(withIdentifier: "showReservationDetailsController", sender: self)
    }
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that a segue is about to be performed.
     
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is ReservationDetailsViewController {
            let viewController = segue.destination as! ReservationDetailsViewController
            viewController.reservationDetails = self.reservation
        }
    }
    
    /**
     
     Checks if the searchController is active and not empty.
     
     */
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    /**
     
     => Inherited documentation:
     Called when the search bar becomes the first responder or when the user makes changes inside the search bar.
     
     */
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    /**
     
     Checks if the searchController is empty.
     
     */
    func searchBarIsEmpty() -> Bool {
        
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /**
     
     Filters the results using the text from the searchBar.
     
     */
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredReservations = reservations.filter({( reservation : Reservation) -> Bool in
            return reservation.designation.lowercased().contains(searchText.lowercased()) || String(reservation.id).lowercased().contains(searchText.lowercased())
        })
        reservationsTable.reloadData()
    }
}
