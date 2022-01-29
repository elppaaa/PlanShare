//
//  PlaceService.swift
//  PlanShare
//
//  Created by JK on 2022/01/20.
//

import CloudKit
import CoreGraphics
import CoreLocation
import Foundation
import GooglePlaces
import RxSwift
import UIKit.UIImage

@MainActor
final class PlaceService {

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  enum PlaceError: Error {
    case failedToFind
    case failedToRequest
  }

  static func findPlaces(query: String, sessionToken: GMSAutocompleteSessionToken? = nil) async -> Result<[PlaceSearchResult], PlaceError> {
    Log.log(.debug, category: .places, #function)
    return await withUnsafeContinuation { container in
      let filter = GMSAutocompleteFilter()
      filter.type = .establishment

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

//  static func photo(from id: String, sessionToken: GMSAutocompleteSessionToken? = nil, size: CGSize? = nil, scale: CGFloat? = nil) async -> Result<UIImage, PlaceError> {
//    switch await placePhotoInfo(from: id, sessionToken: sessionToken) {
//    case .success(let metadata):
//      return await _photo(from: metadata, size: size, scale: scale)
//
//    case .failure(let err):
//      return .failure(err)
//    }
//  }

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

  static func photo(from metadata: GMSPlacePhotoMetadata, size: CGSize? = nil, scale: CGFloat? = nil) async -> Result<UIImage, PlaceError> {
    await withUnsafeContinuation{ continuation in

      let callback: GMSPlacePhotoImageResultCallback = { image, error in
        if let error = error {
          Log.log(.error, category: .places, error.localizedDescription)
          continuation.resume(returning: .failure(.failedToRequest))
        } else if let image = image {
          continuation.resume(returning: .success(image))
        } else {
          continuation.resume(returning: .failure(.failedToFind))
        }
      }

      if let size = size {
        let scale = scale ?? 1.0
        self.client.loadPlacePhoto(metadata, constrainedTo: size, scale: scale, callback: callback)
      } else {
        self.client.loadPlacePhoto(metadata, callback: callback)
      }
    }
  }

  static func placePhotoInfo(from id: String, sessionToken: GMSAutocompleteSessionToken? = nil) async -> Result<(String, GMSPlacePhotoMetadata?), PlaceError> {
    Log.log(.debug, category: .places, #function)
    return await withUnsafeContinuation { continuation in
      self.client.fetchPlace(fromPlaceID: id, placeFields: [.name, .photos], sessionToken: sessionToken) { place, error in
        guard
          let place = place,
          let name = place.name,
          error == nil else
        {
          let errMessage = "request failed \(error!.localizedDescription)"
          Log.log(.error, category: .places, errMessage)
          continuation.resume(returning: .failure(.failedToFind))
          return
        }
        let metadata = place.photos?.first

        continuation.resume(returning: .success((name, metadata)))
      }
    }
  }

  // MARK: Private

  private static let client = GMSPlacesClient.shared()

}
