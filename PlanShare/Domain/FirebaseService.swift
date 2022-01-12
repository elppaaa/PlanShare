//
//  FirebaseService.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import Firebase
import FirebaseDatabase
import Foundation
import RxSwift

// MARK: - FirebaseServieType

protocol FirebaseServieType {
}

// MARK: - FirebaseService

final class FirebaseService: FirebaseServieType {

  // MARK: Internal

  enum Err: Error {
    case serialized
  }

//  static let shared = FirebaseService()

  static let planRef = db.collection("Plan")

  static func configure() {
    FirebaseApp.configure()

    #if DEBUG
    let settings = Self.db.settings
    settings.host = "localhost:8080"
    settings.isPersistenceEnabled = false
    settings.isSSLEnabled = false
    Self.db.settings = settings
    #endif
  }

  static func write(path: String, data: FirestoreEncodable) -> Maybe<DocumentReference> {
    guard let data = data.dict else { return .error(Err.serialized) }

    return db.rx.addDocument(path: path, data: data)
  }

  static func write(path: String, data: FirestoreEncodable) async -> Result<DocumentReference, Error> {
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

  // MARK: Private

  private static let db: Firestore = .firestore()
}
