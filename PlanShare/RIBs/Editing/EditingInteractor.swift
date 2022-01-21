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
  func routeToPlace()
}

// MARK: - EditingPresentable

protocol EditingPresentable: Presentable {
  var listener: EditingPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
  func setView(with plan: Plan)
}

// MARK: - EditingListener

protocol EditingListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
  func routeToHome()
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
    presenter.listener = self
  }

  // MARK: Internal

  weak var router: EditingRouting?
  weak var listener: EditingListener?

  override func didBecomeActive() {
    super.didBecomeActive()
    // TODO: Implement business logic here.
    presenter.setView(with: plan)
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
    router?.routeToPlace()
  }

  func movingFromParent() {
    listener?.routeToHome()
  }

  func save() {
    if isNew {
      FirebaseService.create(path: "Plan", data: plan)
        .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onSuccess: { [weak self] document in
          UserDefaults.idList.insert(document.documentID)

          self?.listener?.routeToHome()
        })
        .disposeOnDeactivate(interactor: self)
    } else {
      guard let id = plan.id else { return }
      FirebaseService.update(path: "Plan", id: id, value: plan)
        .subscribe(onCompleted: { [weak self] in
          self?.listener?.routeToHome()
        })
        .disposeOnDeactivate(interactor: self)
    }
  }
}

// MARK: - PlaceSelectingListener

extension EditingInteractor {
  func dismissedChild() {
    router?.detachCurrentChild()
  }
}
