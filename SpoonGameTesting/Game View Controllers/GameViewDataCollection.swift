//
//  GameViewDataCollection.swift
//  SpoonGameTesting
//
//  Created by Brad Donohue on 12/16/20.
//  Copyright © 2020 Brad Donohue. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth


class GameData {
    
    var ref: DatabaseReference!
    var user: String
    
    init() {
        ref = Database.database().reference()
        user = Auth.auth().currentUser!.uid
    }
    func CollectPlayerStatus(GameID : String, completion: @escaping ((Dictionary<String, String>), (Dictionary<String, Int>)) -> Void ){
        
        let Group = DispatchGroup()
        
        ref.child("Games/\(GameID)/PlayerStatus").observe(.value, with: {(snapshot) in
            let status = snapshot.value as? [String : Int] ?? [:]
            var spoonerDict: [String:String] = [:]
            
            for (spooner,_) in status{
                Group.enter()
                self.getNames(Spooner: spooner, completion: {name in
                    spoonerDict[spooner] = name
                    Group.leave()
                })
            }
            Group.notify(queue: .main){
                completion(spoonerDict, status)
            }
        })
    }
    func getNames(Spooner: String, completion: @escaping (String) -> Void){
    
        self.ref.child("Users/\(Spooner)/Name").observeSingleEvent(of: .value, with: {(snapshot) in
            let SpoonerName = snapshot.value as? String
            if let stringname = SpoonerName{
                completion(stringname)
            }
        })
    }
    
}
