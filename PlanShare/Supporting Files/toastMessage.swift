//
//  toastMessage.swift
//  PlanShare
//
//  Created by JK on 2022/01/25.
//

import UIKit

func toastMessage(_ text: String, duration: Double = 3.0) {
  DispatchQueue.main.async {
    guard let window = getCurrentUIWindow() else { return }

    let label = UILabel().then {
      $0.backgroundColor = .black.withAlphaComponent(0.5)
      $0.textColor = .white
      $0.textAlignment = .center
      $0.alpha = 1.0
      $0.clipsToBounds = true
      $0.layer.cornerRadius = 9
      $0.text = text
    }

    let width = label.intrinsicContentSize.width + 30
    label.frame = .init(x: window.frame.width / 2 - width / 2, y: window.frame.height - 100, width: width, height: 35)

    window.addSubview(label)

    UIView.animate(withDuration: 1.0, delay: duration, options: .curveEaseOut, animations: { label.alpha = 0.0 }) { _ in
      label.removeFromSuperview()
    }
  }

  func getCurrentUIWindow() -> UIWindow? {
    for scene in UIApplication.shared.connectedScenes {
      if scene.activationState == .foregroundActive {
        return (scene as? UIWindowScene)?.windows.last
      }
    }
    return nil
  }
}
