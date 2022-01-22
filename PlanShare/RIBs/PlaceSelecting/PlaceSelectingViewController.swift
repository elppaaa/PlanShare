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
  func movingFromParent()
  func query(_ text: String)
  func mapButtonTapped(index: Int)
  func selectPlace(index: Int)

  var output: PlaceSelectingPresentableOutput { get }
}

// MARK: - PlaceSelectingViewController

final class PlaceSelectingViewController: UIViewController, PlaceSelectingPresentable, PlaceSelectingViewControllable {

  // MARK: Internal

  weak var listener: PlaceSelectingPresentableListener?

  override func viewDidLoad() {
    super.viewDidLoad()
    configView()
    bindings()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isMovingFromParent {
      listener?.movingFromParent()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // 바로 수행 시 `becomeFirstResponder` 수행되지 않는 문제가 있음.
    DispatchQueue.main.async {
      self.searchController.searchBar.searchTextField.becomeFirstResponder()
    }
  }

  // MARK: Private

  private let tableView = UITableView()
  private let disposeBag = DisposeBag()
  private let searchController = UISearchController(searchResultsController: nil)

  private func configView() {
    navigationItem.searchController = searchController

    view.backgroundColor = .systemBackground
    view.addSubview(tableView)
    tableView.frame = view.frame
    tableView.center = view.center

    tableView.register(PlaceSelectingTableViewCell.self, forCellReuseIdentifier: PlaceSelectingTableViewCell.describe)
    tableView.rowHeight = 70
  }

  private func bindings() {

    searchController.searchBar.rx.text
      .orEmpty
      .distinctUntilChanged()
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        self?.listener?.query($0)
      })
      .disposed(by: disposeBag)

    listener?.output.searchResults
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: [])
      .drive(tableView.rx.items(cellIdentifier: PlaceSelectingTableViewCell.describe, cellType: PlaceSelectingTableViewCell.self)) { [weak self] index, element, cell in
        cell.config(result: element, mapButtonClosure: {
          $0.rx.tap
            .subscribe(onNext: {
              self?.listener?.mapButtonTapped(index: index)
            })
        })
      }
      .disposed(by: disposeBag)

    tableView.rx.itemSelected
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] indexPath in
        // dismiss 하지 않고 바로 전환시, memory leak 발생
        self?.searchController.dismiss(animated: true, completion: {
          self?.listener?.selectPlace(index: indexPath.row)
        })
      })
      .disposed(by: disposeBag)
  }
}
