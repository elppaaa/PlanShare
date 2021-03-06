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
}

// MARK: - DetailPlanPresentable

@MainActor
protocol DetailPlanPresentable: Presentable {
  var listener: DetailPlanPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
  func setData(plan: Plan)
  func openLink(url: URL)
  func prepareToRemove()
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
    currentPlan: Plan,
    planModel: PlanModel
  )
  {
    plan = currentPlan
    model = planModel
    super.init(presenter: presenter)
    Task(priority: .userInitiated) {
      await presenter.listener = self
    }
  }

  // MARK: Internal

  weak var router: DetailPlanRouting?
  weak var listener: DetailPlanListener?

  override func didBecomeActive() {
    super.didBecomeActive()
    Task(priority: .userInitiated) {
      await presenter.setData(plan: plan)
    }
  }

  override func willResignActive() {
    super.willResignActive()
    // TODO: Pause any business logic.
  }

  // MARK: Private

  private let plan: Plan
  private var model: PlanModel
}

// MARK: - DetailPlanPresentableListener

extension DetailPlanInteractor {
  func mapButtonTapped() {
    Task {
      if let link = plan.place?.link {
        await UIApplication.shared.open(link, options: [:], completionHandler: nil)
      }
    }
  }

  func shareButtonTapped() {
    Task(priority: .utility) {
      if let link = try? await KakaoLinkService.sendMessage(plan: plan).get() {
        // kakako installed check
        if await UIApplication.shared.canOpenURL(URL(string: "kakaolink://send")!) {
          await UIApplication.shared.open(link, options: [:], completionHandler: nil)
        } else {
          await presenter.openLink(url: link)
        }
      }
    }
  }

  func movingFromParent() {
    Task(priority: .userInitiated) {
      await presenter.prepareToRemove()
      listener?.dismissedChild()
    }
  }

  func editButtonTapped() {
    Task(priority: .userInitiated) {
      await presenter.prepareToRemove()
      listener?.routeToEditing(plan: plan)
    }
  }

  func addCalendarButtonTapped() {
    guard let eventIdentifier = model.eventIdentifier else {
      Task(priority: .utility) {
        if let newEvent = try? await CalendarService.shared.newEvent(plan: plan).get() {
          model.eventIdentifier = newEvent
          model.update()
          toastMessage("???????????? ?????????????????????.")
        }
      }
      return
    }

    // TODO: - ????????? ????????? ?????? ??????
    Task {
      switch await CalendarService.shared.updateEvent(identifier: eventIdentifier, plan: plan) {
      case .success(let value):
        if let value = value {
          self.model.eventIdentifier = value
          self.model.update()
        }
        toastMessage("???????????? ?????????????????????.")
      default:
        return
      }
    }
  }
}

// MARK: - ViewableRouting

extension DetailPlanInteractor {
  func dismissedChild() {
    router?.detachCurrentChild()
  }
}
