//
//  PlaceSelectingTableViewCell.swift
//  PlanShare
//
//  Created by JK on 2022/01/22.
//

import FlexLayout
import PinLayout
import RxSwift
import UIKit

// MARK: - PlaceSelectingTableViewCell

final class PlaceSelectingTableViewCell: UITableViewCell {

  // MARK: Lifecycle

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configView()
  }

  // MARK: Internal

  override var reuseIdentifier: String? { Self.describe }

  func config(result: PlaceSearchResult, mapButtonClosure: @escaping (UIButton) -> Disposable) {
    name.text = result.name
    secondary.text = result.secondary

    if let disposeBag = disposeBag {
      mapButtonClosure(mapButton)
        .disposed(by: disposeBag)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    contentView.pin.all()
    contentView.flex.layout()
  }

  // MARK: Private

  private let name = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .headline)
  }
  private let secondary = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .callout)
  }
  private let mapButton = UIButton().then {
    $0.setImage(.init(systemName: "map.fill"), for: .normal)
    $0.isUserInteractionEnabled = true
  }

  private var disposeBag: DisposeBag? = DisposeBag()

  private func configView() {
    selectionStyle = .none

    contentView.flex.direction(.row).justifyContent(.start).alignItems(.center).paddingVertical(7).paddingHorizontal(10).define {
      $0.addItem().direction(.column).grow(1).shrink(1).width(100%).define {
        $0.addItem(name)
          .marginBottom(10)
        $0.addItem(secondary)
      }

      $0.addItem(mapButton).size(30).padding(10)
    }
  }
}
