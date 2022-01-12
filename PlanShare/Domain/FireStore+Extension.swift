//
//  FireStore+Extension.swift
//  PlanShare
//
//  Created by JK on 2022/01/12.
//

import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import RxSwift

extension Reactive where Base: Firestore {
  func addDocument(path: String, data: [String: Any]) -> Maybe<DocumentReference> {
    var id: DocumentReference!
    return .create { subscriber in
      id = base.collection(path).addDocument(data: data) { err in
        if let err = err {
          subscriber(.error(err))
        } else {
          subscriber(.success(id))
        }
      }

      return Disposables.create()
    }
  }
}

extension Reactive where Base: CollectionReference {
  func new<T: Encodable>(document data: T) -> Single<DocumentReference> {
    let document = base.document()

    return .create { subscriber in
      do {
        try document.setData(from: data) { err in
          if let err = err {
            subscriber(.failure(err))
          } else {
            subscriber(.success(document))
          }
        }
      } catch {
        subscriber(.failure(FirebaseService.Err.request))
      }

      return Disposables.create()
    }
  }

  func get<T: Decodable>(id: String) -> Single<T> {
    let document = base.document(id)
    return .create { subscriber in
      document.getDocument { snapshot, error in
        if let error = error {
          subscriber(.failure(error))
        } else {
          guard let snapshot = snapshot else {
            subscriber(.failure(FirebaseService.Err.request))
            return
          }

          guard let value = try? snapshot.data(as: T.self, decoder: Firestore.Decoder()) else {
            subscriber(.failure(FirebaseService.Err.serialized))
            return
          }
          subscriber(.success(value))
        }

      }

      return Disposables.create()
    }
  }
}
