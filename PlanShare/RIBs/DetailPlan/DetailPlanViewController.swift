//
//  DetailPlanViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import FlexLayout
import MapKit
import PinLayout
import RIBs
import RxGesture
import RxSwift
import UIKit

// MARK: - DetailPlanPresentableListener

protocol DetailPlanPresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
  func mapButtonTapped()
  func movingFromParent()
  func editButtonTapped()
  func addressLabelTapped()
}

// MARK: - DetailPlanViewController

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
  private let memoLabel = UILabel()
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

        addView(flex: $0, label: "title", view: titleLabel)
        addView(flex: $0, label: "address", view: addressLabel)
        addView(flex: $0, label: "startAt", view: startAtLabel)
        addView(flex: $0, label: "endAt", view: endAtLabel)
          .marginBottom(20)
        addView(flex: $0, label: "memo", view: memoLabel)
          .marginBottom(30)
        $0.addItem().direction(.row).justifyContent(.spaceAround).grow(1).define {
          $0.addItem(editButton).size(30)
          $0.addItem(mapButton).size(30)
        }
      }
    }
  }

  @discardableResult
  private func addView(flex: Flex, label: String, view: UIView) -> Flex {
    flex.addItem().direction(.row).grow(1).justifyContent(.spaceBetween).define {
      let labelView = UILabel().then {
        $0.text = label
      }
      $0.addItem(labelView)
        .marginRight(20)

      $0.addItem(view).shrink(1)
    }
    .marginBottom(20)
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
        self?.prepareToRemove()
        self?.listener?.movingFromParent()
      })
      .disposed(by: disposeBag)

    editButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self?.prepareToRemove()
        self?.listener?.editButtonTapped()
      })
      .disposed(by: disposeBag)

    addressLabel.rx.tapGesture()
      .when(.recognized)
      .subscribe(onNext: { [weak self]_ in
        self?.listener?.addressLabelTapped()
      })
      .disposed(by: disposeBag)
  }

  private func prepareToRemove() {
    view.removeFromSuperview()
    removeFromParent()
    willMove(toParent: nil)
  }
}

// MARK: - DetailPlanPresentable
extension DetailPlanViewController {
  func setData(plan: Plan) {
    titleLabel.text = plan.title
    startAtLabel.text = plan.startAt.formattedDateAndTime
    endAtLabel.text = plan.endAt.formattedDateAndTime
    addressLabel.text = plan.place?.address
    mapButton.isEnabled = plan.place != nil
    memoLabel.text = plan.memo
  }
}
