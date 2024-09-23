//
//  EndScreenViewModel.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import Foundation
import WorldlineConnectKit
import MobileCoreServices
import UIKit

extension EndScreen {

    class ViewModel: ObservableObject {

        @Published var showEncryptedFields: Bool = false

        var preparedPaymentRequest: PreparedPaymentRequest?

        init(preparedPaymentRequest: PreparedPaymentRequest?) {
            self.preparedPaymentRequest = preparedPaymentRequest
        }

        func copyToClipboard() {
            UIPasteboard.general.string = self.preparedPaymentRequest?.encryptedFields ?? ""
        }

        func returnToStart() {
            NavigationUtil.popToRootView()
        }

    }
}
