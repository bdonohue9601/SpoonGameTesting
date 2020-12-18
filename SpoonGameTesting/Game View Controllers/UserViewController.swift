//
//  UserViewController.swift
//  SpoonGameTesting
//
//  Created by Brad Donohue on 6/14/20.
//  Copyright © 2020 Brad Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserViewController: UIViewController {

    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var UserNumber: UILabel!
    @IBOutlet weak var usernameVar: UILabel!
    
    var NameString = ""
    var PhoneNumber = ""
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserName.text = NameString
        UserNumber.text = PhoneNumber
        usernameVar.text = username
        // Do any additional setup after loading the view.
    }
    
    @IBAction func SignOutUser(_ sender: Any) {
        
        //navigateToViewController()
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: {action in
            do{
                try Auth.auth().signOut(); print("Done"); self.navigateToLoginVC()}
            catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
            
            //self.navigateToViewController();
            print("Did something")}))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    private func navigateToLoginVC(){
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let mainPage = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            return
        }
        mainPage.modalPresentationStyle = .fullScreen
        present(mainPage, animated: true, completion: nil)
    }

}
