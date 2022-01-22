//
//  HomeTableViewCell.swift
//  PlanShare
//
//  Created by JK on 2022/01/18.
//

import FlexLayout
import PinLayout
import RxSwift
import UIKit

// MARK: - HomeTableViewCell

final class HomeTableViewCell: UITableViewCell {

  // MARK: Lifecycle

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier _: String?) {
    super.init(style: style, reuseIdentifier: Self.describe)
    configView()

    backgroundColor = .systemBackground
    selectionStyle = .none
  }

  // MARK: Internal

  override var reuseIdentifier: String? { Self.describe }

  override func layoutSubviews() {
    super.layoutSubviews()

    contentView.flex.layout()
  }

  func set(plan: Plan) {
    title.text = plan.title
    date.text = plan.startAt.formattedDateAndTime + " - " + plan.endAt.formattedDateAndTime
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }

  // MARK: Private

  private let title = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .title3)
  }
  private let date = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .caption1)
    $0.textColor = .systemGray2
  }
  private var disposeBag = DisposeBag()

  private func configView() {
    contentView.flex.define {
      $0.addItem().direction(.row).margin(5).justifyContent(.start).height(100%).alignItems(.center).define {
        $0.addItem().direction(.column).grow(1).shrink(1)
          .marginEnd(10).define {
            $0.addItem(title).paddingBottom(10)
            $0.addItem(date)
          }
      }
    }
  }
}
