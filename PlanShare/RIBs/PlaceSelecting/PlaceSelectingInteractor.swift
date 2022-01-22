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
    presenter.listener = self
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
    PlaceService.shared.findPlaces(query: text, sessionToken: googleAPISession)
      .subscribe(onSuccess: { [weak self] in
        self?.searchResults.accept($0)
      })
      .disposeOnDeactivate(interactor: self)
  }

  func mapButtonTapped(index: Int) {
    let id = searchResults.value[index].id
    PlaceService.shared.getLocation(from: id, sessionToken: googleAPISession)
      .subscribe(onSuccess: { [weak self] in
        self?.router?.routeToMarkedMap(location: $0)
      })
      .disposeOnDeactivate(interactor: self)
  }

  func selectPlace(index: Int) {
    let id = searchResults.value[index].id
    PlaceService.shared.place(from: id, sessionToken: googleAPISession)
      .subscribe(on: MainScheduler.instance)
      .subscribe(onSuccess: { [weak self] in
        self?.listener?.selectAndClose(place: $0)
      })
      .disposeOnDeactivate(interactor: self)
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
