//
//  PlaceSelectingViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import RIBs
import RxSwift
import UIKit

// MARK: - PlaceSelectingPresentableListener

protocol PlaceSelectingPresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
}

// MARK: - PlaceSelectingViewController

final class PlaceSelectingViewController: UIViewController, PlaceSelectingPresentable, PlaceSelectingViewControllable {

  weak var listener: PlaceSelectingPresentableListener?
}
