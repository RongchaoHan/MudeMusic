//
//  SignUpAndLogInViewController.swift
//  FIT3178-W02-Lab
//
//  Created by Michael Choi on 12/4/22.
//

import UIKit
import FirebaseAuth

class UserSignInViewController: UIViewController, DatabaseListener{

    // Property
    let AUTHENTIFICATION_SEGUE = "UserSignInSegue"
    
    // Outlet
    @IBOutlet weak var errorTextLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Variable
    var authController: Auth?
    var authHandle: AuthStateDidChangeListenerHandle?
    var listenerType: ListenerType = ListenerType.authentification
    weak var databaseController: DatabaseProtocol?
    

    override func viewDidLoad() {
        
        authController = Auth.auth()
        do{
            try authController?.signOut()
        }catch{
            return
        }
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authHandle = authController?.addStateDidChangeListener{
            [self] (auth, user) in
            
            if let _ = user{
                print(user?.uid as Any)
                self.performSegue(withIdentifier: AUTHENTIFICATION_SEGUE, sender: self)
            }
        }
        errorTextLabel.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        authController?.removeStateDidChangeListener(authHandle!)
    }
    
    func onFileChange(change: DatabaseChange, files: [File]) {
        
    }
    func onPackageChange(change: DatabaseChange, packages: [Package]) {
        
    }
    
    func onMusicChange(change: DatabaseChange, musics: [Music]) {
        
    }

    // Check the fields and validate the data if it is correct and returns the error message if incorrect
    func userValidateFields() -> String?{
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        // Check fields
        if email == "" || password == ""{
            return "Please fill in all fields"
        }
        
        // Check email format
        if email.contains("@") == false{
            return "Please enter a valid email address"
        }
        
        // Check email format
        if password.count < 6{
            return "Password must be longer than 6 characters."
        }
        return ""
    }
    
    @IBAction func signInDidTapped(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        if let error = userValidateFields(),
           error.isEmpty == false{
            setErrorText(error: error)
        }
        databaseController?.userLogIn(email: email, password: password)
        
        authHandle = authController?.addStateDidChangeListener{
            [self] (auth, user) in
            
            if let _ = user{
                print(user?.uid as Any)
                self.performSegue(withIdentifier: AUTHENTIFICATION_SEGUE, sender: self)
                return
            }else{
                if databaseController?.errorMsg?.isEmpty == false {
                    setErrorText(error: databaseController?.errorMsg)
                }
                return
            }
        }
        
        authController?.removeStateDidChangeListener(authHandle!)
    }
    
    func setErrorText(error: String?){
        self.errorTextLabel.text = error
    }
    
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}



