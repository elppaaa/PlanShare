//
//  DetailPlanViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import FlexLayout
import PinLayout
import RIBs
import RxGesture
import RxSwift
import SafariServices
import UIKit

// MARK: - DetailPlanPresentableListener

protocol DetailPlanPresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
  func mapButtonTapped()
  func movingFromParent()
  func editButtonTapped()
  func addCalendarButtonTapped()
  func shareButtonTapped()
}

// MARK: - DetailPlanViewController

@MainActor
final class DetailPlanViewController: UIViewController, DetailPlanPresentable, DetailPlanViewControllable {

  // MARK: Internal

  weak var listener: DetailPlanPresentableListener?

  override func viewDidLoad() {
    super.viewDidLoad()
    configView()
    bindings()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    view.pin.all()

    container.pin.all()
    container.flex.layout()
    dimmedBackground.pin.all()
  }

  // MARK: Private

  private let container = UIView()

  private let titleLabel = UILabel()
  private let memoLabel = UILabel().then {
    $0.numberOfLines = 0
  }
  private let startAtLabel = UILabel()
  private let endAtLabel = UILabel()
  private let addressLabel = UILabel()
  private let dimmedBackground = UIView().then {
    $0.alpha = 0.2
    $0.backgroundColor = .black
  }
  private let editButton = UIButton().then {
    $0.setImage(.init(systemName: "pencil"), for: .normal)
  }

  private let mapButton = UIButton().then {
    $0.setImage(.init(systemName: "map.fill"), for: .normal)
  }

  private let addCalendarButton = UIButton().then {
    $0.setImage(.init(systemName: "calendar.badge.plus"), for: .normal)
  }

  private let shareButton = UIButton().then { button in
    button.setImage(.init(systemName: "message.fill"), for: .normal)
    button.imageView?.tintColor = UIColor(displayP3Red: 243 / 255, green: 226 / 255, blue: 75 / 255, alpha: 1.0) // kakao yellow
  }

  private let addressScrollView = AddressScrollView(isEditing: false)
  private let disposeBag = DisposeBag()

  private func configView() {
    view.addSubview(container)
    container.addSubview(dimmedBackground)
    container.flex.alignItems(.center).justifyContent(.center).define {
      let frameView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemBackground
      }

      $0.addItem(frameView).minWidth(65%).maxWidth(90%).maxHeight(90%).direction(.column).padding(20).define {

        $0.addView(label: "제목", view: titleLabel)
        $0.addView(label: "주소", view: addressLabel)
        $0.addView(label: "시작 시간", view: startAtLabel)
        $0.addView(label: "종료 시간", view: endAtLabel)
          .marginBottom(20)

        $0.addItem(labelLabel(text: "메모"))
          .marginBottom(10)

        $0.addItem(memoLabel)
          .marginBottom(30)

        $0.addItem(labelLabel(text: "추가 장소"))
          .marginBottom(10)

        $0.addItem(addressScrollView).height(120).width(100%).shrink(0)
          .marginBottom(30)

        $0.addItem().direction(.row).justifyContent(.spaceAround).grow(1).define {
          $0.addItem(shareButton).size(30)
          $0.addItem(editButton).size(30)
          $0.addItem(addCalendarButton).size(30)
          $0.addItem(mapButton).size(30)
        }
      }
    }
  }

  private func bindings() {
    mapButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self?.listener?.mapButtonTapped()
      })
      .disposed(by: disposeBag)

    dimmedBackground.rx.tapGesture()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        self?.listener?.movingFromParent()
      })
      .disposed(by: disposeBag)

    editButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self?.listener?.editButtonTapped()
      })
      .disposed(by: disposeBag)

    addCalendarButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self?.listener?.addCalendarButtonTapped()
      })
      .disposed(by: disposeBag)

    shareButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self?.listener?.shareButtonTapped()
      })
      .disposed(by: disposeBag)

  }

  private func labelLabel(text: String) -> UILabel {
    UILabel().then {
      $0.text = text
      let fontHeigt = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
      $0.font = .systemFont(ofSize: fontHeigt, weight: .bold)
    }
  }

}

// MARK: - DetailPlanPresentable
extension DetailPlanViewController {
  func setData(plan: Plan) {
    titleLabel.text = plan.title
    startAtLabel.text = plan.startAt.formattedDateAndTime
    endAtLabel.text = plan.endAt.formattedDateAndTime
    if let place = plan.place {
      addressLabel.text = place.title + ", " + place.address
    }
    addressScrollView.setView(idList: plan.additionalPlaces.map { $0.id })
    mapButton.isEnabled = plan.place != nil
    memoLabel.text = plan.memo
  }

  func openLink(url: URL) {
    let vc = SFSafariViewController(url: url)
    vc.modalTransitionStyle = .crossDissolve
    vc.modalPresentationStyle = .overCurrentContext
    present(vc, animated: true, completion: nil)
  }

  func prepareToRemove() {
    view.removeFromSuperview()
    removeFromParent()
    willMove(toParent: nil)
  }
}

extension Flex {
  @discardableResult
  fileprivate func addView(label: String, view: UIView) -> Flex {
    addItem().direction(.row).grow(1).justifyContent(.spaceBetween).define {
      let labelView = UILabel().then {
        $0.text = label
        let fontHeigt = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
        $0.font = .systemFont(ofSize: fontHeigt, weight: .bold)
      }

      $0.addItem(labelView)
        .marginRight(20)

      $0.addItem(view).shrink(1)
    }
    .marginBottom(20)
  }
}
