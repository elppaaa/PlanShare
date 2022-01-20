//
//  MapViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import MapKit
import UIKit

final class MapViewController: UIViewController {

  // MARK: Lifecycle

  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }

  // MARK: Internal

  override func loadView() {
    super.loadView()
    view = mapView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setAnnotation()
  }

  // MARK: Private

  private let mapView = MKMapView()
  private let coordinate: CLLocationCoordinate2D

  private func setAnnotation() {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    mapView.addAnnotation(annotation)
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
    mapView.setRegion(region, animated: true)
  }
}
