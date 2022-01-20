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
import Then
import UIKit

// MARK: - HomePresentableListener

protocol HomePresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
  func planSelected(index: Int)
  var output: HomePresentableOutput { get }
}

// MARK: - HomeViewController

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {

  // MARK: Internal

  weak var listener: HomePresentableListener?

  override func viewDidLoad() {
    super.viewDidLoad()
    debugPrint("Init")
    bindings()
    view.backgroundColor = .systemBackground
    view.addSubview(tableView)
    tableView.frame = view.frame
    tableView.center = view.center
  }

  // MARK: Private

  private let tableView = UITableView().then {
    $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.describe)
    $0.rowHeight = 70
  }

  private let disposeBag = DisposeBag()

  private func bindings() {
    guard let output = listener?.output else { return }

    output.plans
      .asDriver()
      .drive(tableView.rx.items(cellIdentifier: HomeTableViewCell.describe, cellType: HomeTableViewCell.self)) { _, element, cell in
        cell.set(plan: element)
      }
      .disposed(by: disposeBag)

    tableView.rx.itemSelected
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] indexPath in
        self?.listener?.planSelected(index: indexPath.row)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - HomePresentable
extension HomeViewController { }

// MARK: - HomeViewControllable
extension HomeViewController {
  func addChild(viewContronller: ViewControllable) {
    let vc = viewContronller.uiviewController
    addChild(vc)
    view.addSubview(vc.view)
    vc.didMove(toParent: self)
  }
}
