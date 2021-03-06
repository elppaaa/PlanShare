//
//  PlanShareTests.swift
//  PlanShareTests
//
//  Created by JK on 2022/01/07.
//

import Alamofire
import CoreLocation
import FirebaseFirestore
import RxBlocking
import RxSwift
import XCTest
@testable import PlanShare

// MARK: - PlanShareTests

class PlanShareTests: XCTestCase {
  // 테스트 후 DB 삭제
  override func tearDownWithError() throws {
    let deletionRequest = try URLRequest(
      url: "http://localhost:8080/emulator/v1/projects/plan-share-d89cf/databases/(default)/documents",
      method: .delete,
      headers: nil
    )
    let expectation = expectation(description: "request finished")
    let request = URLSession.shared.dataTask(with: deletionRequest) { _, response, _ in
      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }
      expectation.fulfill()
    }
    request.resume()

    wait(for: [expectation], timeout: 3)
    try super.tearDownWithError()
  }

  func testAPIKEY() {
    debugPrint(Constraints.GCP_KEY)
    debugPrint(Constraints.KAKAO_KEY)
  }

//  func testPlanEncodable() {
//    let dateString = "2021-11-30 09:30:00"
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    guard let date = formatter.date(from: dateString) else {
//      XCTFail()
//      fatalError()
//    }
//    let place = Place(id: "testPlace", title: "testTitle", address: "testAddress", location: CLLocationCoordinate2D())
//    let plan = Plan.Upload(title: "testTitle", startAt: date, endAt: date, place: place, memo: "testMemo")
//
//    guard let serialized = plan.dict else {
//      XCTFail("Failed to serialized")
//      return
//    }
//
//    XCTAssert((serialized["title"] as? String) == "testTitle")
//    XCTAssert((serialized["startAt"] as? Timestamp) ?? Timestamp() == Timestamp(date: date))
//    XCTAssert((serialized["endAt"] as? Timestamp) ?? Timestamp() == Timestamp(date: date))
//    XCTAssert((serialized["startAt"] as? Timestamp)?.dateValue() ?? Date.now == date)
//    XCTAssert((serialized["endAt"] as? Timestamp)?.dateValue() ?? Date.now == date)
//    XCTAssert((serialized["memo"] as? String) ?? "" == plan.memo)
//    guard let serializedPlace = serialized["place"] as? [String: Any] else {
//      XCTFail("Place Serialized failed")
//      return
//    }
//
//    XCTAssert((serializedPlace["id"] as? String) ?? "" == place.id)
//    XCTAssert((serializedPlace["title"] as? String) ?? "" == place.title)
//    XCTAssert((serializedPlace["address"] as? String) ?? "" == place.address)
//  }

//  func testPlanDecodable() {
//    let dateString = "2021-11-30 09:30:00"
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    guard let date = formatter.date(from: dateString) else {
//      XCTFail()
//      fatalError()
//    }
//
//    var place = [String: Any]()
//    place["id"] = "placeID"
//    place["title"] = "placeTitle"
//    place["link"] = "placeLink"
//    place["address"] = "placeAddress"
//    place["memo"] = "placeMemo"
//
//    var plan = [String: Any]()
//    plan["id"] = "planID"
//    plan["title"] = "planTitle"
//    plan["startAt"] = Timestamp(date: date)
//    plan["endAt"] = Timestamp(date: date)
//    plan["place"] = place
//    plan["additionalPlaces"] = Array(repeating: place, count: 2)
//
//    guard let planObject = Plan.parse(from: plan) else {
//      XCTFail("Codable failed")
//      return
//    }
//
//    XCTAssert(planObject.id == "planID")
//    XCTAssert(planObject.title == "planTitle")
//    XCTAssert(planObject.startAt == date)
//    XCTAssert(planObject.endAt == date)
//    XCTAssert(planObject.memo == "placeMemo")
//    let _place = Place(id: "placeID", title: "placeTitle", link: "placeLink", address: "placeAddress")
//    XCTAssert(planObject.place == _place)
//    XCTAssert(planObject.additionalPlaces == Array(repeating: _place, count: 2))
//  }

//  func testConcurrencyWrite() throws {
//    runAsyncTest {
//      let value = Plan.Upload(title: "Title", startAt: Date.now, endAt: Date.now, place: Place(id: "new_id", title: "string", address: "address", location: CLLocationCoordinate2D()), memo: "memo")
//      let result = await FirebaseService.create(path: "Plan", data: value)
//
//      debugPrint(try result.get().documentID)
//
//      if case .failure(let err) = result {
//        XCTFail(err.localizedDescription)
//      }
//    }
//  }

  /// read / write with Firstore.Decoder() Firestore.Encoder()
  func testWriteAndRead() async throws {
    let dateString = "2021-11-30 09:30:00"
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let date = formatter.date(from: dateString) else {
      XCTFail()
      fatalError()
    }
    let plan = Plan.Upload(title: "title", startAt: date, endAt: date, place: Place(id: "id", title: "타이틀", address: "address", location: CLLocationCoordinate2D()), memo: "memo")

    let documentID = try await FirebaseService.planRef.new(document: plan).get().documentID

    let result: Plan = try await FirebaseService.planRef.get(id: documentID).get()

    XCTAssert(plan.title == result.title)
    XCTAssert(plan.startAt == result.startAt)
    XCTAssert(plan.place == result.place)
    XCTAssert(plan.memo == result.memo)
    XCTAssert(date == result.startAt)
    XCTAssert(date == result.endAt)
    XCTAssert(plan.additionalPlaces == result.additionalPlaces)
  }
}
