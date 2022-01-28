//
//  PlacesTests.swift
//  PlanShareTests
//
//  Created by JK on 2022/01/20.
//

import RxBlocking
import RxSwift
import XCTest
@testable import PlanShare

class PlacesTests: XCTestCase {

  func testPlaceSearch() async throws {
    let query = "Starbucks"

    let results: [PlaceSearchResult] = try await PlaceService.findPlaces(query: query).get()

    XCTAssert(results != [])
  }

  func testGetPlace() async throws {
    let query = "ChIJc2FdlltDezUR8lMufmz_Yqk"

    let _: Place = try await PlaceService.place(from: query).get()
  }
}
