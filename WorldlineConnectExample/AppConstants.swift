//
//  AppConstants.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import Foundation
import UIKit
import WorldlineConnectKit

class AppConstants {
    static let sdkBundle = Bundle(path: SDKConstants.kSDKBundlePath!)!
    static let ApplicationIdentifier = "SwiftUI Example Application/v2.0.0"
    static let ClientSessionId = "ClientSessionId"
    static let CustomerId = "CustomerId"
    static let MerchantId = "MerchantId"
    static let BaseURL = "BaseURL"
    static let AssetsBaseURL = "AssetsBaseURL"
    static let Price = "Price"
    static let Currency = "Currency"
    static let GroupProducts = "GroupProducts"
    static let ApplePay = "ApplePay"
    static let CountryCode = "CountryCode"
    static let CreditCardField = "cardNumber"
    static let CVVField = "cvv"
    static let ExpiryDateField = "expiryDate"
    static let CardHolderField = "cardholderName"
}
