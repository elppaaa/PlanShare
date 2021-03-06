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
  func additionalAddButtonTapped()
}

// MARK: - EditingViewController

@MainActor
final class EditingViewController: UIViewController, EditingPresentable, EditingViewControllable {

  // MARK: Lifecycle

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
  init(imageCache: GooglePlaceImageCache) {
    additionalAddressView = AddressScrollView(isEditing: true, cache: imageCache)
    super.init(nibName: nil, bundle: nil)
  }

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

  private let additionalAddressView: AddressScrollView

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
      .asDriver(onErrorJustReturn: nil)
      .map { ($0 ?? "").count > 0 }
      .drive(doneBarButton.rx.isEnabled)
      .disposed(by: disposeBag)

    titleTextField.rx.text
      .orEmpty
      .skip(1)
      .distinctUntilChanged()
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .withUnretained(self)
      .subscribe(onNext: { `self`, text in
        self.listener?.setTitle(text)
      })
      .disposed(by: disposeBag)

    memoTextView.rx.text
      .orEmpty
      .skip(1)
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .withUnretained(self)
      .subscribe(onNext: { `self`, text in
        self.listener?.setMemo(text)
      })
      .disposed(by: disposeBag)

    startAtPicker.rx.date
      .skip(1)
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
      .skip(1)
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

    additionalAddressView.addButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { `self`, _ in
        self.listener?.additionalAddButtonTapped()
      })
      .disposed(by: disposeBag)

  }

  private func configView() {
    view.backgroundColor = .systemBackground
    view.addSubview(container)
    navigationItem.rightBarButtonItem = doneBarButton
    Task(priority: .userInitiated) {
      container.flex.direction(.column).marginTop(20).paddingHorizontal(20).justifyContent(.start).alignItems(.start).define {
        $0.addNewRow().define {
          $0.addLabel(text: "제목").marginRight(40)
          $0.addItem(titleTextField).padding(3).grow(1).shrink(1)
        }

        $0.addNewRow().define {
          $0.addLabel(text: "주소").marginRight(40)

          $0.addItem(addressView)
        }

        $0.addDatePicker(text: "시작 시간", datePicker: startAtPicker)
        $0.addDatePicker(text: "종료 시간", datePicker: endAtPicker)

        $0.addLabel(text: "메모")
          .padding(3)
          .marginBottom(10)

        $0.addItem(memoTextView).minHeight(200).width(100%).grow(1)
          .shrink(1)
          .marginBottom(10)

        $0.addLabel(text: "추가 장소")
          .marginBottom(10)

        $0.addItem(additionalAddressView).height(120).width(100%).shrink(0)
      }
    }
  }

}

// MARK: - EditingPresentable

extension EditingViewController {
  func setView(with plan: Plan) {
    titleTextField.text = plan.title
    doneBarButton.isEnabled = plan.title != ""
    memoTextView.text = plan.memo
    startAtPicker.setDate(plan.startAt, animated: false)
    endAtPicker.setDate(plan.endAt, animated: false)
    let idList = plan.additionalPlaces.map { $0.id }
    additionalAddressView.setView(idList: idList)

    if plan.place?.title == "" || plan.place?.title == nil {
      addressView.text = "주소를 입력해주세요"
    } else {
      addressView.text = (plan.place?.title ?? "") + ", " + (plan.place?.address ?? "")
    }
  }
}

extension Flex {
  @discardableResult
  fileprivate func addLabel(text: String) -> Flex {
    let label = UILabel().then {
      $0.text = text
      let fontHeigt = UIFont.preferredFont(forTextStyle: .headline).pointSize
      $0.font = .systemFont(ofSize: fontHeigt, weight: .bold)
    }

    label.text = text

    return addItem(label)
  }

  fileprivate func addNewRow() -> Flex {
    addItem().direction(.row).wrap(.noWrap).alignItems(.center).justifyContent(.spaceBetween).width(100%).marginBottom(40)
  }

  fileprivate func addNewColumn() -> Flex {
    addItem().direction(.column).alignItems(.stretch).justifyContent(.start).width(100%).marginBottom(40)
  }

  @discardableResult
  fileprivate func addDatePicker(text: String, datePicker: UIDatePicker) -> Flex {
    if #available(iOS 14.0, *) {
      return self.addNewRow().define {
        $0.addLabel(text: text)
        $0.addItem(datePicker).grow(1).shrink(1)
      }
    } else {
      return addNewColumn().define {
        $0.addLabel(text: text)
        $0.addItem(datePicker).grow(1).shrink(1)
      }
    }
  }
}
