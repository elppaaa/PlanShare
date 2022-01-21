//
//  HomeInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import Foundation
import MapKit
import RIBs
import RxRelay
import RxSwift

// MARK: - HomeRouting

protocol HomeRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
  func routeToDetailPlan(plan: Plan)
  func routeToNewPlan()
  func routeToHome()
}

// MARK: - HomePresentable

protocol HomePresentable: Presentable {
  var listener: HomePresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
}

// MARK: - HomeListener

protocol HomeListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

// MARK: - HomePresentableOutput

protocol HomePresentableOutput {
  var plans: BehaviorRelay<[Plan]> { get }
}

// MARK: - HomeInteractor

final class HomeInteractor: PresentableInteractor<HomePresentable>, HomeInteractable, HomePresentableListener, HomePresentableOutput {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  override init(presenter: HomePresentable) {
    super.init(presenter: presenter)
    presenter.listener = self
  }

  // MARK: Internal

  weak var router: HomeRouting?
  weak var listener: HomeListener?

  // MARK: HomePresentableOutput
  var plans = BehaviorRelay<[Plan]>(value: [])

  var output: HomePresentableOutput { self }

  override func didBecomeActive() {
    super.didBecomeActive()
    // TODO: Implement business logic here.
    // TODO: - 데이터를 받아온 뒤 `Presentable.set(plans:)` 함수 호출 필요.
    plans.accept([Plan(title: "id", startAt: Date(), endAt: Date(), place: Place(id: "place", title: "place", address: "address", location: CLLocationCoordinate2D(latitude: 37.2654988, longitude: 127.0329044)), memo: "memo")])
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: - HomePresentableListener
  func planSelected(index: Int) {
    let plan = plans.value[index]
    router?.routeToDetailPlan(plan: plan)
  }
}

// MARK: - DetailPlanListener

extension HomeInteractor {
  func dismissedChild() {
    router?.detachCurrentChild()
  }

  func newPlan() {
    router?.routeToNewPlan()
  }
}

// MARK: - EditingListener

extension HomeInteractor {
  func routeToHome() {
    router?.routeToHome()
  }
}
