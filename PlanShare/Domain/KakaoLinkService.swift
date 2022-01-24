//
//  KakaoLinkService.swift
//  PlanShare
//
//  Created by JK on 2022/01/25.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKLink
import KakaoSDKTemplate
import RxKakaoSDKLink
import RxSwift
import SafariServices
import UIKit

final class KakaoLinkService {

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  static func sendMessage(plan: Plan) -> Single<URL> {
    guard let data = planShareMessage(plan: plan) else {
      return .error(NSError())
    }

    do {
      let template = try SdkJSONDecoder.custom.decode(TextTemplate.self, from: data)
      if LinkApi.isKakaoLinkAvailable() {

        return LinkApi.shared.rx.defaultLink(templatable: template)
          .map(\.url)
      } else {
        if let url = LinkApi.shared.makeSharerUrlforDefaultLink(templatable: template) {
          return .just(url)
        } else {
          return .error(NSError())
        }
      }
    } catch {
      return .error(error)
    }
  }

  // MARK: Private

  private static func planShareMessage(plan: Plan) -> Data? {
    var placeText = ""
    if let place = plan.place {
      placeText = "\(place.title), \(place.address)"
    }

    /*
     return """
     {
         "object_type": "text",
         "text": "\(plan.title)\\n\(plan.startAt.formattedDateAndTime) ~ \(plan.endAt.formattedDateAndTime)\\n\(placeText)",
         "link": {
           "mobile_web_url": "https://www.naver.com"
         },
         "button_title": "앱에서 열기"
     }
     """
      */
    return """
        {
            "object_type": "text",
            "text": "\(plan.title)\\n\\n\(plan.startAt.formattedDateAndTime) ~ \(plan.endAt.formattedDateAndTime)\\n\(placeText)",
            "link": {
              "ios_execution_params": "\(plan.id!)"
            },
            "button_title": "앱에서 열기"
        }
    """
    .data(using: .utf8)
  }
}
