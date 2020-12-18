//
//  GameViewController.swift
//  SpoonGameTesting
//
//  Created by Brad Donohue on 5/9/20.
//  Copyright © 2020 Brad Donohue. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFunctions
import FirebaseAuth
class GameViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var enterGuessPickerView = UIPickerView()
    
    @IBOutlet weak var NavigationBar: UINavigationItem!
    @IBOutlet weak var PursuitPlayer: UILabel!
    @IBOutlet weak var SpoonerTable: UITableView!
    @IBOutlet weak var EnterGuess: UITextField!
    @IBOutlet weak var GuessButton: UIButton!
    
    lazy var functions = Functions.functions()
    
    var GameID = ""
    var GameName = ""
    var SecretPlayer = ""
    var guess = ""
    var user = ""
    var playersRemaining: Int = 0
    
    var spoonersList = [String]()
    var PickerList = [String]()
    let gameData = GameData()
    //Dictonary <UID, Name>
    var spoonerDict: [String:String] = [:]
    //Dictonary <UID, Status(Alive or not)>
    var SpoonerStatus: [String:Int] = [:]
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NavigationBar.title = GameName
        user = Auth.auth().currentUser!.uid
        dismissPickerView()
        GuessButton.isEnabled = false
        //EnterGuess.inputView = enterGuessPickerView
        EnterGuess.delegate = self
        enterGuessPickerView.delegate = self
        enterGuessPickerView.dataSource = self
        
        SpoonerTable.dataSource = self
    
        gameData.CollectPlayerStatus(GameID: GameID, completion: {dic1, dic2 in
            self.spoonerDict = dic1
            self.SpoonerStatus = dic2
            
            self.listenforSecret()
            self.spoonersList = Array(self.SpoonerStatus.keys)
            self.SpoonerTable.reloadData()
            
            self.playersRemaining = self.SpoonerStatus.filter{$0.value > 0}.count
            if self.playersRemaining < 4{
                self.createGameOver()
                print("Game is Over!!")
            }
            
        })
        
        ref = Database.database().reference()
        ref.child("UsersGameList/\(user)/\(GameID)").observe(.value, with: {(snapshot) in
            //print(snapshot.value ?? "Nothing")
            self.SecretPlayer = snapshot.value as! String
            self.listenforSecret()
        })
    }
    
    func listenforSecret(){
        if SecretPlayer == "Dead"{
            self.PursuitPlayer.text = "You're Dead"
        }
        else{
            self.PursuitPlayer.text = spoonerDict[SecretPlayer]
            }
    }
    
    @IBAction func GuessButton(_ sender: Any) {
        
        let data = ["guess" : self.guess, "game" : "\(self.GameID)"]
        let alert = UIAlertController(title: "Are you sure?", message: "If you are wrong you will eliminate yourself", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
            do{
                self.functions.httpsCallable("checkGuess").call(data) { (result, error) in
                    if let error = error as NSError? {
                      if error.domain == FunctionsErrorDomain {
                        let code = FunctionsErrorCode(rawValue: error.code)
                        _ = error.localizedDescription
                        _ = error.userInfo[FunctionsErrorDetailsKey]
                        print(code ?? "None")
                      }
                        return
                    }
                    if let text = result?.data {
                        self.responseAlert(response: text as! Bool)
                    }
                }}
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    func responseAlert(response: Bool){
        EnterGuess.text = nil
        GuessButton.isEnabled = false
        var Title: String
        var Message: String
        if response == true{
            Title = "Success!"
            Message = "You eliminated \(spoonerDict[guess]!)"
        }
        else{
            Title = "Wrong!"
            Message = "You eliminated yourself!"
        }
        let Alert = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        
        Alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        self.present(Alert, animated: true)
    }
    
    func dismissPickerView(){
        let toolBar = UIToolbar()
        //toolBar.barStyle = .default
        //toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        EnterGuess.inputAccessoryView = toolBar
        
    }
    @objc func doneClick() {
        if EnterGuess.text == ""{
            GuessButton.isEnabled = false
        }
        else{
            GuessButton.isEnabled = true
        }
        view.endEditing(true)
    }
    @objc func cancelClick() {
        EnterGuess.text = nil
        GuessButton.isEnabled = false
        view.endEditing(true)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    private func createGameOver(){
        
        EnterGuess.isEnabled = false
        var winnerList: [String] = []
        for (UID, status) in SpoonerStatus{
            if (status == 1){
                winnerList.append(UID)
            }
        }
        print("Going Back")
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        guard let GameOverPage = mainStoryboard.instantiateViewController(withIdentifier: "GameOver") as? GameOverViewController else {
            return
        }
        GameOverPage.win1 = spoonerDict[winnerList[0]] ?? "No Winner"
        GameOverPage.win2 = spoonerDict[winnerList[1]] ?? "No Winner"
        GameOverPage.win3 = spoonerDict[winnerList[2]] ?? "No Winner"
        GameOverPage.modalPresentationStyle = .popover
        let popoverPres = GameOverPage.popoverPresentationController
        popoverPres?.delegate = self
        popoverPres?.sourceView = self.view
        popoverPres?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        popoverPres?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        present(GameOverPage, animated: true, completion: nil)

        //_ = navigationController?.popToRootViewController(animated: true)
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}

extension GameViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.spoonersList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let spoonerCell = tableView.dequeueReusableCell(withIdentifier: "SpoonerCell", for: indexPath) as? SpoonerTableViewCell else {
            return UITableViewCell()
        }
        
        let player = spoonersList[indexPath.row]
        
        spoonerCell.SpoonerLabel.text = spoonerDict[player]
        if SpoonerStatus[player]! < 1 {
            spoonerCell.SpoonerLabel.textColor = UIColor.red
        }
        else{
            spoonerCell.SpoonerLabel.textColor = UIColor.black
        }
        return spoonerCell
    }
}
extension GameViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //let newCount = SponnerStatus.filter{$0.value > 0}.count
        return PickerList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        spoonerDict[PickerList[row]]
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        EnterGuess.text = spoonerDict[PickerList[row]]
        guess = PickerList[row]
        
        //EnterGuess.resignFirstResponder()
        return
        
    }
    
    
}

extension GameViewController: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if SpoonerStatus[user] == 0{
            return false
        }
        else{
            PickerList = []
            PickerList.append("")
            for (UID, status) in SpoonerStatus{
                if (UID != Auth.auth().currentUser!.uid) && (status == 1){
                    if UID != SecretPlayer{
                        PickerList.append(UID)
                    }
                }
            }
            EnterGuess.inputView = enterGuessPickerView
            return true
        }
    }
}
