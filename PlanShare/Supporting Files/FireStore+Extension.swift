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

  func getDocumentsBy<T: Decodable>(idList: [Any], useCache: Bool = false) -> Single<[T]> {
    .create { subscriber in
      base.whereField(FirebaseFirestore.FieldPath.documentID(), in: idList).getDocuments(source: useCache ? .cache : .default) { snapshot, error in
        if let error = error {
          subscriber(.failure(error))
          return
        }

        guard let snapshot = snapshot else {
          subscriber(.failure(FirebaseService.Err.request))
          return
        }

        var result = [T]()

        do {
          for value in snapshot.documents {
            guard let value = try value.data(as: T.self, decoder: Firestore.Decoder()) else {
              subscriber(.failure(FirebaseService.Err.serialized))
              return
            }
            result.append(value)
          }
        } catch {
          debugPrint("ERROR ::::", error)
        }

        subscriber(.success(result))
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

          do {
            guard let value = try snapshot.data(as: T.self, decoder: Firestore.Decoder()) else {
              subscriber(.failure(FirebaseService.Err.serialized))
              return
            }
            subscriber(.success(value))
          } catch {
            print("ERROR ::::", error)
            subscriber(.failure(error))
          }
        }
      }

      return Disposables.create()
    }
  }

//  func update<T: Decodable>(id: String, updateBlock: @escaping (T) -> [String: Any]) -> Completable {
//    get(id: id)
//      .map { updateBlock($0) }
//      .flatMapCompletable({ updateValue in
//        .create { subscriber in
//          let document = base.document(id)
//
//          document.updateData(updateValue) { err in
//            if let err = err {
//              subscriber(.error(err))
//            } else {
//              subscriber(.completed)
//            }
//          }
//
//          return Disposables.create()
//        }
//      })
//  }

  func delete(id: String) -> Completable {
    .create { subscriber in
      base.document(id).delete { err in
        if let err = err {
          subscriber(.error(err))
        } else {
          subscriber(.completed)
        }
      }
      return Disposables.create()
    }
  }
}

extension Reactive where Base: DocumentReference {
  func update(to updateValue: [String: Any]) -> Completable {
    .create { subscriber in
      base.updateData(updateValue) { err in
        if let err = err {
          subscriber(.error(err))
        } else {
          subscriber(.completed)
        }
      }
      return Disposables.create()
    }
  }

  func update<T: Encodable>(to updateValue: T) -> Completable {
    guard let dictionary = updateValue.dictionary else {
      return Completable.error(FirebaseService.Err.serialized)
    }

    return .create { subscriber in
      base.updateData(dictionary) { err in
        if let err = err {
          subscriber(.error(err))
        } else {
          subscriber(.completed)
        }
      }
      return Disposables.create()
    }
  }
}
