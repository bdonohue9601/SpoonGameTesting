//
//  CreateUserNameViewController.swift
//  SpoonGameTesting
//
//  Created by Brad Donohue on 7/6/20.
//  Copyright © 2020 Brad Donohue. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CreateUserNameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var UsernameTextField: UITextField!
    
    @IBOutlet weak var FinishButton: UIButton!
    
    var ref: DatabaseReference!
    
    var user = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FinishButton.isEnabled = false
        self.UsernameTextField.delegate = self
        
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        /*ref.child("Users").queryOrdered(byChild: "Username").queryStarting(atValue: UsernameTextField.text, childKey: "Username").queryEnding(atValue: UsernameTextField.text! + "\u{f8ff}", childKey: "Username").observeSingleEvent(of: .value, with: {(snapshot) in
            print(snapshot)
            })*/
        if UsernameTextField.text!.count > 5{
            ref.child("Users").queryOrdered(byChild: "Username").queryEqual(toValue: UsernameTextField.text?.lowercased()).observeSingleEvent(of: .value, with: {(snapshot) in
                print(snapshot.value as Any)
                if snapshot.exists(){
                    print("Username already exists!")
                    self.FinishButton.isEnabled = false
                }
                else{
                    print("Good to go!")
                    self.FinishButton.isEnabled = true
                }
            })
        }
        else{
            self.FinishButton.isEnabled = false
        }

            //print(username!)
            //print("Changing")
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //text
        //print(UsernameTextField.text!)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if string.count > 0 {
            var allowedCharacters = CharacterSet.alphanumerics
            
            allowedCharacters.insert(charactersIn: "-_")
            
            let unwantedStr = string.trimmingCharacters(in: allowedCharacters)
            return unwantedStr.count == 0
        }
        return true
        
    }

    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func FinishSignUp(_ sender: Any) {
        //ref.child("Users").child(user!).setValue(["Username": "\(String(describing: UsernameTextField.text))"])
        ref.child("Users/\(user!)/Username").setValue(UsernameTextField.text)
        navigateToViewController()
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
