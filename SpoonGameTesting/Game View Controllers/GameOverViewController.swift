//
//  GameOverViewController.swift
//  SpoonGameTesting
//
//  Created by Brad Donohue on 12/16/20.
//  Copyright © 2020 Brad Donohue. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {

    @IBOutlet weak var Winner1: UILabel!
    @IBOutlet weak var Winner2: UILabel!
    @IBOutlet weak var Winner3: UILabel!
    
    var win1 = ""
    var win2 = ""
    var win3 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Winner1.text = win1
        Winner2.text = win2
        Winner3.text = win3
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ReturnButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //_ = navigationController?.popToRootViewController(animated: true)
    }
    
}
