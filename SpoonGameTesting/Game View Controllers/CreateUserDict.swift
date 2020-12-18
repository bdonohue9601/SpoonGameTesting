//
//  CreateUserDict.swift
//  SpoonGameTesting
//
//  Created by Brad Donohue on 12/16/20.
//  Copyright © 2020 Brad Donohue. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class CreateUserDict {
    
    var ref: DatabaseReference!
    var user = ""
    
    func Create(completion: @escaping (Dictionary<String, String>)-> Void){
        ref = Database.database().reference()
        user = Auth.auth().currentUser!.uid
        ref.child("Users/\(user)").observe(DataEventType.value, with: {(snapshot) in
            let userdic = snapshot.value as? [String : String] ?? [:]
            completion(userdic)
            print("Finished")
        })
    }
}
