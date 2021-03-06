//
//  RootInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import Foundation
import RIBs
import RxSwift

// MARK: - RootRouting

protocol RootRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
  func routeToHome() -> HomeActionableItem
}

// MARK: - RootPresentable

protocol RootPresentable: Presentable {
  var listener: RootPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
}

// MARK: - RootListener

protocol RootListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

// MARK: - RootInteractor

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  override init(presenter: RootPresentable) {
    super.init(presenter: presenter)
    presenter.listener = self
  }

  // MARK: Internal

  weak var router: RootRouting?
  weak var listener: RootListener?

  override func didBecomeActive() {
    super.didBecomeActive()
    // TODO: Implement business logic here.
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }
}

// MARK: RootActionableItem

extension RootInteractor: RootActionableItem {
  func routeToHome() -> Observable<(HomeActionableItem, ())> {
    let item = router!.routeToHome()
    return .just((item, ()))
  }
}

// MARK: URLHandler

extension RootInteractor: URLHandler {
  func handle(_ url: URL) {
    let workflow = GetPlanWorkflow(url: url)

    workflow
      .subscribe(self)
      .disposeOnDeactivate(interactor: self)
  }
}
