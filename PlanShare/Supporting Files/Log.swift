//
//  Log.swift
//  PlanShare
//
//  Created by JK on 2022/01/23.
//

import Foundation
import OSLog

// MARK: - Log

final class Log {

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  enum Category {
    case sqlite
    case firebase
    case places

    // MARK: Internal

    @available(iOS 14.0, *)
    var logger: Logger {
      switch self {
      case .sqlite: return Log.sqlite
      case .firebase: return Log.firebase
      case .places: return Log.places
      }
    }

    var osLog: OSLog {
      switch self {
      case .sqlite: return OSLog.sqlite
      case .firebase: return OSLog.firebase
      case .places: return OSLog.places
      }
    }
  }

  @available(iOS 14.0, *)
  static let sqlite = Logger(subsystem: subsystem, category: "🥞 SQLite")
  @available(iOS 14.0, *)
  static let firebase = Logger(subsystem: subsystem, category: "🔥 FireBase")
  @available(iOS 14.0, *)
  static let places = Logger(subsystem: subsystem, category: "🗺 Places")

  static func log(_ level: OSLogType, category: Category, _ message: String) {
    if #available(iOS 14, *) {
      let logger = category.logger
      logger.log(level: level, "\(message)")
    } else {
      os_log(level, log: category.osLog, "%@", message)
    }
  }

  // MARK: Private

  private static let subsystem = Bundle.main.bundleIdentifier!
}

extension OSLog {

  // MARK: Internal

  static let sqlite = OSLog(subsystem: subsystem, category: "🥞 SQLite")
  static let firebase = OSLog(subsystem: subsystem, category: "🔥 FireBase")
  static let places = OSLog(subsystem: subsystem, category: "🗺 Places")

  // MARK: Private

  private static let subsystem = Bundle.main.bundleIdentifier!
}
