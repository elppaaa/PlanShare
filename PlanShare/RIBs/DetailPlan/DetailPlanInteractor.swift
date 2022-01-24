//
//  DetailPlanInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import CoreLocation
import RIBs
import RxSwift

// MARK: - DetailPlanRouting

protocol DetailPlanRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
  func routeToMarkedMap(location: CLLocationCoordinate2D)
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
  func dismissedChild()
  func routeToEditing(plan: Plan)
}

// MARK: - DetailPlanInteractor

final class DetailPlanInteractor: PresentableInteractor<DetailPlanPresentable>, DetailPlanInteractable, DetailPlanPresentableListener {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  init(
    presenter: DetailPlanPresentable,
    currentPlan: Plan
  )
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
    presenter.setData(plan: plan)
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: Private

  private let plan: Plan
}

// MARK: - DetailPlanPresentableListener

extension DetailPlanInteractor {
  func mapButtonTapped() {
    if let location = plan.place?.location {
      router?.routeToMarkedMap(location: location)
    }
  }

  func movingFromParent() {
    listener?.dismissedChild()
  }

  func editButtonTapped() {
    listener?.routeToEditing(plan: plan)
  }
}

// MARK: - ViewableRouting

extension DetailPlanInteractor {
  func dismissedChild() {
    router?.detachCurrentChild()
  }
}
