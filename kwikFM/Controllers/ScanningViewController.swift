//
//  ScanningViewController.swift
//  kwikFM
//
//  Created by MacOS on 13/09/2021.
//  Copyright © 2021 MacOS. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import os.log

class ScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UISearchBarDelegate {
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var toggleFlashButton: UIButton!
    @IBOutlet var searchView: UIView!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView?
    
    // Decalare a furniture item so that it can be sent to the next ViewController
    private var furniture: FurnitureItem? = nil
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var focusView = UIImageView()
    
    private let informUserLabel = UILabel()
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Remove the border between the navigation bar and the search bar.
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view was added to a view hierarchy.
     
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // When the view is added to the view hierarchy, start the capture session again.
        resetBarcodeOverlay()
        captureSession?.startRunning()
    }
    
    /**
     
     => Inherited documentation:
     Called after the controller's view is loaded into memory.
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Turn the flash off.
        toggleFlash(sender: nil)
        
        // Add the crosshair to help the user with the scanning.
        focusView.frame = CGRect(x: 0, y: 0, width: 300, height: 250)
        let cameraFocusImage = UIImage(named: "camera-focus")
        focusView.image = cameraFocusImage
        focusView.alpha = 0.7
        focusView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 75)
        self.view.addSubview(focusView)
        self.view.addSubview(informUserLabel)
        
        // Set the features of the searchController.
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = LocalizedStrings.searchFurnitureItems
        searchController.searchBar.sizeToFit()
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.keyboardType = .numberPad
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        searchView.addSubview(searchController.searchBar)
        definesPresentationContext = true
        
        // Add the search button above the keyboard.
        addAccessoryView()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = ScanningFeatures.supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the subviews to the front.
            view.bringSubview(toFront: focusView)
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: toggleFlashButton)
            view.bringSubview(toFront: searchView)
            // Initialize QR Code Frame to highlight the code.
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply log it out and don't continue any more.
            os_log("An error occurred while starting a capture session", log: OSLog.default, type: .error)
            return
        }
    }
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view was removed from a view hierarchy.
     
     */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Set the searchController to not active, and stop the flash.
        searchController.isActive = false
        toggleFlash(sender: nil)
    }
    
    /**
     
     => Inherited documentation:
     Tells this object that one or more new touches occurred in a view or window.
     
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Reset the overlay and start the captureSession again.
        resetBarcodeOverlay()
        captureSession?.startRunning()
    }
    
    /**
     
     => Inherited documentation:
     Informs the delegate that the capture output object emitted new metadata objects.
     
     */
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                resetBarcodeOverlay()
                return
            }
            guard let stringValue = readableObject.stringValue else { return }
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            qrCodeFrameView?.frame = (barCodeObject?.bounds)!
            captureSession?.stopRunning()
            
            // found correct data in ean code.
            messageLabel.attributedText = NSAttributedString(string: stringValue, attributes: ScanningFeatures.strokeTextAttributes)
            messageLabel.frame = CGRect(x: 0, y: 0, width: messageLabel.intrinsicContentSize.width , height: 20)
            messageLabel.center = CGPoint(x: focusView.center.x, y: focusView.center.y + 150)
            
            DispatchQueue.main.async {
                let cameraFocusImage = UIImage(named: "camera-focus-green")
                self.focusView.image = cameraFocusImage
                self.focusView.alpha = 1
            }
            
            // Vibrate to inform the user.
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            guard let eanCode = messageLabel.text else {
                resetBarcodeOverlay()
                return
            }
            // Start searching using the scanned ean code.
            searchUsingEanCode(eanCode: eanCode)
        }
    }
    
    /**
     
     Resets the scanning franeView, focusView and the messageLabel.
     
     */
    private func resetBarcodeOverlay() {
        
        qrCodeFrameView?.frame = CGRect.zero
        messageLabel.text = ""
        DispatchQueue.main.async {
            let cameraFocusImage = UIImage(named: "camera-focus")
            self.focusView.image = cameraFocusImage
            self.focusView.alpha = 0.7
            self.view.sendSubview(toBack: self.informUserLabel)
        }
        if toggleFlashButton.currentImage == UIImage(named: "flash-on") {
            toggleFlash(sender: UIButton())
        }
    }
    
    /**
     
     Gets the text from the searchBar and starts searching using the given text/eanCode.
     
     */
    @objc func searchFunitureItemsManually(tapGestureRecognizer: UITapGestureRecognizer) {
        
        guard let eanCode = searchController.searchBar.text, !eanCode.isEmpty else {
            return
        }
        captureSession?.stopRunning()
        searchUsingEanCode(eanCode: eanCode)
    }
    
    /**
     
     Starts searching using the given eanCode.
     
     - parameter eanCode: The ean code of the product.
     
     */
    private func searchUsingEanCode(eanCode: String) {
        
        // Check if the user has put empty spaces as input
        let eanCode = eanCode.removeWhiteSpaces()
        
        if eanCode == "" || eanCode.isEmpty {
            return
        }
        
        let furnitureItemsUrlRequest = RestAPIs.getFurnitureItemRequest(withFurnitureEan: eanCode)
        
        // Initialize the activity indicator
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = focusView.center
        
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Stop the user from interacting with the application
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Calls the completeGetFurnitureItemsRequest method
        getFurnitureItemsRequest(request: furnitureItemsUrlRequest) { status in
            DispatchQueue.main.async(){
                if status == ParseStatus.success {
                    // Declare the defaults and save the ean code.
                    let userDefaults: UserDefaults = UserDefaults.standard
                    userDefaults.set(self.messageLabel.text, forKey: "eanCode")
                    self.navigationController?.popViewController(animated: false)
                    // Perform Segue and show the ScanningViewController
                    self.performSegue(withIdentifier: "showFurnitureDetailsController", sender: self)
                }
                else if status == ParseStatus.fail || status == ParseStatus.empty {
                    // Initialize the alert controller and add an action button to dismiss it.
                    self.showErrorAlert(message: LocalizedStrings.furnitureItemNotFound)
                }
                else if status == ParseStatus.forbidden {
                    self.showErrorAlert(message: LocalizedStrings.youDontHaveAccess)
                }
                // Remove the activity indicator and allow user interaction
                activityIndicator.removeFromSuperview()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    /**
     
     Send a request to the server to get the furniture object.
     
     - parameter request: The http/https URL request.
     - parameter completion: What is returned.
     
     */
    private func getFurnitureItemsRequest(request: URLRequest, completion: @escaping (ParseStatus) -> ()) {
        
        var result = ParseStatus.fail
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error == nil {
                
                if (response as? HTTPURLResponse)!.statusCode == 200 {
                    if let data = data {
                        // Check if the JSONParsers returns a Furniture decoded in JSON
                        if let furniture = JSONParser.parseFurnitureItems(data: data) {
                            self.furniture = furniture
                            result = ParseStatus.success
                        }
                        else {
                            result = ParseStatus.empty
                        }
                    }
                } else if (response as? HTTPURLResponse)!.statusCode == 403 {
                    result = ParseStatus.forbidden
                }
            }
            completion(result)
        }
        task.resume()
    }
    
    /**
     
     Adds the search button to the keyboard.
     
     */
    private func addAccessoryView() {
        
        let searchButton = UIBarButtonItem(title: LocalizedStrings.search, style: .plain, target: self, action: #selector(searchFunitureItemsManually))
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.setItems([flexSpace, searchButton], animated: false)
        searchController.searchBar.inputAccessoryView = toolbar
    }
    
    /**
     
     Shows an error alert and resets the screen capturing.
     
     - parameter message: The message that is going to be shown.
     
     */
    private func showErrorAlert(message: String) {
        
        let errorAlert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.resetBarcodeOverlay()
            self.captureSession?.startRunning()
        }))
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    /**
     
     Called when the segue is performed. Checks if the destination view is the FurnitureDetailsController and sends the furniture object that holds the data of the furniture item.
     
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is FurnitureDetailsController {
            let viewController = segue.destination as! FurnitureDetailsController
            viewController.furniture = self.furniture
        }
    }
    
    /**
     
     Called when we need to unwind to the login screen.
     
     - parameter sender: The Log out button on the ScanningViewController View.
     */
    @IBAction func unwindToLoginScreen(sender: Any) {
        
        self.captureSession?.stopRunning()
        
        let logoutAlert = UIAlertController(title: nil, message: LocalizedStrings.confirmLogOut, preferredStyle: UIAlertControllerStyle.alert)
        
        logoutAlert.addAction(UIAlertAction(title: LocalizedStrings.yes, style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
            
            let userDefaults = UserDefaults.standard
            // Clear the user defaults
            userDefaults.removeObject(forKey: "LoggedIn")
            userDefaults.removeObject(forKey: "EncodedCredentials")
            userDefaults.removeObject(forKey: "eanCode")
            
            // Go to the main screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(controller, animated: true, completion: nil)
        }))
            
        logoutAlert.addAction(UIAlertAction(title: LocalizedStrings.cancel, style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
            self.resetBarcodeOverlay()
            self.captureSession?.startRunning()
        }))
        
        // Show the alert
        self.present(logoutAlert, animated: true, completion: nil)
    }
    
    /**
     
     Presents the ScanningHelpViewController modally.
     
     */
    @IBAction func showPopUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ScanningHelpViewController")
        self.present(controller, animated: true, completion: {
            self.captureSession.stopRunning()
            self.showInformationLabel()
        })
    }
    
    /**
     
     Shows the informUserLabel, which tells the user to tap the screen to continue.
     
     */
    private func showInformationLabel() {
        
        informUserLabel.attributedText = NSAttributedString(string: LocalizedStrings.tapTheScreenToContinue, attributes: ScanningFeatures.strokeTextAttributes)
        informUserLabel.frame = CGRect(x: 0, y: 0, width: informUserLabel.intrinsicContentSize.width, height: 20)
        informUserLabel.center = CGPoint(x: focusView.center.x, y: focusView.center.y - 150)
        informUserLabel.startBlink()
        self.view.bringSubview(toFront: informUserLabel)
    }
    
    /**
     
     Changes the image of the toggleFlashButton.
     - parameter image: The new image of the toggleFlashButton
     
     */
    @IBAction func toggleFlash(sender: UIButton? = nil) {
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                // If the method was called without a sender, turn of the flash.
                if sender == nil {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    // If the method was called with a sender, toggle the flash light.
                    if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                        device.torchMode = AVCaptureDevice.TorchMode.off
                        self.toggleFlashButton.setImage(UIImage(named: "flash-off"), for: .normal)
                    }
                    else {
                        do {
                            try device.setTorchModeOn(level: 1.0)
                            self.toggleFlashButton.setImage(UIImage(named: "flash-on"), for: .normal)
                        } catch {
                            os_log("An error occurred while turning on the torch", log: OSLog.default, type: .error)
                        }
                    }
                }
                device.unlockForConfiguration()
            } catch {
                os_log("An error occurred while turning on the torch", log: OSLog.default, type: .error)
            }
        }
    }
}
