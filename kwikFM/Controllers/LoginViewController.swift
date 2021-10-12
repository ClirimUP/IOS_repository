//
//  LoginViewController.swift
//  kwikFM
//
//  Created by MacOS on 13/09/2021.
//  Copyright © 2021 MacOS. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    // Initialize the image view that is goind to be set as the right view of the password text field.
    private let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 23, height: 23))
    
    // Intialize the User Defaults that we be used to save the preferences of the user.
    private let userDefaults: UserDefaults = UserDefaults.standard
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let username = userDefaults.string(forKey: "Username"){
            usernameTextField.text = username
        }
    }
    
    /**
 
     => Inherited documentation:
     Called after the controller's view is loaded into memory.
     
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // When clicking the Return button on the keyboard, go to the next text field.
        usernameTextField.addTarget(passwordTextField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        passwordTextField.addTarget(passwordTextField, action: #selector(resignFirstResponder), for: .editingDidEndOnExit)
        
        // Change the color of the loginButton when it's highlighted.
        loginButton.setBackgroundColor(to: UIColor.gray, forState: .highlighted)
        
        // Call the function that adds a rightView to the passwordTextField that shows the password in plain text.
        addRightView()
    }
    
    /**
     
     => Inherited documentation:
     Notifies the view controller that its view was removed from a view hierarchy.
     
     */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Remove the text from the passwordTextField
        self.passwordTextField.text?.removeAll()
    }
    
    /**
     
     Adds a rightView to the passwordTextField. That view shows the password in plain text when tapped on.
     
     */
    private func addRightView() {
        
        // Set the right view of the passwordTextField as a view image with the 'show-eye' as the image.
        passwordTextField.rightViewMode = UITextFieldViewMode.always
        imageView.image = UIImage(named: "show-eye")!
        
        // Initialize how much padding we want to have on the rightView of the password text field.
        let rightViewPadding: CGFloat = 5
        
        // Create the right view, add padding to the width of the view and set it as the passwordTextField's right view.
        let passwordFieldRightView = UIView(frame: CGRect(x: 0, y: 0, width: imageView.frame.width + rightViewPadding, height: imageView.frame.height))
        
        // Add the imageView to passwordFieldRightView and set that as the right view of the passwordTextField.
        passwordFieldRightView.addSubview(imageView)
        passwordTextField.rightView = passwordFieldRightView
        
        // Add tapGestureRecognizer for the right view of the passwordTextField and call the showPasswordImageTapped method.
        let showPasswordTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.showPasswordImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(showPasswordTapGestureRecognizer)
    }
    
    /**
     
     Shows the ScanningViewController using Segue if the fields are not empty. The seague identifier is set in the Main.storyboard after clicking on the Attribute inspector on the segue
     
     */
    @IBAction func showScanningViewController() {
        
        // Clear the borders if one of them had a red border to indicate empty inputs
        usernameTextField.layer.borderWidth = 0
        passwordTextField.layer.borderWidth = 0
        
        // Unwrap the text fields to get the text inside or else show red borders around fields that don't have text inside and return
        guard let username = usernameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                
                if usernameTextField.text == nil || usernameTextField.text == "" {
                    usernameTextField.shake()
                }
                
                if passwordTextField.text == nil || passwordTextField.text == "" {
                    passwordTextField.shake()
                }
                return
        }

        // Initialize the login activity indicator.
        let loginActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        // Add the loginActivityIndicator to the loginButton.
        DispatchQueue.main.async {
            self.show(activityIndicator: loginActivityIndicator)
        }
        
        // Encode Base64 the decoded credentials
        let encodedCredentials = ((username + ":" + password).data(using: .utf8))?.base64EncodedData();
        
        // TODO: Get the login API URL unwrapped
        let loginUrl = URL(string: "/api/login?version=1.0")!
        // Prepare the login request, by default the method type is GET
        var loginUrlRequest = URLRequest(url: loginUrl)
        // Set maximum request timeout in seconds
        loginUrlRequest.timeoutInterval = RestAPIs.requestTimeoutInterval
        // Set request headers for the login API
        loginUrlRequest.setValue("Basic \(String(data: encodedCredentials!, encoding: .utf8)!)", forHTTPHeaderField: "Authorization")
        
        // Do the GET HTTP request for login by given URLRequest
        URLSession.shared.dataTask(with: loginUrlRequest) { (data, response, error) in
            
            // UI Components can be modified only from the main thread
            DispatchQueue.main.async() {
                // Remove the activity indicator and allow user interaction with the application
                loginActivityIndicator.removeFromSuperview()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            
            if error != nil {
                // Show an error alert to notify the user.
                self.showErrorAlert(withMessage: LocalizedStrings.connectionFailed)
                return
            }
            if let httpUrlResponse = response as? HTTPURLResponse {
                switch httpUrlResponse.statusCode {
                case 200:
                    // Set the user defaults. This is where we hold on to the data needed for requests and preferences
                    self.userDefaults.set(true, forKey: "LoggedIn")
                    self.userDefaults.set(username, forKey: "Username")
                    self.userDefaults.set(encodedCredentials, forKey: "EncodedCredentials")
                    
                    // UI Componentents should be accessed only from the main thread.
                    DispatchQueue.main.async() {
                        // Perform Segue and show the ScanningViewController
                        self.performSegue(withIdentifier: "showScanningViewController", sender: self)
                    }                    
                case 401:
                    // Show an error alert to notify the user that he's not authorized.
                    self.showErrorAlert(withMessage: LocalizedStrings.wrongCredentials)
                    return
                default:
                    // Show an error alert to notify the user.
                    self.showErrorAlert(withMessage: LocalizedStrings.serverConnectionFailed)
                    return
                }
            }
        }.resume()
    }
    
    /**
     
     Called when the right view(image view) of the passwordTextField is tapped. Shows the password in plaintext and changes the image of the view, and hides it if tapped on it again.
     
     - parameter tapGestureRecognizer: The tap registered after the user clicks on the background.
     */
    @objc func showPasswordImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        // Check if password text field is set as secure and set it to unsecure and show the password, if not, set it to secure and hide the password.
        if passwordTextField.isSecureTextEntry {
            passwordTextField.isSecureTextEntry = false            
            imageView.image = UIImage(named: "hide-eye")!
        } else {
            passwordTextField.isSecureTextEntry = true
            imageView.image = UIImage(named: "show-eye")!
        }
    }
    
    /**
     
     Shows the activity indicator on the right side of the login button.
     
     - parameter activityIndicator: The Activity Indicator that is going to be shown.
     
     */
    func show(activityIndicator: UIActivityIndicatorView) {
        
        // Set the indicator on the right side of the login button
        let buttonHeight = loginButton.bounds.size.height
        let buttonWidth = loginButton.bounds.size.width
        activityIndicator.center = CGPoint(x: buttonWidth - buttonHeight/2, y: buttonHeight/2)
        loginButton.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Stop the user from interacting with the application
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    /**
     
     Shows an error alert.
     
     - parameter message: The message that is going to be shown.
     
     */
    func showErrorAlert(withMessage errorMessage: String) {
        
        // Initialize the UIAlertController and add an action button to dismiss it.
        let errorAlert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async {
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    /**
     
     Hide the keyboard when clicking on the background.
     
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
}
