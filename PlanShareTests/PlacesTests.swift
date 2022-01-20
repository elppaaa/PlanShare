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

  var service: PlaceService!

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    service = PlaceService.shared
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    service = nil
  }

  func testPlaceSearch() throws {
    let query = "스타벅스 수원"

    let results: [PlaceSearchResult]? = try service.findPlaces(query: query)
      .toBlocking()
      .first()

    debugPrint(results)

    XCTAssert(results != nil)
  }

  func testGetPlace() throws {
    let query = "ChIJc2FdlltDezUR8lMufmz_Yqk"

    let results: Place? = try service.place(from: query)
      .toBlocking()
      .first()

    debugPrint(results)

    XCTAssert(results != nil)
  }

}
