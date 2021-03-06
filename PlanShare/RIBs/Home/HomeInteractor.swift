//
//  HomeInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import CoreLocation
import Foundation
import RIBs
import RxCocoa
import RxRelay
import RxSwift

// MARK: - HomeRouting

protocol HomeRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
  func routeToDetailPlan(plan: Plan, model: PlanModel)
  func routeToNewPlan()
  func routeToHome()
  func routeToEditing(plan: Plan)
}

// MARK: - HomePresentable

@MainActor
protocol HomePresentable: Presentable {
  var listener: HomePresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
  func startLoading()
  func endLoading()
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
    Task(priority: .userInitiated) {
      await presenter.listener = self
    }
  }

  // MARK: Internal

  weak var router: HomeRouting?
  weak var listener: HomeListener?

  // MARK: HomePresentableOutput
  var plans = BehaviorRelay<[Plan]>(value: [])

  var output: HomePresentableOutput { self }

  override func didBecomeActive() {
    super.didBecomeActive()
    readAllPlans()
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: Private

  private func readAllPlans(useCache: Bool = false) {
    Task.detached(priority: .utility) {
      await self.presenter.startLoading()
      let planModels = PlanModel.readAll()
      switch planModels {
      case .success(let values):
        var plans = [Plan]()

        for model in values {
          let _result: Result<Plan, Error> = await FirebaseService.read(path: "Plan", id: model.planID)
          switch _result {
          case .success(let value):
            plans.append(value)
          case .failure(let err):
            if let err = err as? FirebaseService.Err, err == .serialized {
              let model = try? PlanModel.getBy(planID: model.planID).get()
              model?.delete()
            }
          }
        }
        self.sortAndAccept(plans: plans)

      // db read err
      case .failure(let err):
        Log.log(.error, category: .sqlite, "\(#function) \(err)")
      }
      await self.presenter.endLoading()
    }
  }

  private func appendPlan(plan: Plan) {
    var plans = plans.value
    if !plans.contains(where: { $0.id == plan.id }) {
      plans.append(plan)
    }
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
    if let id = plan.id, let model = try? PlanModel.getBy(planID: id).get() {
      router?.routeToDetailPlan(plan: plan, model: model)
    }
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
      Task(priority: .utility) {
        if let document = try? await FirebaseService.create(path: "Plan", data: plan).get() {

          let model = PlanModel(planID: document.documentID, eventIdentifier: "")
          model.prepare()
          if let error = model.write() {
            Log.log(.error, category: .sqlite, "\(#function):: \(error)")
          }
          var plan = plan
          plan.id = document.documentID
          self.appendPlan(plan: plan)
          self.router?.routeToHome()
        }
      }
    } else {
      Task(priority: .utility) {
        guard let id = plan.id else { return }
        if (try? await FirebaseService.update(path: "Plan", id: id, value: plan).get()) != nil {
          readAllPlans()
          router?.routeToHome()
        }
      }
    }
  }

  func deleteItem(index: Int) {
    Task.detached(priority: .utility) {
      var value = self.plans.value
      let plan = value.remove(at: index)
      self.plans.accept(value)
      if let id = plan.id {
        if (try? PlanModel.getBy(planID: id).get().delete()) != nil {
          Log.log(.debug, category: .sqlite, "Deletion Error")
        }
      }
    }
  }
}

// MARK: HomeActionableItem

extension HomeInteractor: HomeActionableItem {
  func getAndOpenPlan(id: String) -> Observable<(HomeActionableItem, ())> {
    .create { [weak self] subscriber in
      guard let self = self else { return Disposables.create() }
      Task(priority: .utility) {
        guard var plan: Plan = try? await FirebaseService.read(path: "Plan", id: id).get() else { return }
        plan.id = id
        self.appendPlan(plan: plan)
        let planModel = PlanModel(planID: id)
        planModel.prepare()
        planModel.write()

        if let model = try? PlanModel.getBy(planID: id).get() {
          self.router?.routeToDetailPlan(plan: plan, model: model)
        }

        subscriber.onNext((self, ()))
      }

      return Disposables.create()
    }
  }
}
