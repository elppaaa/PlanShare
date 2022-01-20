//
//  EditingViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import FlexLayout
import PinLayout
import RIBs
import RxSwift
import UIKit

// MARK: - EditingPresentableListener

protocol EditingPresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
}

// MARK: - EditingViewController

final class EditingViewController: UIViewController, EditingPresentable, EditingViewControllable {

  // MARK: Internal

  weak var listener: EditingPresentableListener?

  override func viewDidLoad() {
    super.viewDidLoad()

    configView()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    container.pin.all().margin(view.pin.safeArea)
    container.flex.layout()
  }

  // MARK: Private

  private let container = UIView()

  /// 장소 화면 , 수정 예정.
  private let placeView = UILabel()

  private let titleTextField = UITextField().then {
    $0.layer.borderColor = UIColor.systemGray.cgColor
    $0.layer.borderWidth = 0.1
    $0.layer.cornerRadius = 8
  }
  private let startAtPicker = UIDatePicker().then {
    if #available(iOS 13.4, *) {
      $0.preferredDatePickerStyle = .compact
    }
  }
  private let endAtPicker = UIDatePicker()
  private let memoTextView = UITextView().then {
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 0.1
    $0.layer.borderColor = UIColor.systemGray.cgColor
  }

  private let addressView = UILabel()

  private func configView() {
    view.backgroundColor = .systemBackground
    view.addSubview(container)

    container.flex.direction(.column).marginTop(20).paddingHorizontal(20).justifyContent(.start).alignItems(.start).define {
      addRow($0).define {
        addLabel($0, text: "title").marginRight(40)
        $0.addItem(titleTextField).padding(3).grow(1).shrink(1)
      }

      addRow($0).define {
        addLabel($0, text: "address").marginRight(40)
        $0.addItem(addressView).padding(3)
      }

      addDatePicker($0, text: "startAt", datePicker: startAtPicker)
      addDatePicker($0, text: "endAt", datePicker: endAtPicker)

      addLabel($0, text: "memo")
        .marginBottom(10)

      $0.addItem(memoTextView).minHeight(50).width(100%).grow(1)
        .shrink(1)
        .marginBottom(50)

    }
  }

  private func addRow(_ flex: Flex) -> Flex {
    flex.addItem().direction(.row).alignItems(.center).justifyContent(.spaceBetween).width(100%).marginBottom(40)
  }

  private func addColumn(_ flex: Flex) -> Flex {
    flex.addItem().direction(.column).alignItems(.stretch).justifyContent(.start).width(100%).marginBottom(40)
  }

  @discardableResult
  private func addDatePicker(_ flex: Flex, text: String, datePicker: UIDatePicker) -> Flex {
    if #available(iOS 14.0, *) {
      return addRow(flex).define {
        addLabel($0, text: text)
        $0.addItem(datePicker).grow(1).shrink(1)
      }
    } else {
      return addColumn(flex).define {
        addLabel($0, text: text)
        $0.addItem(datePicker).grow(1).shrink(1)
      }
    }
  }

  @discardableResult
  private func addLabel(_ flex: Flex, text: String) -> Flex {
    let label = UILabel().then {
      let captionSize = UIFont.preferredFont(forTextStyle: .subheadline)
      $0.font = .boldSystemFont(ofSize: captionSize.pointSize)
    }

    label.text = text

    return flex.addItem(label)
  }
}

// MARK: - EditingPresentable

extension EditingViewController {
  func setView(with plan: Plan) {
    titleTextField.text = plan.title
    memoTextView.text = plan.memo
    startAtPicker.date = plan.startAt
    endAtPicker.date = plan.endAt
    if addressView.text == "" || addressView.text == nil {
      addressView.text = "주소를 입력해주세요"
    } else {
      addressView.text = plan.place.title + ", " + plan.place.address
    }
  }
}
