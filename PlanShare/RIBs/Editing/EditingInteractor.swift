//
//  EditingInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import Foundation
import RIBs
import RxSwift
import SwiftUI

// MARK: - EditingRouting

protocol EditingRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
  func routeToPlace(isAdditionalPlace: Bool)
  func popAndDetach()
}

// MARK: - EditingPresentable

@MainActor
protocol EditingPresentable: Presentable {
  var listener: EditingPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
  func setView(with plan: Plan)
}

// MARK: - EditingListener

protocol EditingListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
  func routeToHome()
  func appendAndClose(plan: Plan, isNew: Bool)
}

// MARK: - EditingInteractor

final class EditingInteractor: PresentableInteractor<EditingPresentable>, EditingInteractable, EditingPresentableListener {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  init(presenter: EditingPresentable, plan: Plan?) {
    if let plan = plan {
      self.plan = plan
      isNew = false
    } else {
      self.plan = Plan.empty
      isNew = true
    }
    super.init(presenter: presenter)
    Task(priority: .userInitiated) {
      await presenter.listener = self
    }
  }

  // MARK: Internal

  weak var router: EditingRouting?
  weak var listener: EditingListener?

  override func didBecomeActive() {
    super.didBecomeActive()
    // TODO: Implement business logic here.
    setCurrentView()
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: Private

  private let isNew: Bool

  private var plan: Plan
}

// MARK: - EditingPresentableListener

extension EditingInteractor {

  // MARK: Internal

  func setTitle(_ text: String) {
    plan.title = text
  }

  func setMemo(_ text: String) {
    plan.memo = text
  }

  func setStartAt(_ date: Date) {
    plan.startAt = date
  }

  func setEndAt(_ date: Date) {
    plan.endAt = date
  }

  func getPlace() {
    router?.routeToPlace(isAdditionalPlace: false)
  }

  func movingFromParent() {
    listener?.routeToHome()
  }

  func save() {
    listener?.appendAndClose(plan: plan, isNew: isNew)
  }

  func additionalAddButtonTapped() {
    router?.routeToPlace(isAdditionalPlace: true)
  }

  // MARK: Private

  private func setCurrentView() {
    Task(priority: .userInitiated) {
      await presenter.setView(with: plan)
    }
  }
}

// MARK: - PlaceSelectingListener

extension EditingInteractor {
  func dismissedChild() {
    router?.detachCurrentChild()
  }
}

// MARK: - PlaceSelectingListener

extension EditingInteractor {
  func selectAndClose(place: Place, isAdditionalPlace: Bool) {
    if isAdditionalPlace {
      plan.additionalPlaces.append(place)
    } else {
      plan.place = place
    }
    setCurrentView()
    router?.popAndDetach()
  }
}
