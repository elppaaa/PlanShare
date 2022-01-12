//
//  FireStore+Extension.swift
//  PlanShare
//
//  Created by JK on 2022/01/12.
//

import Firebase
import FirebaseDatabase
import FirebaseFirestore
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
