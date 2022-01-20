//
//  MarkedMapViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import MapKit
import RIBs
import RxSwift
import UIKit

// MARK: - MarkedMapPresentableListener

protocol MarkedMapPresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
  func movingFromParent()
}

// MARK: - MarkedMapViewController

final class MarkedMapViewController: UIViewController, MarkedMapPresentable, MarkedMapViewControllable {

  // MARK: Internal

  weak var listener: MarkedMapPresentableListener?

  override func loadView() {
    super.loadView()
    view = mapView
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isMovingFromParent {
      listener?.movingFromParent()
    }
  }

  // MARK: Private

  private let mapView = MKMapView()
}

// MARK: - MarkedMapPresentable

extension MarkedMapViewController {
  func mark(location: CLLocationCoordinate2D) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = location
    mapView.addAnnotation(annotation)
    let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
    mapView.setRegion(region, animated: true)
  }
}
