//
//  HomeViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs
import RxSwift
import UIKit

// MARK: - HomePresentableListener

protocol HomePresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
}

// MARK: - HomeViewController

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {

  // MARK: Internal

  weak var listener: HomePresentableListener?

  override func loadView() {
    super.loadView()
    view = tableView
    view.backgroundColor = .systemTeal
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    debugPrint("Init")
  }

  // MARK: Private

  private let tableView = UITableView()
}

// MARK: - HomePresentable

extension HomeViewController {
  // TODO: -  함수 구현 필요
  func set(plans _: [Plan]) {}
}
