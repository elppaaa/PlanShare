//
//  GoogleMapLink.swift
//  PlanShare
//
//  Created by JK on 2022/01/24.
//

import Foundation

// MARK: - GoogleMapLink

struct GoogleMapLink {

  // MARK: Lifecycle

  init() {
    var components = URLComponents()
    if Constraints.isGoogleMapInstalled {
      components.scheme = Constraints.GOOGLEMAP_DEEPLINK
    } else {
      components.scheme = "https"
      components.host = Constraints.GOOGLEMAP_BASEURL
    }

    self.components = components
  }

  private init(_ components: URLComponents) {
    self.components = components
  }

  // MARK: Internal

  enum QueryKey: String {
    case center
    case q
  }

  let components: URLComponents

  var url: URL? {
    components.url
  }

  func query(key: QueryKey, value: String) -> GoogleMapLink {
    var components = components
    var items = components.queryItems ?? []
    items.append(URLQueryItem(name: key.rawValue, value: value))
    components.queryItems = items
    return GoogleMapLink(components)
  }
}
