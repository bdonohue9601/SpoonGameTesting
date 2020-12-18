//
//  ViewController.swift
//  SpoonGameTesting
//
//  Created by Brad Donohue on 4/25/20.
//  Copyright © 2020 Brad Donohue. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

    
class ViewController: UIViewController {
    
    @IBOutlet weak var Table: UITableView!

    let tempClass = CreateUserDict()
    var GameIDList: [String] = []
    var ref: DatabaseReference!
    //let logo = UIBarButtonItem(image: UIImage (named: "Account_circle"), style: .plain, target: self, action: nil)
    
    var user = ""
    var userString = ""
    var phone = ""
    var userDict: [String:String] = [:]
    var tempDict: [String:String] = [:]
    var GameNameDic: [String:String] = [:]
    var SecretDict: [String:String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If user authenticated load games
        if Auth.auth().currentUser != nil{
            
            tempClass.Create(completion: {dic in
                self.userDict = dic
            })
            
            user = Auth.auth().currentUser!.uid
            phone = Auth.auth().currentUser!.phoneNumber!
            Table.dataSource = self
            ref = Database.database().reference()
           
            //Get game information then reload table
            ref.child("UsersGameList/\(user)").observe(DataEventType.value, with: { (snapshot) in
                self.SecretDict = snapshot.value as? [String : String] ?? [:]
                
                self.GameIDList = Array(self.SecretDict.keys)
                for (GameID, _) in self.SecretDict{
                    self.ref.child("Games/\(GameID)/Game Name").observeSingleEvent(of: .value, with: {(snapshot) in
                        let tablename = snapshot.value as? String
                        if let strname = tablename{
                         self.GameNameDic[GameID] = strname
                        }
                        self.Table.reloadData()
                    })
                }
            })
        }
        //Else navigate to Login
        else{
            self.navigateToLoginVC()
        }

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FromCell",
            let destination = segue.destination as? GameViewController,
            let INDEX = Table.indexPathForSelectedRow?.row
        {
            destination.GameID = GameIDList[INDEX]
            //let dic = GameDict[GameIDList[INDEX]]
            destination.GameName = GameNameDic[GameIDList[INDEX]] ?? "No Game Name"
            destination.SecretPlayer = SecretDict[GameIDList[INDEX]] ?? "No Secret"
            
        }
        if segue.identifier == "UserSegue", let destination = segue.destination as? UserViewController{
            //destination.NameString = userString
            destination.NameString = userDict["Name"] ?? "No Name"
            destination.username = userDict["Username"] ?? "No Username"
            destination.PhoneNumber = phone
        }
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

extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.GameIDList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let GameCell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameTableViewCell else {
            return UITableViewCell()
        }
        let game = GameIDList[indexPath.row]
        //let tempDic = GameDict[game]
        GameCell.GameLabel.text = GameNameDic[game]
        
        return GameCell
    }
}
