//
//  GooglePlaceImageCache.swift
//  PlanShare
//
//  Created by JK on 2022/01/30.
//

import _Concurrency
import Foundation
import GooglePlaces

// MARK: - GooglePlaceImageCache

actor GooglePlaceImageCache {

  // MARK: Internal

  func nameAndImage(id: String) async -> (title: String, image: UIImage?)? {
    if let (title, metadata) = try? await PlaceService.placePhotoInfo(from: id, sessionToken: session).get() {
      let image = try? await PlaceService.photo(from: metadata).get()
      cache[id] = (title, image)
      return (title, image)
    } else {
      return nil
    }
  }

  // MARK: Private

  private var cache = [String: (title: String, image: UIImage?)]()
  private let session = GMSAutocompleteSessionToken()
}
