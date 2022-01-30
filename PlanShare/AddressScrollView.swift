//
//  AddressScrollView.swift
//  PlanShare
//
//  Created by JK on 2022/01/29.
//

import FlexLayout
import GooglePlaces
import PinLayout
import UIKit

// MARK: - AddressScrollView

final class AddressScrollView: UIScrollView {

  // MARK: Lifecycle

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
  init(isEditing: Bool = false, cache: GooglePlaceImageCache) {
    self.isEditing = isEditing
    self.cache = cache
    super.init(frame: .zero)
    isUserInteractionEnabled = true
    configView()
    addSubview(container)
  }

  // MARK: Internal

  private(set) lazy var addButton = UIButton().then {
    $0.setImage(UIImage(systemName: "plus"), for: .normal)
    $0.tintColor = .white
    $0.backgroundColor = .systemGray3
    $0.layer.cornerRadius = 10
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    container.pin.vertically().left()
    container.flex.layout(mode: .adjustWidth)
    contentSize = container.frame.size
  }

  func setView(idList: [String]) {
    container.subviews.forEach { $0.removeFromSuperview() }
    if isEditing {

      container.flex.direction(.row).define {
        for id in idList {
          $0.addSquare(view: GooglePlaceImageView().then { $0.setImage(fetcher: cache, id: id) } )
            .marginRight(10)
        }
        $0.addSquare(view: addButton)
      }

    } else {

      container.flex.direction(.row).define {
        guard let lastImageID = idList.last else { return }
        for id in idList[..<(idList.count - 1)] {
          $0.addSquare(view: GooglePlaceImageView().then { $0.setImage(fetcher: cache, id: id) })
            .marginRight(10)
        }
        $0.addSquare(view: GooglePlaceImageView().then { $0.setImage(fetcher: cache, id: lastImageID) })
      }

    }

    DispatchQueue.main.async {
      self.setNeedsLayout()
    }
  }

  // MARK: Private

  private let container = UIView()

  private let isEditing: Bool

  private let cache: GooglePlaceImageCache

  private func configView() {
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    isDirectionalLockEnabled = true
  }
}

extension Flex {
  @discardableResult
  fileprivate func addSquare(view: UIView) -> Flex {
    addItem(view).height(100%).aspectRatio(1.3).markDirty()
  }
}
