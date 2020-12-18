//
//  LoginViewController.swift
//  SpoonGameTesting
//
//  Created by Brad Donohue on 5/30/20.
//  Copyright © 2020 Brad Donohue. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
import FirebaseAuth

typealias FIRUser = FirebaseAuth.User



class LoginViewController: UIViewController, FUIAuthDelegate {

    
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
           if Auth.auth().currentUser != nil{
                   //do something
                 print("Should navigate")
                 //navigateToViewController()
               }
    }
    
   /* override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil{
            //do something
        }
        else{
            let authUI = FUIAuth.defaultAuthUI()
            authUI?.delegate = self
            let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
            authUI?.providers = providers
            let authViewController = authUI!.authViewController()
            self.present(authViewController, animated: true, completion: nil)
            
        }
    }*/
    func authUI(_ authUI: FUIAuth, didSignInWith user: FirebaseAuth.User?, error: Error?){
        // Something
        //let user: FIRUser? = Auth.auth().currentUser
        if let user = Auth.auth().currentUser {
            let rootRef = Database.database().reference()
            let userRef = rootRef.child("Users").child(user.uid)

            // 1
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // 2 handle snapshot containing data
                if let userDict = snapshot.value as? [String: Any]{
                    print("User good \(userDict.debugDescription)")
                    self.navigateToViewController()
                }
                else{
                    self.navigateToUserInfo()
                    print("New User")
                }
            })
        }
        //print(user!.uid)

        
    }
    
    @IBAction func LoginButton(_ sender: Any) {
        
        if Auth.auth().currentUser != nil{
              //do something
            navigateToViewController()
            //navigateToUserInfo()
            
          }
        else{
          let authUI = FUIAuth.defaultAuthUI()
          authUI?.delegate = self
            let providers: [FUIAuthProvider] = [FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!)]
          authUI?.providers = providers
            let phoneProvider = FUIAuth.defaultAuthUI()!.providers.first as! FUIPhoneAuth
            phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
          //let authViewController = authUI!.authViewController()
          //self.present(authViewController, animated: true, completion: nil)
        
          
      }
    
        //navigateToViewController()
        
    }
    private func navigateToViewController(){
        
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let mainPage = mainStoryboard.instantiateViewController(withIdentifier: "NavigationViewController") as? NavigationViewController else {
            return
        }
        mainPage.modalPresentationStyle = .fullScreen
        present(mainPage, animated: true, completion: nil)
    }
    private func navigateToUserInfo(){
        
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let mainPage = mainStoryboard.instantiateViewController(withIdentifier: "UserNavController") as? UserNavController else {
            return
        }
        mainPage.modalPresentationStyle = .fullScreen
        present(mainPage, animated: true, completion: nil)
    }
    
}
