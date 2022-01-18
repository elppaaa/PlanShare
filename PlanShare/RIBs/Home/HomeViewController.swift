//
//  HomeViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs
import RxCocoa
import RxRelay
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
    configTableView()
    bindings()
  }

  // MARK: Private

  private let tableView = UITableView()
  private let disposeBag = DisposeBag()
  private let plans = BehaviorRelay<[Plan]>(value: [])

  private func bindings() {
    plans
      .asDriver()
      .drive(tableView.rx.items(cellIdentifier: HomeTableViewCell.describe, cellType: HomeTableViewCell.self)) { _, element, cell in
        cell.set(plan: element)
      }
      .disposed(by: disposeBag)
  }
  
  private func configTableView() {
    tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.describe)
    tableView.rowHeight = 70
  }
}

// MARK: - HomePresentable

extension HomeViewController {
  func set(plans: [Plan]) {
    self.plans.accept(plans)
  }
}
