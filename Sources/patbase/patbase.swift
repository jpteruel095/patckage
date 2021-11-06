//
//  File.swift
//  
//
//  Created by John Patrick Teruel on 11/3/21.
//

import Foundation
import FirebaseFirestore
import patckage
import SwiftCoroutine

extension CollectionReference {
    // MARK: Create
    @discardableResult
    public func add<T: ObjectCodable>(document: T) -> FutureDocument<T> {
        .init {
            let data = try document.toDictionary()
            let ref = self.addDocument(data: data)
            let result: (DocumentSnapshot?, Error?) = try Coroutine.await{ callback in
                ref.getDocument(completion: callback)
            }
            if let error = result.1 {
                throw error
            }
            guard let snapshot = result.0,
                  let data = snapshot.data() else{
                throw PatckageError.empty
            }
            
            let final = try T(from: data)
            return DocumentObject(
                objectID: snapshot.documentID,
                document: ref,
                data: final
            )
        }
    }
}

extension Query {
    // MARK: Read
    @discardableResult
    public func retrieve<T: ObjectCodable>() -> FutureDocumentList<T> {
        .init {
            let result = try Coroutine.await{
                self.getDocuments(completion: $0)
            }
            if let error = result.1 {
                throw error
            }
            guard let snapshot = result.0 else{
                throw PatckageError.empty
            }
            
            return try snapshot.documents.compactMap({
                let data = try T(from: $0.data())
                return DocumentObject(
                    objectID: $0.documentID,
                    document: $0.reference,
                    data: data
                )
            })
        }
    }
    
    @discardableResult
    public func retrieveFirst<T: ObjectCodable>() -> FutureDocument<T> {
        .init {
            let documents: DocumentList<T> = try self.retrieve().await()
            guard let result = documents.first else {
                throw PatckageError.empty
            }
            return result
        }
    }
}


public typealias DocumentList<T: ObjectCodable> = [DocumentObject<T>]
public typealias FutureDocument<T: ObjectCodable> = CoFuture<DocumentObject<T>>
public typealias FutureDocumentList<T: ObjectCodable> = CoFuture<[DocumentObject<T>]>

public struct DocumentObject<DataObject: ObjectCodable> {
    public let objectID: String
    public let document: DocumentReference?
    public var data: DataObject
    
    // MARK: Update
    public func update(in collection: CollectionType) -> CoFuture<Void> {
        .init {
            let objectID = self.objectID
            let data = try self.data.toDictionary()

            guard let error = try Coroutine.await ({
                collection.collection.document(objectID)
                    .setData(data, completion: $0)
            }) else {
                return
            }
            throw error
        }
    }
}

public protocol WithPath {
    var path: String { get }
}

public extension WithPath where Self: RawRepresentable, RawValue == String {
    var path: String {
        self.rawValue
    }
}

public protocol CollectionType: WithPath {
}

extension CollectionType {
    public var collection: CollectionReference {
        Firestore.firestore().collection(self.path)
    }
}
