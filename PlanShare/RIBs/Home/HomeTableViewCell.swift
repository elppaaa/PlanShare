//
//  HomeTableViewCell.swift
//  PlanShare
//
//  Created by JK on 2022/01/18.
//

import FlexLayout
import PinLayout
import UIKit

// MARK: - HomeTableViewCell

final class HomeTableViewCell: UITableViewCell {

  // MARK: Lifecycle

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
    // TODO: - Fill Content
  }

  // MARK: Private

  private let title = UILabel()
  private let date = UILabel()
  private let shareButton = UIButton()

  private func configView() {
    contentView.flex.define {
      $0.addItem().direction(.row).margin(5).justifyContent(.start).height(100%).alignItems(.center).define {
        $0.addItem().direction(.column).grow(1).shrink(1)
          .marginEnd(10).define {
            $0.addItem(title).paddingBottom(10)
            $0.addItem(date)
          }
        $0.addItem(shareButton).size(25).margin(5).shrink(0)
      }
    }
  }
}
