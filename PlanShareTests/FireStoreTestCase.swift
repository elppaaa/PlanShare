//
//  FireStoreTestCase.swift
//  PlanShareTests
//
//  Created by JK on 2022/01/14.
//

import MapKit
import RxBlocking
import RxSwift
import XCTest
@testable import PlanShare

class FireStoreTestCase: XCTestCase {

  // MARK: Internal

  override func setUp() {
    disposeBag = DisposeBag()
    super.setUp()
  }

  override func tearDownWithError() throws {
    disposeBag = nil
//
//    let deletionRequest = try URLRequest(
//      url: "http://localhost:8080/emulator/v1/projects/plan-share-d89cf/databases/(default)/documents",
//      method: .delete,
//      headers: nil
//    )
//    let expectation = expectation(description: "request finished")
//    let request = URLSession.shared.dataTask(with: deletionRequest) { _, response, _ in
//      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }
//      expectation.fulfill()
//    }
//    request.resume()
//
//    wait(for: [expectation], timeout: 3)
    try super.tearDownWithError()
  }

  func testDBCreate() throws {
    let place = Place(id: "placeID", title: "placeTitle", address: "placeAddress", location: CLLocationCoordinate2D(latitude: 37.2654988, longitude: 127.0329044))
    let plan = Plan(title: "planTitle", startAt: Date(), endAt: Date(), place: place, memo: "planMemo")

    let result = try FirebaseService.create(path: "Plan", data: plan)
      .toBlocking(timeout: 4)
      .first()

    XCTAssert(result != nil)

  }

  func testDBRead() throws {
    var plan = createPlan()

    let createResult = try FirebaseService.create(path: "Plan", data: plan)
      .toBlocking(timeout: 3)
      .first()

    XCTAssert(createResult != nil)

    guard let id = createResult?.documentID else {
      XCTFail("Failed to get document ID")
      return
    }

    plan.id = id

    let readResult: Plan? = try FirebaseService.read(path: "Plan", id: id)
      .toBlocking(timeout: 3)
      .first()

    checkEqual(plan, readResult)
  }

  func testDBUpdate() throws {
    var plan = createPlan()
    let updateExpectation = expectation(description: "Failed to update")
    let createResult = try FirebaseService.create(path: "Plan", data: plan)
      .toBlocking(timeout: 3)
      .first()

    XCTAssert(createResult != nil)

    guard let id = createResult?.documentID else {
      XCTFail("Failed to get document ID")
      return
    }

    plan.id = id
    let newValue = "newTitle"
    plan.title = newValue

    let updateBlock = { (plan: Plan) -> [String: Any] in
      guard var dict = plan.dictionary else {
        return [:]
      }
      dict["title"] = newValue
      return dict
    }

    FirebaseService.update(path: "Plan", id: id, updateBlock: updateBlock)
      .subscribe(onCompleted: {
        updateExpectation.fulfill()
      })
      .disposed(by: disposeBag)
    wait(for: [updateExpectation], timeout: 3)

    let readResult: Plan? = try FirebaseService.read(path: "Plan", id: id)
      .toBlocking(timeout: 3)
      .first()

    checkEqual(plan, readResult)

  }

  func testDBDelete() throws {
    let errorExpectation = expectation(description: "해당 document 는 존재하지 않아야 합니다.")
    let deleteExpectation = expectation(description: "해당 document 는 삭제가 되지 않았습니다.")
    let plan = createPlan()

    let createResult = try FirebaseService.create(path: "Plan", data: plan)
      .toBlocking(timeout: 3)
      .first()

    XCTAssert(createResult != nil)

    guard let id = createResult?.documentID else {
      XCTFail("Failed to get document ID")
      return
    }

    FirebaseService.delete(path: "Plan", id: id)
      .subscribe(onCompleted: {
        deleteExpectation.fulfill()
      })
      .disposed(by: disposeBag)

    wait(for: [deleteExpectation], timeout: 3)

    let readObservable: Single<Plan> = FirebaseService.read(path: "Plan", id: id)

    readObservable
      .asObservable()
      .subscribe(
        onError: { e in
          debugPrint(e)
          errorExpectation.fulfill()
        })
      .disposed(by: disposeBag)

    wait(for: [errorExpectation], timeout: 5)
  }

  // MARK: Private

  private var disposeBag: DisposeBag!

  private func checkEqual(_ lhs: Plan?, _ rhs: Plan?) {
    XCTAssert(lhs?.id == rhs?.id)
    XCTAssert(lhs?.startAt == rhs?.startAt)
    XCTAssert(lhs?.memo == rhs?.memo)
    XCTAssert(lhs?.endAt == rhs?.endAt)
    XCTAssert(lhs?.place == rhs?.place)
    XCTAssert(lhs?.additionalPlaces == rhs?.additionalPlaces)
  }

  private func createPlan() -> Plan {
    let dateString = "2021-11-30 09:30:00"
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let date = formatter.date(from: dateString) else {
      XCTFail()
      fatalError()
    }

    let place = Place(id: "placeID", title: "placeTitle", address: "placeAddress", location: CLLocationCoordinate2D(latitude: 37.2654988, longitude: 127.0329044))
    let plan = Plan(title: "planTitle", startAt: date, endAt: date, place: place, memo: "planMemo")

    return plan
  }

}
