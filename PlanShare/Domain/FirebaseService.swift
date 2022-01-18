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

final class FirebaseService: FirebaseServieType {

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

    #if DEBUG
    settings.host = "localhost:8080"
    settings.isPersistenceEnabled = false
    settings.isSSLEnabled = false
    #endif
    Self.db.settings = settings
  }

  static func create(path: String, data: FirestoreEncodable) async -> Result<DocumentReference, Error> {
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

  static func create<T: Encodable>(path: String, data: T) -> Single<DocumentReference> {
    db.collection(path).rx.new(document: data)
  }

  static func read<T: Decodable>(path: String, id: String) -> Single<T> {
    db.collection(path).rx.get(id: id)
  }

  static func delete(path: String, id: String) -> Completable {
    db.collection(path).rx.delete(id: id)
  }

  static func update<T: Decodable>(path: String, id: String, updateBlock: @escaping (T) -> [String: Any]) -> Completable {
    let document = db.collection(path)
    let observable: Single<T> = document.rx.get(id: id)

    return observable
      .flatMapCompletable { (value: T) in
        let updateValue = updateBlock(value)
        return document.document(id).rx.update(to: updateValue)
      }
  }

  // MARK: Private

  private static let db: Firestore = .firestore()
}
