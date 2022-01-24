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
    case calendar

    // MARK: Internal

    @available(iOS 14.0, *)
    var logger: Logger {
      switch self {
      case .sqlite: return Log.sqlite
      case .firebase: return Log.firebase
      case .places: return Log.places
      case .calendar: return Log.calendar
      }
    }

    var osLog: OSLog {
      switch self {
      case .sqlite: return OSLog.sqlite
      case .firebase: return OSLog.firebase
      case .places: return OSLog.places
      case .calendar: return OSLog.calendar
      }
    }
  }

  @available(iOS 14.0, *)
  static let sqlite = Logger(subsystem: subsystem, category: "🥞 SQLite")
  @available(iOS 14.0, *)
  static let firebase = Logger(subsystem: subsystem, category: "🔥 FireBase")
  @available(iOS 14.0, *)
  static let places = Logger(subsystem: subsystem, category: "🗺 Places")
  @available(iOS 14.0, *)
  static let calendar = Logger(subsystem: subsystem, category: "🗓 Calendar")

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
  static let calendar = OSLog(subsystem: subsystem, category: "🗓 Calendar")

  // MARK: Private

  private static let subsystem = Bundle.main.bundleIdentifier!
}
