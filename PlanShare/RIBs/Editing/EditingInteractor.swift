//
//  EditingInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs
import RxSwift

// MARK: - EditingRouting

protocol EditingRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
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
}

// MARK: - EditingInteractor

final class EditingInteractor: PresentableInteractor<EditingPresentable>, EditingInteractable, EditingPresentableListener {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  init(presenter: EditingPresentable, plan: Plan?) {
    self.plan = plan
    super.init(presenter: presenter)
    presenter.listener = self
  }

  // MARK: Internal

  weak var router: EditingRouting?
  weak var listener: EditingListener?

  override func didBecomeActive() {
    super.didBecomeActive()
    // TODO: Implement business logic here.
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: Private

  private var plan: Plan?

}
