//
//  DetailPlanViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import FlexLayout
import PinLayout
import RIBs
import RxSwift
import UIKit
import MapKit

// MARK: - DetailPlanPresentableListener

protocol DetailPlanPresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
  func mapButtonTapped(location: CLLocationCoordinate2D)
}

// MARK: - DetailPlanViewController

final class DetailPlanViewController: UIViewController, DetailPlanPresentable, DetailPlanViewControllable {

  // MARK: Internal

  weak var listener: DetailPlanPresentableListener?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(container)
    configView()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    view.pin.top()
    container.pin.horizontally().margin(view.pin.safeArea)
    container.flex.layout()
  }

  // MARK: Private

  private let container = UIView()

  private func configView() {
    view.isOpaque = true
    view.layer.opacity = 0.3
    view.layer.backgroundColor = UIColor.systemGray.cgColor

    container.flex.define {
      $0.addItem().size(100).backgroundColor(.systemTeal)
    }
  }
}

// MARK: - DetailPlanPresentable
extension DetailPlanViewController {
  func setData(plan: Plan) {

  }
}
