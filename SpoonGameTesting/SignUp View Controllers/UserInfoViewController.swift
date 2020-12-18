//
//  UserInfoViewController.swift
//  SpoonGameTesting
//
//  Created by Brad Donohue on 6/14/20.
//  Copyright © 2020 Brad Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserInfoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var FirstName: UITextField!
    
    @IBOutlet weak var LastName: UITextField!
    
    @IBOutlet weak var CreateName: UIButton!
    
    var ref: DatabaseReference!
    
    var user = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.FirstName.delegate = self
        self.LastName.delegate = self
        
        CreateName.isEnabled = false
        
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if ((FirstName.text!.count > 0) && (LastName.text!.count > 0)){
           CreateName.isEnabled = true
        }
        else{
           CreateName.isEnabled = false
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //let set = NSCharacterSet.alphanumerics
        //return string.rangeOfCharacterFromSet(set) == nil
        
        let allowedCharacters = CharacterSet.letters
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
        
    }
    
    
    @IBAction func Cancel(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func EnterButton(_ sender: Any) {

        ref.child("Users").child(user!).setValue(["Name": "\(FirstName!.text!) \(LastName!.text!)"]) /*{
          (error:Error?, ref:DatabaseReference) in
          if let error = error {
            print("Data could not be saved: \(error).")
          } else {
            print("Data saved successfully!")
          }
        }*/
        //self.ref.child("Users").setValue(user)*/
        /*ref.child("Users").child("User3").setValue(["Name": "Brad"]) {
           (error:Error?, ref:DatabaseReference) in
           if let error = error {
             print("Data could not be saved: \(error).")
           } else {
             print("Data saved successfully!")
           }
         }*/

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

}
/*
extension UserInfoViewController: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                do {
                    let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: [])
                    if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                        return false
                    }
                }
                catch {
                    print("ERROR")
                }
            return true
    }
}
*/
