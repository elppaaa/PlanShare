//
//  PlaceService.swift
//  PlanShare
//
//  Created by JK on 2022/01/20.
//

import CoreLocation
import Foundation
import GooglePlaces
import RxSwift

final class PlaceService {

  // MARK: Lifecycle

  private init() { setUp() }

  // MARK: Internal

  enum PlaceError: Error {
    case failedToFind
  }

  static let shared = PlaceService()

  func findPlaces(query: String, currentPlace: CLLocation? = nil, sessionToken: GMSAutocompleteSessionToken? = nil) -> Single<[PlaceSearchResult]> {
    Log.log(.debug, category: .places, #function)

    return .create { subscriber in
      let filter = GMSAutocompleteFilter()
      filter.type = .establishment
      filter.origin = currentPlace

      self.client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { results, error in
        guard let results = results, error == nil else {
          let errMessage = "request failed \(error!.localizedDescription)"
          Log.log(.error, category: .places, errMessage)
          subscriber(.failure(PlaceError.failedToFind))
          return
        }

        let places = results.compactMap {
          PlaceSearchResult(id: $0.placeID, name: $0.attributedPrimaryText.string, secondary: $0.attributedSecondaryText?.string)
        }

        subscriber(.success(places))
      }

      return Disposables.create()
    }
  }

  func getLocation(from id: String, sessionToken: GMSAutocompleteSessionToken? = nil) -> Single<CLLocationCoordinate2D> {
    Log.log(.debug, category: .places, #function)

    return .create { subscriber in
      self.client.fetchPlace(fromPlaceID: id, placeFields: .coordinate, sessionToken: sessionToken) { place, error in
        guard let place = place, error == nil else {
          let errMessage = "request failed \(error!.localizedDescription)"
          Log.log(.error, category: .places, errMessage)
          subscriber(.failure(PlaceError.failedToFind))
          return
        }

        subscriber(.success(place.coordinate))
      }
      return Disposables.create()
    }
  }

  func place(from id: String, sessionToken: GMSAutocompleteSessionToken? = nil) -> Single<Place> {
    Log.log(.debug, category: .places, #function)
    return placeInfo(from: id)
      .map { Place(id: id, title: $0.name, address: $0.address, location: $0.location) }
  }

  func setUp() {
    GMSPlacesClient.provideAPIKey(Constraints.GCP_KEY)
  }

  // MARK: Private

  private lazy var client = GMSPlacesClient.shared()

  private func placeInfo(from id: String) -> Single<(name: String, address: String, location: CLLocationCoordinate2D)> {
    Log.log(.debug, category: .places, #function)

    return .create { subscriber in
      self.client.fetchPlace(fromPlaceID: id, placeFields: [.coordinate, .name, .formattedAddress], sessionToken: nil) { place, error in
        guard let place = place, error == nil else {
          let errMessage = "request failed \(error!.localizedDescription)"
          Log.log(.error, category: .places, errMessage)
          subscriber(.failure(PlaceError.failedToFind))
          return
        }

        subscriber(.success((
          name: place.name ?? "",
          address: place.formattedAddress ?? "",
          location: place.coordinate
        )))
      }
      return Disposables.create()
    }
  }

}
