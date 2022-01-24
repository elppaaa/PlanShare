//
//  DetailPlanInteractor.swift
//  PlanShare
//
//  Created by JK on 2022/01/19.
//

import CoreLocation
import KakaoSDKLink
import RIBs
import RxSwift
import UIKit

// MARK: - DetailPlanRouting

protocol DetailPlanRouting: ViewableRouting {
  // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
  func routeToMarkedMap(location: CLLocationCoordinate2D)
}

// MARK: - DetailPlanPresentable

protocol DetailPlanPresentable: Presentable {
  var listener: DetailPlanPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
  func setData(plan: Plan)
  func openLink(url: URL)
}

// MARK: - DetailPlanListener

protocol DetailPlanListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
  func dismissedChild()
  func routeToEditing(plan: Plan)
}

// MARK: - DetailPlanInteractor

final class DetailPlanInteractor: PresentableInteractor<DetailPlanPresentable>, DetailPlanInteractable, DetailPlanPresentableListener {

  // MARK: Lifecycle

  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  init(
    presenter: DetailPlanPresentable,
    currentPlan: Plan
  )
  {
    plan = currentPlan
    super.init(presenter: presenter)
    presenter.listener = self
  }

  // MARK: Internal

  weak var router: DetailPlanRouting?
  weak var listener: DetailPlanListener?

  override func didBecomeActive() {
    super.didBecomeActive()
    presenter.setData(plan: plan)
    if
      let id = plan.id,
      case .success(let id) = PlanModel.getEventIDBy(planID: id)
    {
      eventIdentifier = id
    }
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: Private

  private let plan: Plan
  private var eventIdentifier: String?
}

// MARK: - DetailPlanPresentableListener

extension DetailPlanInteractor {
  func mapButtonTapped() {
//    if let location = plan.place?.location {
//      router?.routeToMarkedMap(location: location)
//    }
    if let link = plan.place?.link {
      UIApplication.shared.open(link, options: [:], completionHandler: nil)
    }
  }

  func shareButtonTapped() {
    KakaoLinkService.sendMessage(plan: plan)
      .subscribe(onSuccess: { [weak self] in
        if LinkApi.isKakaoLinkAvailable() {
          UIApplication.shared.open($0, options: [:], completionHandler: nil)
        } else {
          self?.presenter.openLink(url: $0)
        }
      })
      .disposeOnDeactivate(interactor: self)
  }

  func movingFromParent() {
    listener?.dismissedChild()
  }

  func editButtonTapped() {
    listener?.routeToEditing(plan: plan)
  }

  func addCalendarButtonTapped() {
    guard let eventIdentifier = eventIdentifier else {
      CalendarService.shared.newEvent(plan: plan)
        .subscribe(onSuccess: { [weak self] in
          guard
            let self = self,
            let id = self.plan.id else { return }

          // TODO: - 토스트 메시지 표시 예정
          self.eventIdentifier = $0
          PlanModel.updateEventID(planID: id, eventIdentifier: $0)
        })
        .disposeOnDeactivate(interactor: self)
      return
    }

    // TODO: - 토스트 메시지 표시 예정
    CalendarService.shared.updateEvent(identifier: eventIdentifier, plan: plan)
      .subscribe(
        onSuccess: { [weak self] in
          guard
            let self = self,
            let id = self.plan.id else { return }

          // TODO: - 토스트 메시지 표시 예정
          self.eventIdentifier = $0
          PlanModel.updateEventID(planID: id, eventIdentifier: $0)
        },
        onCompleted: {
          // TODO: - 토스트 메시지 표시 예정

        }
      )
      .disposeOnDeactivate(interactor: self)

  }

//  func addressLabelTapped() {
//    if let link = plan.place?.link {
//      UIApplication.shared.open(link, options: [:], completionHandler: nil)
//    }
//  }
}

// MARK: - ViewableRouting

extension DetailPlanInteractor {
  func dismissedChild() {
    router?.detachCurrentChild()
  }
}
