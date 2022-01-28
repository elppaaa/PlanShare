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
  nonisolated static var service: SQLiteService { get }
  nonisolated static var createQuery: String { get }
  nonisolated static var insertQuery: String { get }
  nonisolated static var selectAllQuery: String { get }
  nonisolated static var readingBlock: (OpaquePointer?) -> Self { get }
  nonisolated static var db: String { get }
  var writingBlock: (OpaquePointer?) throws -> Void { get }
  var id: Int? { get }
}

extension SQLiteEnable {

  static var service: SQLiteService {
    get { .shared }
    set { .shared = newValue }
  }

//  static func readAll<T>(readingBlock: (OpaquePointer?) -> T) -> Result<[T], SQLiteError> {
//    SQLiteService.shared.readAll(query: Self.selectAllQuery, blocks: readingBlock)
//  }

  static func readAll() -> Result<[Self], SQLiteError> {
    Self.service.openDB(createQuery: createQuery)
    return SQLiteService.shared.readAll(query: selectAllQuery, blocks: readingBlock)
  }

  func prepare() {
    Self.service.openDB(createQuery: Self.createQuery)
  }

  @discardableResult
  func write() -> SQLiteError? {
    Self.service.write(query: Self.insertQuery, block: writingBlock)
  }

  @discardableResult
  func delete() -> SQLiteError? {
    guard let id = id else { return .idIsEmpty }
    let deleteQuery = "DELETE FROM \(Self.db) WHERE id = '\(id)'"

    return Self.service.delete(query: deleteQuery, id: id)
  }

  func bind_text(stmt: OpaquePointer?, index: Int, value: String) throws {
    if sqlite3_bind_text(stmt, Int32(index), value.trimmingCharacters(in: .whitespacesAndNewlines), -1, Self.service.SQLITE_TRANSIENT) != SQLITE_OK {
      Log.log(.error, category: .sqlite, "Failed to bind \(value)")
      throw SQLiteError.failedToBind
    }
  }

  func bind_int(stmt: OpaquePointer?,index: Int, value: Int) throws {
    if sqlite3_bind_int(stmt, Int32(index), Int32(value)) != SQLITE_OK {
      Log.log(.error, category: .sqlite, "Failed to bind \(value)")
      throw SQLiteError.failedToBind
    }
  }

  func bind_double(stmt: OpaquePointer?,index: Int, value: Double) throws {
    if sqlite3_bind_double(stmt, Int32(index), value) != SQLITE_OK {
      Log.log(.error, category: .sqlite, "Failed to bind \(value)")
      throw SQLiteError.failedToBind
    }
  }
}
