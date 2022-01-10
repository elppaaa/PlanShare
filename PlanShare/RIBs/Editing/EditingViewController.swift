//
//  EditingViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs
import RxSwift
import UIKit

// MARK: - EditingPresentableListener

protocol EditingPresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
}

// MARK: - EditingViewController

final class EditingViewController: UIViewController, EditingPresentable, EditingViewControllable {

  weak var listener: EditingPresentableListener?
}
