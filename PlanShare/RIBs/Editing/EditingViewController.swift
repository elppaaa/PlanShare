//
//  EditingViewController.swift
//  PlanShare
//
//  Created by JK on 2022/01/10.
//

import RIBs
import RxSwift
import UIKit
import PinLayout
import FlexLayout

// MARK: - EditingPresentableListener

protocol EditingPresentableListener: AnyObject {
  // TODO: Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
}

// MARK: - EditingViewController

final class EditingViewController: UIViewController, EditingPresentable, EditingViewControllable {
  weak var listener: EditingPresentableListener?
  
  private let container = UIView()
  
  override func viewDidLoad()  {
    super.viewDidLoad()
    
    configView()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    container.pin.all()
    container.flex.layout()
  }
  
  private func configView() {
    view.addSubview(container)
    /*
     title textfield
     start / end date picker
     memo textview
     장소 버튼.
     
     uitableview ?? stack 으로 필드를 쌓기
     static 한 화면임으로 tableview 보다는 쌓는것이 이점이 있지 않을까.
     */
  }
  
  private let titleTextField = UITextField()
  private let startAtView = UIDatePicker()
  private let endAtView = UIDatePicker()
  private let memo = UITextView()
  
  /// 장소 화면 , 수정 예정.
  private let placeView = UILabel()
}

// MARK: - EditingPresentable

extension EditingViewController  {
  func setView(with plan: Plan) {
    // TODO: - 구현 예정
  }
}
