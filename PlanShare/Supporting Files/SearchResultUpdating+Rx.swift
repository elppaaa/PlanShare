//
//  SearchResultUpdating+Rx.swift
//  PlanShare
//
//  Created by JK on 2022/01/21.
//

import RxCocoa
import RxSwift
import UIKit

// MARK: - RxSearchResultUpdatingProxy

final class RxSearchResultUpdatingProxy: DelegateProxy<UISearchController, UISearchResultsUpdating>, DelegateProxyType, UISearchResultsUpdating {

  private(set) lazy var queryTextSubject = PublishSubject<String>()

  static func currentDelegate(for object: UISearchController) -> UISearchResultsUpdating? {
    object.searchResultsUpdater
  }

  static func setCurrentDelegate(_ delegate: UISearchResultsUpdating?, to object: UISearchController) {
    object.searchResultsUpdater = delegate
  }

  static func registerKnownImplementations() {
    register { RxSearchResultUpdatingProxy(parentObject: $0, delegateProxy: self) }
  }

  func updateSearchResults(for searchController: UISearchController) {
    if let text = searchController.searchBar.text {
      queryTextSubject.onNext(text)
    }
  }

}

extension Reactive where Base: UISearchController {
  var searchResultsUpdater: RxSearchResultUpdatingProxy {
    RxSearchResultUpdatingProxy.proxy(for: base)
  }

  var queryText: Observable<String> {
    searchResultsUpdater
      .queryTextSubject
      .asObserver()
  }

}
