//
//  RootViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs
import RxSwift
import UIKit

// MARK: - RootPresentableListener

protocol RootPresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
}

// MARK: - RootViewController

final class RootViewController: UINavigationController, RootPresentable, RootViewControllable {
  weak var listener: RootPresentableListener?
}

// MARK: - RootViewControllable

extension RootViewController {
  func push(viewController: ViewControllable, animated: Bool = true) {
    pushViewController(viewController.uiviewController, animated: animated)
  }
}
