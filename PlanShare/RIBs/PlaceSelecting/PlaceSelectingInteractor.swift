//
//  PlaceSelectingInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs
import RxSwift

// MARK: - PlaceSelectingRouting

protocol PlaceSelectingRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

// MARK: - PlaceSelectingPresentable

protocol PlaceSelectingPresentable: Presentable {
  var listener: PlaceSelectingPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
}

// MARK: - PlaceSelectingListener

protocol PlaceSelectingListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

// MARK: - PlaceSelectingInteractor

final class PlaceSelectingInteractor: PresentableInteractor<PlaceSelectingPresentable>, PlaceSelectingInteractable, PlaceSelectingPresentableListener {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  override init(presenter: PlaceSelectingPresentable) {
    super.init(presenter: presenter)
    presenter.listener = self
  }

  // MARK: Internal

  weak var router: PlaceSelectingRouting?
  weak var listener: PlaceSelectingListener?

  override func didBecomeActive() {
    super.didBecomeActive()
    // TODO: Implement business logic here.
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }
}
