//
//  UserService.swift
//  Pat-ckageSPMSample
//
//  Created by John Patrick Teruel on 11/4/21.
//

import Foundation
import SwiftCoroutine
import patbase
import Fakery
import Firebase

class UserService {
//    func getUser() -> CoFuture<DocumentObject<User>> {
//        let result: [DocumentObject<User>] try PatStore.shared.retrieve(from: PatCollection.users).await()
//    }
    private lazy var db = Firestore.firestore()
    private lazy var faker = Faker()
    private lazy var rawID = faker.number.randomInt(min: 1000, max: 9999)
    private lazy var userID = "\(rawID)"
    
    func createUser() -> FutureDocument<User> {
        .init {
            let data = User(
                name: self.faker.name.name(),
                age: self.faker.number.randomInt(min: 20, max: 50),
                userID: self.userID
            )
            return try PatCollection.users
                .collection
                .add(document: data)
                .await()
        }
    }
    
    func getCurrentUser() -> FutureDocument<User> {
        PatCollection.users
            .collection
            .whereField("userID", isEqualTo: userID)
            .retrieveFirst()
    }
    
    func updateUser(name: String, age: Int) -> FutureDocument<User> {
        .init {
            var document: DocumentObject<User> = try PatCollection.users
                .collection
                .whereField("userID", isEqualTo: self.userID)
                .retrieveFirst()
                .await()
                                            
            document.data.name = name
            document.data.age = age
            try document.update(in: PatCollection.users).await()
            return document
        }
    }
}

enum PatCollection: String, CollectionType {
    case users
    
    
}
