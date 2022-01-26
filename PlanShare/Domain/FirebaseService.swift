//
//  FirebaseService.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import RxSwift

// MARK: - FirebaseServieType

protocol FirebaseServieType {}

// MARK: - FirebaseService

final actor FirebaseService: FirebaseServieType {

  // MARK: Internal

  enum Err: Error {
    case serialized
    case request
  }

  static let planRef = db.collection("Plan")

  static func configure() {
    FirebaseApp.configure()
    let settings = Self.db.settings
    settings.isPersistenceEnabled = true

    //    #if DEBUG
    //    settings.host = "localhost:8090"
    //    settings.isSSLEnabled = false
    //    #endif
    Self.db.settings = settings
  }

  static func create(path: String, data: FirestoreEncodable) async -> Result<DocumentReference, Error> {
    Log.log(.debug, category: .firebase, #function)
    guard let data = data.dict else { return .failure(Err.serialized) }

    return await withCheckedContinuation { continueation in
      var ref: DocumentReference!
      ref = db.collection(path).addDocument(data: data) { err in
        if let err = err {
          continueation.resume(returning: .failure(err))
        } else {
          continueation.resume(returning: .success(ref))
        }
      }
    }
  }

  //  static func readByIDs<T: Decodable>(path: String, list: [Any], useCache: Bool = false) async -> Result<[T], Error> {
  //    Log.log(.debug, category: .firebase, #function)
  //    return db.collection(path).rx.getDocumentsBy(idList: list, useCache: useCache)
  //      .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
  //  }
  static func readByIDs<T: Decodable>(path: String, list: [Any], useCache: Bool = false) async -> Result<[T], Error> {
    Log.log(.debug, category: .firebase, #function)
    return await db.collection(path).getDocumentsBy(idList: list, useCache: useCache)
  }

  static func create<T: Encodable>(path: String, data: T) async -> Result<DocumentReference, Error> {
    Log.log(.debug, category: .firebase, #function)
    return await db.collection(path).new(document: data)
  }

  static func read<T: Decodable>(path: String, id: String) async -> Result<T, Error> {
    Log.log(.debug, category: .firebase, #function)
    return await db.collection(path).get(id: id)
  }

  static func delete(path: String, id: String) async -> Result<Void, Error> {
    Log.log(.debug, category: .firebase, #function)
    return await db.collection(path).delete(id: id)
  }

  static func update<T: Decodable>(path: String, id: String, updateBlock: @escaping (T) -> [String: Any]) async -> Result<Void, Error> {
    Log.log(.debug, category: .firebase, #function)
    let document = db.collection(path)
    let _result: Result<T, Error> = await document.get(id: id)

    switch _result {
    case .success(let value):
      let updateValue = updateBlock(value)
      return await document.document(id).update(to: updateValue)
    case .failure(let err):
      return .failure(err)
    }
  }

  static func update<T: Encodable>(path: String, id: String, value: T) async -> Result<Void, Error> {
    Log.log(.debug, category: .firebase, #function)
    let document = db.collection(path)

    return await document.document(id).update(to: value)
  }

  // MARK: Private

  private static let db: Firestore = .firestore()
}
