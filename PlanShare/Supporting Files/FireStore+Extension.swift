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

extension Firestore {
  func addDocument(path: String, data: [String: Any]) async -> Result<DocumentReference, Error> {
    await withUnsafeContinuation { container in
      var id: DocumentReference!
      id = self.collection(path).addDocument(data: data) { err in
        if let err = err {
          container.resume(returning: .failure(err))
        } else {
          container.resume(returning: .success(id))
        }
      }
    }
  }
}

extension CollectionReference {
  func new<T: Encodable>(document data: T) async -> Result<DocumentReference, Error> {
    await withUnsafeContinuation { container in
      let document = self.document()
      do {
        try document.setData(from: data) { err in
          if let err = err {
            container.resume(returning: .failure(err))
          } else {
            container.resume(returning: .success(document))
          }
        }
      } catch {
        container.resume(returning: .failure(FirebaseService.Err.request))
      }
    }
  }

  func getDocumentsBy<T: Decodable>(idList: [Any], useCache: Bool = false) async -> Result<[T], Error> {
    await withUnsafeContinuation { container in
      self.whereField(FirebaseFirestore.FieldPath.documentID(), in: idList).getDocuments(source: useCache ? .cache : .default) { snapshot, err in
        if let err = err {
          container.resume(returning: .failure(err))
          return
        }

        guard let snapshot = snapshot else {
          container.resume(returning: .failure(FirebaseService.Err.request))
          return
        }

        var result = [T]()

        do {
          for value in snapshot.documents {
            guard let value = try value.data(as: T.self, decoder: Firestore.Decoder()) else {
              container.resume(returning: .failure(FirebaseService.Err.serialized))
              return
            }
            result.append(value)
          }
        } catch {
          debugPrint("ERROR ::::", error)
        }

        container.resume(returning: .success(result))
      }
    }
  }

  func get<T>(id: String) async -> Result<T, Error> where T: Decodable {
    await withUnsafeContinuation { container in
      let document = self.document(id)
      document.getDocument { snapshot, err in
        if let err = err {
          container.resume(returning: .failure(err))
        } else {
          guard let snapshot = snapshot else {
            container.resume(returning: .failure(FirebaseService.Err.request))
            return
          }

          do {
            guard let value = try snapshot.data(as: T.self, decoder: Firestore.Decoder()) else {
              container.resume(returning: .failure(FirebaseService.Err.serialized))
              return
            }
            container.resume(returning: .success(value))

          } catch {
            print("ERROR ::::", error)

            container.resume(returning: .failure(error))
          }
        }
      }

    }
  }

  //  func update<T: Decodable>(id: String, updateBlock: @escaping (T) -> [String: Any]) -> Completable {
  //    get(id: id)
  //      .map { updateBlock($0) }
  //      .flatMapCompletable({ updateValue in
  //        .create { subscriber in
  //          let document = self.document(id)
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

  func delete(id: String) async -> Result<Void, Error> {
    await withUnsafeContinuation { container in
      self.document(id).delete { err in
        if let err = err {
          container.resume(returning: .failure(err))
        } else {
          container.resume(returning: .success(()))
        }
      }
    }
  }
}

extension DocumentReference {
  func update(to updateValue: [String: Any]) async -> Result<Void, Error> {
    await withUnsafeContinuation { container in
      self.updateData(updateValue) { err in
        if let err = err {
          container.resume(returning: .failure(err))
        } else {
          container.resume(returning: .success(()))
        }
      }
    }
  }

  func update<T: Encodable>(to updateValue: T) async -> Result<Void, Error> {
    guard let dictionary = try? Firestore.Encoder().encode(updateValue) else {
      return .failure(FirebaseService.Err.serialized)
    }

    return await withUnsafeContinuation { container in
      self.updateData(dictionary) { err in
        if let err = err {
          container.resume(returning: .failure(err))
        } else {
          container.resume(returning: .success(()))
        }
      }
    }
  }
}
