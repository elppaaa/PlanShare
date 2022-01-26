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
  func save()
  func movingFromParent()
  func setTitle(_ text: String)
  func setMemo(_ text: String)
  func setStartAt(_ date: Date)
  func setEndAt(_ date: Date)
  func getPlace()
}

// MARK: - EditingViewController

@MainActor
final class EditingViewController: UIViewController, EditingPresentable, EditingViewControllable {

  // MARK: Internal

  weak var listener: EditingPresentableListener?

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
    $0.minuteInterval = 5
  }
  private let endAtPicker = UIDatePicker().then {
    if #available(iOS 13.4, *) {
      $0.preferredDatePickerStyle = .compact
    }
    $0.minuteInterval = 5
  }
  private let memoTextView = UITextView().then {
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 0.1
    $0.layer.borderColor = UIColor.systemGray.cgColor
    let fontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    $0.font = .systemFont(ofSize: fontSize * 1.2, weight: .medium)
  }

  private let addressView = UILabel()
  private lazy var doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: nil)
  private let disposeBag = DisposeBag()

  private func bindings() {
    doneBarButton.rx.tap
      .throttle(.seconds(3), scheduler: ConcurrentDispatchQueueScheduler(qos: .utility))
      .withUnretained(self)
      .subscribe(onNext: { `self`, _ in
        self.listener?.save()
      })
      .disposed(by: disposeBag)

    titleTextField.rx.text
      .map { ($0 ?? "").count > 0 }
      .asDriver(onErrorJustReturn: false)
      .drive(doneBarButton.rx.isEnabled)
      .disposed(by: disposeBag)

    titleTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .withUnretained(self)
      .subscribe(onNext: { `self`, text in
        self.listener?.setTitle(text)
      })
      .disposed(by: disposeBag)

    memoTextView.rx.text
      .orEmpty
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .withUnretained(self)
      .subscribe(onNext: { `self`, text in
        self.listener?.setMemo(text)
      })
      .disposed(by: disposeBag)

    startAtPicker.rx.date
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .withUnretained(self)
      .subscribe(onNext: { `self`, date in
        self.listener?.setStartAt(date)
        if self.endAtPicker.date < date {
          self.endAtPicker.setDate(date, animated: true)
        }
      })
      .disposed(by: disposeBag)

    endAtPicker.rx.date
      .distinctUntilChanged()
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .withUnretained(self)
      .subscribe(onNext: { `self`, date in
        self.listener?.setEndAt(date)
      })
      .disposed(by: disposeBag)

    addressView.rx.tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { `self`, _ in
        self.listener?.getPlace()
      })
      .disposed(by: disposeBag)

  }

  private func configView() {
    view.backgroundColor = .systemBackground
    view.addSubview(container)
    navigationItem.rightBarButtonItem = doneBarButton
    doneBarButton.isEnabled = false
    container.flex.direction(.column).marginTop(20).paddingHorizontal(20).justifyContent(.start).alignItems(.start).define {
      addRow($0).define {
        addLabel($0, text: "title").marginRight(40)
        $0.addItem(titleTextField).padding(3).grow(1).shrink(1)
      }
      
      addRow($0).define {
        addLabel($0, text: "address").marginRight(40)

        $0.addItem(addressView).padding(3).shrink(1).grow(1)
      }
      
      addDatePicker($0, text: "startAt", datePicker: startAtPicker)
      addDatePicker($0, text: "endAt", datePicker: endAtPicker)
      
      addLabel($0, text: "memo")
        .padding(3)
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
    DispatchQueue.main.async {
      self.titleTextField.text = plan.title
      self.memoTextView.text = plan.memo
      self.startAtPicker.date = plan.startAt
      self.endAtPicker.date = plan.endAt
      if self.addressView.text == "" || self.addressView.text == nil {
        self.addressView.text = "주소를 입력해주세요"
      } else {
        self.addressView.text = (plan.place?.title ?? "") + ", " + (plan.place?.address ?? "")
      }
    }
  }
}
