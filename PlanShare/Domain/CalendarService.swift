//
//  CalendarService.swift
//  PlanShare
//
//  Created by JK on 2022/01/24.
//

import EventKit
import Foundation
import MapKit
import RxSwift

// MARK: - CalendarService

@globalActor
final actor CalendarService {

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  static let shared = CalendarService()

  let store = EKEventStore()

  func newEvent(plan: Plan, calendar: EKCalendar? = nil) async -> Result<String, Error> {
    guard let bool = try? await access().get(), bool == true else {
      return .failure(CalenderServiceError.accessDenied)
    }

    let event = EKEvent(eventStore: store)
    event.title = plan.title
    event.startDate = plan.startAt
    event.endDate = plan.endAt
    event.calendar = calendar ?? store.defaultCalendarForNewEvents
    event.notes = plan.memo
    if let place = plan.place {
      event.structuredLocation = .init(title: place.address)
    }

    do {
      try store.save(event, span: .thisEvent, commit: true)
      return .success(event.eventIdentifier)
    } catch {
      Log.log(.error, category: .calendar, error.localizedDescription)
      return .failure(error)
    }
  }

  func updateEvent(identifier: String, calendar: EKCalendar? = nil, plan: Plan) async -> Result<String?, Error> {
    guard let bool = try? await access().get(), bool == true else {
      return .failure(CalenderServiceError.accessDenied)
    }

    switch await _updateEvent(identifier: identifier, calendar: calendar, plan: plan) {
    // 등록 후에 사용자가 이벤트를 삭제한 경우 해당 이벤트가 없을 수 있음.
    case .failure(let error) where (error as? CalenderServiceError) == .eventNotFound:
      return await newEvent(plan: plan)
        .map { $0 }
    case .failure(let err):
      return .failure(err)
    case .success:
      return .success(nil)
    }
  }

  // MARK: Private

  private func _updateEvent(identifier: String, calendar: EKCalendar? = nil, plan: Plan) async -> Result<Void, Error> {
    guard let event = store.event(withIdentifier: identifier) else {
      return .failure(CalenderServiceError.eventNotFound)
    }

    event.title = plan.title
    event.startDate = plan.startAt
    event.endDate = plan.endAt
    event.notes = plan.memo
    if let place = plan.place {
      event.structuredLocation = .init(title: place.address)
    }
    do {
      try store.save(event, span: .thisEvent, commit: true)
      return .success(())
    } catch {
      return .failure(error)
    }
  }

  private func access() async -> Result<Bool, Error> {
    await withUnsafeContinuation { container in
      self.store.requestAccess(to: .event) { bool, error in
        if let error = error {
          Log.log(.info, category: .calendar, "\(error)")
          container.resume(returning: .failure(error))
        }

        if bool == false {
          Log.log(.info, category: .calendar, "Calendar Access Denied")
        }

        container.resume(returning: .success(bool))
      }
    }
  }
}

// MARK: - CalenderServiceError

enum CalenderServiceError: Error {
  case accessDenied
  case eventNotFound
}
