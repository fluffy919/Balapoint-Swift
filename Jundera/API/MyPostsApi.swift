//
//  MyPostsApi.swift
//  Balapoint
//
//  Created by David S on 11/14/17.
//  Copyright © 2017 David S. All rights reserved.
//  May have to modify this to be myPublic, myPrivate, myDraft

import Foundation
import FirebaseDatabase

class MyPostsApi {
    
    var REF_MYPOSTS = Database.database().reference().child("myPosts")
    
    func fetchMyPosts(userId: String, completion: @escaping (String) -> Void) {
        REF_MYPOSTS.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
    func fetchCountMyPosts(userId: String, completion: @escaping (Int) -> Void) {
        REF_MYPOSTS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
