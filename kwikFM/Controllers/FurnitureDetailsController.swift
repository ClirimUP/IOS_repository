//
//  FurnitureDetailsController.swift
//  kwikFM
//
//  Created by MacOS on 13/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import UIKit

class FurnitureDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet var furnitureImage: UIImageView!
    @IBOutlet var reserveButton: UIButton!
    @IBOutlet var mainTableView: UITableView!
    
    var furniture: FurnitureItem!
    
    private var reservations: [Reservation]? = []
    
    private var furnitureDetailsKeys = [String]()
    private var furnitureDetails = [String?]()
    private var furnitureMoreDetails = [String?]()
    
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
        
        furnitureDetailsKeys = [
            LocalizedStrings.title_localized,
            LocalizedStrings.item_nr,
            LocalizedStrings.manufacturer,
            LocalizedStrings.type,
            LocalizedStrings.properties,
            LocalizedStrings.moreDetails
        ]
        furnitureDetails = [
            furniture.title,
            furniture.item_nr,
            furniture.manufacturer,
            furniture.type,
            "",
            ""
        ]
        
        furnitureMoreDetails = [
            furniture.category,
            DateConverter.convertToReadable(date: furniture.created),
            DateConverter.convertToReadable(date: furniture.updated),
            furniture.diameter,
            furniture.length,
            String(furniture.minimum_holding ?? 0),
            furniture.model,
            furniture.height,
            String(furniture.not_assembled),
            String(furniture.stock),
            furniture.width,
            furniture.comment
        ]
        
        // Call the method to display the furniture's image.
        displayImage()
        
        // Call the method to check for the furniture's reservations.
        checkForReservations()
        
        // Remove the extra rows on the mainTableView.
        mainTableView.tableFooterView = UIView()
        
        // Change the color of the reserveButton when it's highlighted.
        reserveButton.setBackgroundColor(to: UIColor.gray, forState: .highlighted)
    }
    
    /**
     
     Shows the ReservationsViewController.
     
     */
    @IBAction func showReservationsViewController(sender: Any){
        
        self.performSegue(withIdentifier: "showReservationsViewController", sender: self)
    }
    
    /**
     
     => Inherited documentation:
     Tells the data source to return the number of rows in a given section of a table view.
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return furnitureDetailsKeys.count
    }
    
    /**
     
     => Inherited documentation:
     Tells the delegate that the specified row is now selected.
     
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! MainTableViewCell
        
        if currentCell.titleLabel.text == LocalizedStrings.properties {
            self.performSegue(withIdentifier: "showFurnitureProperties", sender: self)
        }
        
        if currentCell.titleLabel.text == LocalizedStrings.moreDetails {
            self.performSegue(withIdentifier: "showMoreDetails", sender: self)
        }
    }
    
    /**
     
     => Inherited documentation:
     Asks the data source for a cell to insert in a particular location of the table view.
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let detailsCell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath) as! MainTableViewCell
        let index: Int = indexPath.row
        
        if furnitureDetailsKeys[index] == LocalizedStrings.properties || furnitureDetailsKeys[index] == LocalizedStrings.moreDetails {
            detailsCell.accessoryType = .disclosureIndicator
            detailsCell.selectionStyle = .default
        }
 
        if furnitureDetails[index] != nil {
            detailsCell.detailLabel.text = furnitureDetails[index]
        }
        
        detailsCell.titleLabel.text = furnitureDetailsKeys[index]
        
        return detailsCell
    }
        
    /**
     
     Get the furniture's image and set it as the UIImage.
     
     */
    private func displayImage() {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = CGPoint(x: furnitureImage.frame.height/2, y: furnitureImage.frame.width/2)
        furnitureImage.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Declare the defaults...
        let defaults: UserDefaults = UserDefaults.standard
        let serverUrl = defaults.string(forKey: "ServerURL")
        
        if furniture.image != "" && !furniture.image.isEmpty {
            // Get the imageUrl URL unwrapped.
            let imageUrl = URL(string: serverUrl! + furniture.image)!
            // Prepare the imageUrlRequest request.
            var imageUrlRequest = URLRequest(url: imageUrl)
            imageUrlRequest.timeoutInterval = RestAPIs.requestTimeoutInterval
            
            URLSession.shared.dataTask(with: imageUrlRequest) { data, response, error in
                DispatchQueue.main.async(execute: {
                    activityIndicator.removeFromSuperview()
                })
                if error == nil && (response as? HTTPURLResponse)!.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async(execute: {
                            self.furnitureImage.image = UIImage(data: data)!
                            return
                        })
                    }
                } else {
                    self.setNoImageFound()
                }
            }.resume()
        } else {
            self.setNoImageFound(remove: activityIndicator)
        }
    }
    
    /**
     
     Check if there are any reservations for the furniture.
     
     */
    private func checkForReservations() {
        
        let buttonHeight = reserveButton.bounds.size.height
        let buttonWidth = reserveButton.bounds.size.width
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.center = CGPoint(x: buttonWidth - buttonHeight/2, y: buttonHeight/2)
        reserveButton.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let reservationsUrlRequest = RestAPIs.getReservationRequest(withFurnitureId: furniture.id)
        
        URLSession.shared.dataTask(with: reservationsUrlRequest) { data, response, error in
            
            if error == nil && (response as? HTTPURLResponse)!.statusCode == 200 {
                if let data = data {
                    // Check if the JSONParser returns Reservations decoded in JSON.
                    if let reservations = JSONParser.parseReservations(data: data) {
                        if reservations.count > 0 {
                            self.reservations = reservations
                            DispatchQueue.main.async(execute: {
                                self.reserveButton.isEnabled = true
                            })
                        } else {
                            self.reservationsNotAvailable()
                        }
                    }
                }
            } else {
                self.reservationsNotAvailable()
            }
            
            DispatchQueue.main.async(execute: {
                activityIndicator.removeFromSuperview()
            })
        }.resume()
    }
    
    /**
     
     Set the reserveButton as disabled and inform the user that there are not reservations available.
     
     */
    private func reservationsNotAvailable() {
        
        DispatchQueue.main.async(execute: {
            let buttonHeight = self.reserveButton.bounds.size.height
            let buttonWidth = self.reserveButton.bounds.size.width
            let secondLabel = UILabel(frame: CGRect(x: 0, y: buttonHeight * 0.5, width: buttonWidth, height: buttonHeight * 0.5))
            secondLabel.textColor = .white
            secondLabel.font = UIFont.systemFont(ofSize: 11)
            secondLabel.text = LocalizedStrings.noReservationsAvailable
            secondLabel.textAlignment = .center
            secondLabel.alpha = 0.8
            self.reserveButton.addSubview(secondLabel)
            self.reserveButton.isEnabled = false
            self.reserveButton.backgroundColor = UIColor.gray
        })
    }
    
    /**
     
     Sets the image for furnitureImage and removes the activityIndicator if it's passed as an argument.
     
     */
    private func setNoImageFound(remove activityIndicator: UIActivityIndicatorView? = nil) {
        DispatchQueue.main.async(execute: {
            let image = UIImage(named: "no-image-found")
            self.furnitureImage.image = image
            if activityIndicator != nil {
                activityIndicator!.removeFromSuperview()
            }
        })
    }
    
    
    /**
     
     Override this method so that the capture session doesn't start again.
     
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    /**
     
     Called when the segue is performed. Checks if the destination view is the FurniturePropertiesController and sends the furniture properties array.
     
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PropertiesViewController {
            let viewController = segue.destination as! PropertiesViewController
            viewController.properties = self.furniture.properties           
        }
        
        if segue.destination is ReservationsViewController {
            let viewController = segue.destination as! ReservationsViewController
            viewController.reservations = self.reservations
        }
        
        if segue.destination is ExtendedDetailsViewController {
            let viewController = segue.destination as! ExtendedDetailsViewController
            viewController.furnitureMoreDetails = self.furnitureMoreDetails
        }
    }
}
