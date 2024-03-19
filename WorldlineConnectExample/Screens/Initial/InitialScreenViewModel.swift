//
//  InitialScreenViewModel.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import Foundation
import WorldlineConnectKit
import UIKit

extension StartScreen {
    class ViewModel: ObservableObject {

        // MARK: - Properties

        @Published var clientSessionId: String = ""
        @Published var clientSessionIdError: String?

        @Published var customerID: String = ""
        @Published var customerIDError: String?

        @Published var clientApiUrl: String = ""
        @Published var clientApiUrlError: String?

        @Published var assetsUrl: String = ""
        @Published var assetsUrlError: String?

        @Published var amount: String = ""
        @Published var amountError: String?

        @Published var countryCode: String = ""
        @Published var countryCodeError: String?

        @Published var currencyCode: String = ""
        @Published var currencyCodeError: String?

        @Published var merchantId: String = ""
        @Published var merchantIdError: String?

        @Published var recurringPayment: Bool = false
        @Published var groupProducts: Bool = false
        @Published var applePay: Bool = false

        @Published var errorMessage: String?
        @Published var showAlert: Bool = false
        @Published var infoText: String = ""
        @Published var showPaymentList: Bool = false
        @Published var isLoading: Bool = false

        let emptyFieldError = "EmptyField".localized

        var paymentItems: PaymentItems?

        init() {
            clientSessionId = UserDefaults.standard.string(forKey: AppConstants.ClientSessionId) ?? ""
            customerID = UserDefaults.standard.string(forKey: AppConstants.CustomerId) ?? ""
            clientApiUrl = UserDefaults.standard.string(forKey: AppConstants.BaseURL) ?? ""
            assetsUrl = UserDefaults.standard.string(forKey: AppConstants.AssetsBaseURL) ?? ""

            amount = UserDefaults.standard.string(forKey: AppConstants.Price) ?? ""
            countryCode = UserDefaults.standard.string(forKey: AppConstants.CountryCode) ?? ""
            currencyCode = UserDefaults.standard.string(forKey: AppConstants.Currency) ?? ""
            merchantId = UserDefaults.standard.string(forKey: AppConstants.MerchantId) ?? ""

            groupProducts = UserDefaults.standard.bool(forKey: AppConstants.GroupProducts)
            applePay = UserDefaults.standard.bool(forKey: AppConstants.ApplePay)

        }

        // MARK: - Actions
        func proceedToCheckout() {
            isLoading = true

            self.initializeConnectSDK()

            ConnectSDK.clientApi.paymentItems(
                success: { paymentItems in
                    self.isLoading = false
                    self.paymentItems = paymentItems
                    self.showPaymentList = true
                },
                failure: { error in
                    self.showAlert(text: error.localizedDescription)
                    self.isLoading = false
                },
                apiFailure: { errorResponse in
                    self.showAlert(text: errorResponse.errors[0].message)
                    self.isLoading = false
                }
            )
        }

        private func initializeConnectSDK() {
            validateClientSessionId()
            validateCustomerID()
            validateClientApiUrl()
            validateAssetsUrl()
            validateAmount()
            validateCountryCode()
            validateCurrencyCode()

            guard clientSessionIdError == nil &&
                customerIDError == nil &&
                clientApiUrlError == nil &&
                assetsUrlError == nil &&
                amountError == nil &&
                countryCodeError == nil &&
                currencyCodeError == nil else {
                isLoading = false
                return
            }

            let sessionConfiguration = SessionConfiguration(
                clientSessionId: clientSessionId,
                customerId: customerID,
                clientApiUrl: clientApiUrl,
                assetUrl: assetsUrl
            )

            // ***************************************************************************
            //
            // You can log of requests made to the server and responses received from the server
            // by passing the `enableNetworkLogs` parameter to the ConnectSDKConfiguration constructor.
            // In the constructor below, the logging is disabled.
            // Logging should be disabled in production.
            // To use logging in debug, but not in production, you can initialize the ConnectSDKConfiguration object
            // within a DEBUG flag.
            // If you use the DEBUG flag, you can take a look at this app's build settings
            // to see the setup you should apply to your own app.
            //
            // ***************************************************************************

            var connectSDKConfiguration: ConnectSDKConfiguration?
            #if DEBUG
            connectSDKConfiguration = ConnectSDKConfiguration(
                sessionConfiguration: sessionConfiguration,
                enableNetworkLogs: true,
                applicationId: AppConstants.ApplicationIdentifier,
                ipAddress: nil
            )
            #else
            connectSDKConfiguration = ConnectSDKConfiguration(
                sessionConfiguration: sessionConfiguration,
                enableNetworkLogs: false,
                applicationId: AppConstants.ApplicationIdentifier,
                ipAddress: nil
            )
            #endif

            UserDefaults.standard.set(clientSessionId, forKey: AppConstants.ClientSessionId)
            UserDefaults.standard.set(customerID, forKey: AppConstants.CustomerId)
            UserDefaults.standard.set(clientApiUrl, forKey: AppConstants.BaseURL)
            UserDefaults.standard.set(assetsUrl, forKey: AppConstants.AssetsBaseURL)

            UserDefaults.standard.set(amount, forKey: AppConstants.Price)
            UserDefaults.standard.set(countryCode, forKey: AppConstants.CountryCode)
            UserDefaults.standard.set(currencyCode, forKey: AppConstants.Currency)
            UserDefaults.standard.set(merchantId, forKey: AppConstants.MerchantId)

            UserDefaults.standard.set(groupProducts, forKey: AppConstants.GroupProducts)
            UserDefaults.standard.set(applePay, forKey: AppConstants.ApplePay)

            let amountOfMoney = PaymentAmountOfMoney(totalAmount: Int(amount) ?? 0, currencyCode: currencyCode)
            let context =
                PaymentContext(
                    amountOfMoney: amountOfMoney,
                    isRecurring: recurringPayment,
                    countryCode: countryCode
                )

            guard let connectSDKConfiguration else {
                Macros.DLog(message: "Could not find connectSDKConfiguration")
                self.showAlert(text: "Could not retrieve payment items. Please try again later.")
                self.isLoading = false
                return
            }

            let paymentConfiguration = PaymentConfiguration(
                paymentContext: context,
                groupPaymentProducts: groupProducts
            )

            ConnectSDK.initialize(
                connectSDKConfiguration: connectSDKConfiguration,
                paymentConfiguration: paymentConfiguration
            )
        }

        func pasteFromJson() {
            if let value = UIPasteboard.general.string {
                guard let result = parseJson(value) else {
                    showAlert(text: "JsonErrorMessage".localized)
                    return
                }
                clientSessionId = result.clientId ?? ""
                customerID = result.customerId ?? ""
                clientApiUrl = result.baseUrl ?? ""
                assetsUrl = result.assetUrl ?? ""
            }
        }

        // MARK: - Helpers
        private func parseJson(_ jsonString: String) -> ClientSessionParsedJsonData? {
            guard let data = jsonString.data(using: .utf8) else {
                showAlert(text: "data is nil")
                return nil
            }
            do {
                return try JSONDecoder().decode(ClientSessionParsedJsonData.self, from: data)
            } catch {
                showAlert(text: "JsonErrorMessage".localized)
                return nil
            }
        }

        private func showAlert(text: String) {
            errorMessage = text
            showAlert = true
        }

        // MARK: - Field Validation

        private func validateClientSessionId() {
            if clientSessionId == "" {
                clientSessionIdError = emptyFieldError
            } else {
                clientSessionIdError = nil
            }
        }

        private func validateCustomerID() {
            if customerID == "" {
                customerIDError = emptyFieldError
            } else {
                customerIDError = nil
            }
        }

        private func validateClientApiUrl() {
            if clientApiUrl == "" {
                clientApiUrlError = emptyFieldError
            } else {
                clientApiUrlError = nil
            }
        }

        private func validateAssetsUrl() {
            if assetsUrl == "" {
                assetsUrlError = emptyFieldError
            } else {
                assetsUrlError = nil
            }
        }

        private func validateAmount() {
            if amount == "" {
                amountError = emptyFieldError
            } else {
                amountError = nil
            }
        }

        private func validateCountryCode() {
            if countryCode == "" {
                countryCodeError = emptyFieldError
            } else {
                countryCodeError = nil
            }
        }

        private func validateCurrencyCode() {
            if currencyCode == "" {
                currencyCodeError = emptyFieldError
            } else {
                currencyCodeError = nil
            }
        }
    }
}
