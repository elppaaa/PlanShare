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
  func routeToEditing(plan: Plan)
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
    readAllPlans()
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: Private

  private func readAllPlans(useCache: Bool = false) {
    let planModels = PlanModel.readAll()
    if let plans = try? planModels.get().map({ $0.planID }) {
      Log.log(.debug, category: .firebase, "Plans: \(plans)")
    }

    switch planModels {
    case .success(let values):
      Single<Plan?>.zip( values.map { plan in
        FirebaseService.read(path: "Plan", id: plan.planID)
          .do(onError: {
            if let error = $0 as? FirebaseService.Err, error == .serialized {
              PlanModel.deleteBy(planID: plan.planID)
            } else {
              Log.log(.error, category: .sqlite, "\(#function) \($0)")
            }
          })
          .catchAndReturn(nil)
      })
      .map { $0.compactMap { $0 } }
      .subscribe(onSuccess: { [weak self] in
        self?.sortAndAccept(plans: $0)
      })
      .disposeOnDeactivate(interactor: self)
//      guard values.count > 0 else { return }
//      FirebaseService.readByIDs(path: "Plan", list: values.map { $0.planID }, useCache: useCache)
//        .subscribe(onSuccess: { [weak self] in
//          self?.plans.accept($0)
//        })
//        .disposeOnDeactivate(interactor: self)
    case .failure(let error):
      Log.log(.error, category: .sqlite, "\(#function) \(error)")
    }
  }

  private func appendPlan(plan: Plan) {
    var plans = plans.value
    plans.append(plan)
    sortAndAccept(plans: plans)
  }

  private func sortAndAccept(plans: [Plan]) {
    self.plans.accept(plans.sorted { $0.startAt < $1.startAt })
  }
}
// MARK: - HomePresentableListener

extension HomeInteractor {
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

  func routeToEditing(plan: Plan) {
    router?.detachCurrentChild()
    router?.routeToEditing(plan: plan)
  }
}

// MARK: - EditingListener

extension HomeInteractor {
  func routeToHome() {
    router?.routeToHome()
  }

  func appendAndClose(plan: Plan, isNew: Bool) {
    if isNew {
      FirebaseService.create(path: "Plan", data: plan)
        .observe(on: MainScheduler.instance)
        .subscribe(onSuccess: { [weak self] document in
          let model = PlanModel(planID: document.documentID, eventIdentifier: "")
          model.prepare()
          if let error = model.write() {
            Log.log(.error, category: .sqlite, "\(#function):: \(error)")
          }
          self?.appendPlan(plan: plan)
          self?.router?.routeToHome()
        })
        .disposeOnDeactivate(interactor: self)
    } else {
      guard let id = plan.id else { return }
      FirebaseService.update(path: "Plan", id: id, value: plan)
        .observe(on: MainScheduler.instance)
        .subscribe(onCompleted: { [weak self] in
          self?.readAllPlans()
          self?.router?.routeToHome()
        })
        .disposeOnDeactivate(interactor: self)
    }
  }

  func deleteItem(index: Int) {
    var value = plans.value
    let plan = value.remove(at: index)
    plans.accept(value)
    if let id = plan.id {
      PlanModel.deleteBy(planID: id)
    }
  }
}
