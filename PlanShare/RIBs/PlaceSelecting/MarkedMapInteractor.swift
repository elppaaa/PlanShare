//
//  MarkedMapInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import CoreLocation
import RIBs
import RxSwift

// MARK: - MarkedMapRouting

protocol MarkedMapRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

// MARK: - MarkedMapPresentable

@MainActor
protocol MarkedMapPresentable: Presentable {
  var listener: MarkedMapPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
  func mark(location: CLLocationCoordinate2D)
}

// MARK: - MarkedMapListener

protocol MarkedMapListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
  func dismissedChild()
}

// MARK: - MarkedMapInteractor

final class MarkedMapInteractor: PresentableInteractor<MarkedMapPresentable>, MarkedMapInteractable, MarkedMapPresentableListener {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  init(presenter: MarkedMapPresentable, location: CLLocationCoordinate2D) {
    self.location = location
    super.init(presenter: presenter)
    Task(priority: .userInitiated) {
      await presenter.listener = self
    }
  }

  // MARK: Internal

  weak var router: MarkedMapRouting?
  weak var listener: MarkedMapListener?

  override func didBecomeActive() {
    super.didBecomeActive()
    // TODO: Implement business logic here.
    Task(priority: .userInitiated) {
      await presenter.mark(location: location)
    }
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: - MarkedMapPresentableListener

  func movingFromParent() {
    listener?.dismissedChild()
  }

  // MARK: Private

  private let location: CLLocationCoordinate2D
}
