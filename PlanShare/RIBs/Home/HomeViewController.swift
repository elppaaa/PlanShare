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
  func newPlan()
  func deleteItem(index: Int)
  var output: HomePresentableOutput { get }
}

// MARK: - HomeViewController

@MainActor
final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {

  // MARK: Internal

  weak var listener: HomePresentableListener?

  override func viewDidLoad() {
    super.viewDidLoad()
    debugPrint("Init")
    bindings()
    configView()
  }

  // MARK: Private

  private let tableView = UITableView().then {
    $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.describe)
    $0.rowHeight = 70
  }
  private let newPlanButton = UIBarButtonItem(image: .init(systemName: "plus"), style: .plain, target: self, action: nil)

  private let disposeBag = DisposeBag()

  private let loadingView = UIActivityIndicatorView()

  private func configView() {
    view.backgroundColor = .systemBackground
    view.addSubview(tableView)
    tableView.frame = view.frame
    tableView.center = view.center
    navigationItem.rightBarButtonItem = newPlanButton
  }

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

    tableView.rx.itemDeleted
      .subscribe(onNext: { [weak self] indexPath in
        self?.listener?.deleteItem(index: indexPath.row)
      })
      .disposed(by: disposeBag)

    newPlanButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self?.listener?.newPlan()
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - HomePresentable
extension HomeViewController {
  func startLoading() {
    loadingView.frame.size = .init(width: 20, height: 20)
    loadingView.center = view.center
    view.addSubview(loadingView)
    loadingView.startAnimating()
  }

  func endLoading() {
    loadingView.removeFromSuperview()
    loadingView.stopAnimating()
  }
}

// MARK: - HomeViewControllable
extension HomeViewController {
  nonisolated func addChild(viewContronller: ViewControllable) {
    DispatchQueue.main.async {
      let vc = viewContronller.uiviewController
      self.addChild(vc)
      self.view.addSubview(vc.view)
      vc.didMove(toParent: self)
    }
  }
}
