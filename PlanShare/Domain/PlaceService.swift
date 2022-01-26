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

@MainActor
final class PlaceService {

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  enum PlaceError: Error {
    case failedToFind
  }

  static func findPlaces(query: String, currentPlace: CLLocation? = nil, sessionToken: GMSAutocompleteSessionToken? = nil) async -> Result<[PlaceSearchResult], PlaceError> {
    Log.log(.debug, category: .places, #function)
    return await withUnsafeContinuation { container in
      let filter = GMSAutocompleteFilter()
      filter.type = .establishment
      filter.origin = currentPlace

      client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { results, error in
        guard let results = results, error == nil else {
          let errMessage = "request failed \(error!.localizedDescription)"
          Log.log(.error, category: .places, errMessage)
          container.resume(returning: .failure(.failedToFind))
          return
        }

        let places = results.compactMap {
          PlaceSearchResult(id: $0.placeID, name: $0.attributedPrimaryText.string, secondary: $0.attributedSecondaryText?.string)
        }

        container.resume(returning: .success(places))
      }
    }
  }

  static func getLocation(from id: String, sessionToken: GMSAutocompleteSessionToken? = nil) async -> Result<CLLocationCoordinate2D, PlaceError> {
    Log.log(.debug, category: .places, #function)
    return await withUnsafeContinuation { container in
      self.client.fetchPlace(fromPlaceID: id, placeFields: .coordinate, sessionToken: sessionToken) { place, error in
        guard let place = place, error == nil else {
          let errMessage = "request failed \(error!.localizedDescription)"
          Log.log(.error, category: .places, errMessage)
          container.resume(returning: .failure(.failedToFind))
          return
        }

        container.resume(returning: .success(place.coordinate))
      }
    }
  }

  static func place(from id: String, sessionToken: GMSAutocompleteSessionToken? = nil) async -> Result<Place, PlaceError> {
    Log.log(.debug, category: .places, #function)
    let place = await placeInfo(from: id)
    switch place {
    case .success(let place):
      return .success(Place(id: id, title: place.name, address: place.address, location: place.location))
    case .failure(let error):
      return .failure(error)
    }
  }

  static func setUp() {
    GMSPlacesClient.provideAPIKey(Constraints.GCP_KEY)
  }

  static func placeInfo(from id: String) async -> Result<(name: String, address: String, location: CLLocationCoordinate2D), PlaceError> {
    Log.log(.debug, category: .places, #function)

    return await withUnsafeContinuation { container in
      self.client.fetchPlace(fromPlaceID: id, placeFields: [.coordinate, .name, .formattedAddress], sessionToken: nil) { place, error in
        guard let place = place, error == nil else {
          let errMessage = "request failed \(error!.localizedDescription)"
          Log.log(.error, category: .places, errMessage)
          container.resume(returning: .failure(.failedToFind))
          return
        }
        let result = (name: place.name ?? "", address: place.formattedAddress ?? "", location: place.coordinate)

        container.resume(returning: .success(result))
      }
    }
  }

  // MARK: Private

  @MainActor private static let client = GMSPlacesClient.shared()

}
