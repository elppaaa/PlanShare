//
//  SQLiteEnable.swift
//  PlanShare
//
//  Created by JK on 2022/01/24.
//

import Foundation
import SQLite3

// MARK: - SQLiteEnable

protocol SQLiteEnable {
  var service: SQLiteService { get }
  static var createQuery: String { get }
  static var insertQuery: String { get }
  static var selectAllQuery: String { get }
//  var values: [Any] { get }
  static var readingBlock: (OpaquePointer?) -> Self { get }
  var writingBlock: () throws -> Void { get }
  static var db: String { get }
  var id: Int? { get }
}

extension SQLiteEnable {
  var service: SQLiteService {
    get { .shared }
    set { .shared = newValue }
  }

//  static func readAll<T>(readingBlock: (OpaquePointer?) -> T) -> Result<[T], SQLiteError> {
//    SQLiteService.shared.readAll(query: Self.selectAllQuery, blocks: readingBlock)
//  }

  static func readAll() -> Result<[Self], SQLiteError> {
    SQLiteService.shared.openDB(createQuery: createQuery)
    return SQLiteService.shared.readAll(query: selectAllQuery, blocks: readingBlock)
  }

  func prepare() {
    service.openDB(createQuery: Self.createQuery)
  }

  @discardableResult
  func write() -> SQLiteError? {
    service.write(query: Self.insertQuery, block: writingBlock)
  }

  func delete() -> SQLiteError? {
    guard let id = id else { return .idIsEmpty }
    let deleteQuery = "DELETE FROM \(Self.db) WHERE id \(id)"

    return service.delete(query: deleteQuery, id: id)
  }

  func bind_text(index: Int, value: String) throws {
    if sqlite3_bind_text(service.stmt, Int32(index), value.trimmingCharacters(in: .whitespacesAndNewlines), -1, service.SQLITE_TRANSIENT) != SQLITE_OK {
      Log.log(.error, category: .sqlite, "Failed to bind \(value)")
      throw SQLiteError.failedToBind
    }
  }

  func bind_int(index: Int, value: Int) throws {
    if sqlite3_bind_int(service.stmt, Int32(index), Int32(value)) != SQLITE_OK {
      Log.log(.error, category: .sqlite, "Failed to bind \(value)")
      throw SQLiteError.failedToBind
    }
  }

  func bind_double(index: Int, value: Double) throws {
    if sqlite3_bind_double(service.stmt, Int32(index), value) != SQLITE_OK {
      Log.log(.error, category: .sqlite, "Failed to bind \(value)")
      throw SQLiteError.failedToBind
    }
  }
}
