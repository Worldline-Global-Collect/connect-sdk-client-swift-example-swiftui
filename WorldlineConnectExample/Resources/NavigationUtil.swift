//
//  NavigationUtil.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 05/03/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import UIKit

struct NavigationUtil {
    static func popToRootView() {
        findNavigationController(
            viewController:
                UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
        )?.popToRootViewController(animated: true)
    }

    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }

        return nil
    }
}
