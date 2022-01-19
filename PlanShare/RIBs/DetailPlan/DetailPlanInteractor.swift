//
//  DetailPlanInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs
import RxSwift

// MARK: - DetailPlanRouting

protocol DetailPlanRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

// MARK: - DetailPlanPresentable

protocol DetailPlanPresentable: Presentable {
  var listener: DetailPlanPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
  func setData(plan: Plan)
}

// MARK: - DetailPlanListener

protocol DetailPlanListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

// MARK: - DetailPlanInteractor

final class DetailPlanInteractor: PresentableInteractor<DetailPlanPresentable>, DetailPlanInteractable, DetailPlanPresentableListener {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  init(
    presenter: DetailPlanPresentable,
    currentPlan: Plan)
  {
    plan = currentPlan
    super.init(presenter: presenter)
    presenter.listener = self
  }

  // MARK: Internal

  weak var router: DetailPlanRouting?
  weak var listener: DetailPlanListener?

  override func didBecomeActive() {
    super.didBecomeActive()
    // TODO: Implement business logic here.
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: Private

  private let plan: Plan
}
