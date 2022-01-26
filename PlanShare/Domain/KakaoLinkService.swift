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

  enum Err: Error {
    case failedToCreate
  }

  static func sendMessage(plan: Plan) async -> Result<URL, Error> {
    guard let data = planShareMessage(plan: plan) else {
      return .failure(Err.failedToCreate)
    }

    do {
      let template = try SdkJSONDecoder.custom.decode(TextTemplate.self, from: data)
      if LinkApi.isKakaoLinkAvailable() {
        return await withUnsafeContinuation { container in
          LinkApi.shared.defaultLink(templatable: template) { linkResult, err in
            if let err = err {
              container.resume(returning: .failure(err))
            }
            if let linkResult = linkResult {
              container.resume(returning: .success(linkResult.url))
            } else {
              container.resume(returning: .failure(Err.failedToCreate))
            }
          }
        }
      } else {
        return await withUnsafeContinuation { container in
          if let url = LinkApi.shared.makeSharerUrlforDefaultLink(templatable: template) {
            container.resume(returning: .success(url))
          } else {
            container.resume(returning: .failure(Err.failedToCreate))
          }
        }
      }
    } catch {
      return .failure(error)
    }
  }

  // MARK: Private

  private static func planShareMessage(plan: Plan) -> Data? {
    var placeText = ""
    if let place = plan.place {
      placeText = "\(place.title), \(place.address)"
    }

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
