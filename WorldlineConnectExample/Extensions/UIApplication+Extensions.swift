//
//  UIApplication+Extensions.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 09/03/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import UIKit

extension UIApplication {
  var currentKeyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .map { $0 as? UIWindowScene }
      .compactMap { $0 }
      .first?.windows
      .filter { $0.isKeyWindow }
      .first
  }

  var rootViewController: UIViewController? {
    currentKeyWindow?.rootViewController
  }
}
