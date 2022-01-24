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

final class CalendarService {

  // MARK: Lifecycle

  private init() {

  }

  // MARK: Internal

  static let shared = CalendarService()

  let store = EKEventStore()

  func newEvent(plan: Plan, calendar: EKCalendar? = nil) -> Single<String> {
    access()
      .flatMap { boolean in
        if !boolean { return .error(CalenderServiceError.accessDenied) }

        switch self._newEvent(plan: plan, calendar: calendar) {
        case .success(let value):
          return .just(value)
        case .failure(let error):
          Log.log(.error, category: .calendar, error.localizedDescription)
          return .error(error)
        }
      }
  }

  func updateEvent(identifier: String, calendar: EKCalendar? = nil, plan: Plan) -> Maybe<String> {
    access()
      .flatMapMaybe{
        if !$0 { return .error(CalenderServiceError.accessDenied) }
        switch self._updateEvent(identifier: identifier, calendar: calendar, plan: plan) {
        // 등록 후에 사용자가 이벤트를 삭제한 경우 해당 이벤트가 없을 수 있음.
        case .failure(let error) where (error as? CalenderServiceError) == .eventNotFound:
          return self.newEvent(plan: plan)
            .asMaybe()
        case .failure(let error):
          return .error(error)
        case .success:
          return .empty()
        }
      }

//      .flatMapCompletable {
//
//        switch self._updateEvent(identifier: identifier, calendar: calendar, plan: plan) {
//        case .success:
//          return .empty()
//        case .failure(let error):
//          return .error(error)
//        }
//      }
  }

  // MARK: Private

  private func _updateEvent(identifier: String, calendar: EKCalendar? = nil, plan: Plan) -> Result<Void, Error> {
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

  private func _newEvent(plan: Plan, calendar: EKCalendar? = nil) -> Result<String, Error> {
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
      return .failure(error)
    }
  }
  private func access() -> Single<Bool> {
    .create { subscriber in
      self.store.requestAccess(to: .event) { bool, error in
        if let error = error {
          Log.log(.info, category: .calendar, "\(error)")
          subscriber(.failure(error))
        }

        if bool == false {
          Log.log(.info, category: .calendar, "Calendar Access Denied")
        }

        subscriber(.success(bool))
      }

      return Disposables.create()
    }
  }
}

// MARK: - CalenderServiceError

enum CalenderServiceError: Error {
  case accessDenied
  case eventNotFound
}
