//
//  GooglePlaceImageView.swift
//  PlanShare
//
//  Created by JK on 2022/01/30.
//

import UIKit

// MARK: - GooglePlaceImageView

final class GooglePlaceImageView: UIImageView {

  // MARK: Lifecycle

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
  override init(frame: CGRect = .zero) {
    super.init(frame: frame)

    configLayout()
  }

  // MARK: Internal

  func setImage(fetcher: GooglePlaceImageCache, id: String) {
    Task(priority: .background) {
      if let (name, image) = await fetcher.nameAndImage(id: id) {
        self.image = image
        self.label.text = name

        let width = label.intrinsicContentSize.width + 15
        label.frame = .init(x: self.frame.width / 2 - width / 2, y: self.frame.height - 100, width: width, height: label.font.pointSize + 15)
      }
      self.endLoading()
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    indicator?.pin.size(10).center()
    label.pin.hCenter().bottom(7)
  }

  // MARK: Private

  private var indicator: UIActivityIndicatorView? = UIActivityIndicatorView()
  private let label = UILabel().then {
    $0.backgroundColor = .black.withAlphaComponent(0.7)
    $0.textColor = .white
    $0.textAlignment = .center
    $0.font = .preferredFont(forTextStyle: .footnote)
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 9
  }

  private func configLayout() {
    layer.cornerRadius = 10
    clipsToBounds = true

    if let indicator = indicator {
      addSubview(indicator)
      indicator.startAnimating()
    }
    addSubview(label)
  }

  private func endLoading() {
    indicator?.stopAnimating()
    indicator?.removeFromSuperview()
    indicator = nil
  }
}
