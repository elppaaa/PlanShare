//
//  PlaceSelectingInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import CoreLocation
import GooglePlaces
import RIBs
import RxRelay
import RxSwift

// MARK: - PlaceSelectingRouting

protocol PlaceSelectingRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
  func routeToMarkedMap(location: CLLocationCoordinate2D)
}

// MARK: - PlaceSelectingPresentable

@MainActor
protocol PlaceSelectingPresentable: Presentable {
  var listener: PlaceSelectingPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
}

// MARK: - PlaceSelectingListener

protocol PlaceSelectingListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
  func dismissedChild()
  func selectAndClose(place: Place)
}

// MARK: - PlaceSelectingPresentableOutput

protocol PlaceSelectingPresentableOutput {
  var searchResults: BehaviorRelay<[PlaceSearchResult]> { get }
}

// MARK: - PlaceSelectingInteractor

final class PlaceSelectingInteractor: PresentableInteractor<PlaceSelectingPresentable>, PlaceSelectingInteractable, PlaceSelectingPresentableListener {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  override init(presenter: PlaceSelectingPresentable) {
    super.init(presenter: presenter)
    Task(priority: .userInitiated) {
      await presenter.listener = self
    }
  }

  // MARK: Internal

  weak var router: PlaceSelectingRouting?
  weak var listener: PlaceSelectingListener?

  private(set) var searchResults = BehaviorRelay<[PlaceSearchResult]>(value: [])

  override func didBecomeActive() {
    super.didBecomeActive()
    // TODO: Implement business logic here.
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: Private

  private let googleAPISession = GMSAutocompleteSessionToken()

}

// MARK: - PlaceSelectingPresentableListener

extension PlaceSelectingInteractor {

  func movingFromParent() {
    listener?.dismissedChild()
  }

  func query(_ text: String) {
    Task(priority: .utility) {
      let place = await PlaceService.findPlaces(query: text, sessionToken: googleAPISession)
      if case .success(let place) = place {
        searchResults.accept(place)
      }
    }
  }

  func mapButtonTapped(index: Int) {
    let id = searchResults.value[index].id
    Task(priority: .utility) {
      let value = await PlaceService.getLocation(from: id, sessionToken: googleAPISession)
      if case .success(let value) = value {
        router?.routeToMarkedMap(location: value)
      }
    }
  }

  func selectPlace(index: Int) {
    let id = searchResults.value[index].id
    Task(priority: .utility) {
      let place = await PlaceService.place(from: id, sessionToken: googleAPISession)
      if case .success(let place) = place {
        listener?.selectAndClose(place: place)
      }
    }
  }
}

// MARK: PlaceSelectingPresentableOutput

extension PlaceSelectingInteractor: PlaceSelectingPresentableOutput {
  var output: PlaceSelectingPresentableOutput { self }
}

// MARK: - MarkedMapInteractable

extension PlaceSelectingInteractor {
  func dismissedChild() {
    router?.detachCurrentChild()
  }
}
