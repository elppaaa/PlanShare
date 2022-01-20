//
//  ViewControllerable+Extension.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import Foundation
import RIBs

extension ViewControllable {
  func push(viewController: ViewControllable, animated: Bool = true) {
    uiviewController.navigationController?.pushViewController(viewController.uiviewController, animated: animated)
  }

  func present(viewController: ViewControllable, animated: Bool = true, completion: (() -> Void)? = nil) {
    uiviewController.present(viewController.uiviewController, animated: animated, completion: completion)
  }

  func popToSelf(animated: Bool = true) {
    uiviewController.navigationController?.popToViewController(uiviewController, animated: animated)
  }

  func popSelf(animated: Bool = true) {
    uiviewController.navigationController?.popViewController(animated: animated)
  }
}
