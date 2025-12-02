//
//  PaymentListItemsScreenViewModel.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import WorldlineConnectKit
import Foundation
import PassKit
import SwiftUI

extension PaymentItemListScreen {

    class ViewModel: NSObject, ObservableObject, PKPaymentAuthorizationViewControllerDelegate {

        @Published var paymentProductRows: [PaymentProductsRow] = []
        @Published var accountsOnFile: [PaymentProductsRow] = []
        @Published var showSuccessScreen: Bool = false
        @Published var showBottomSheet: Bool = false
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        @Published var showAlert: Bool = false
        @Published var infoText: String = ""

        @Published var showCardProductScreen: Bool = false

        var context: PaymentContext {
            ConnectSDK.paymentConfiguration.paymentContext
        }
        var paymentItems: PaymentItems?
        var selectedPaymentItem: PaymentItem?
        var selectedAccountOnFile: AccountOnFile?
        var hasAccountsOnFile: Bool = false
        var preparedPaymentRequest: PreparedPaymentRequest?

        var applePayPaymentProduct: PaymentProduct?
        var summaryItems: [PKPaymentSummaryItem] = []
        var authorizationViewController: PKPaymentAuthorizationViewController?

        init(paymentItems: PaymentItems?) {
            super.init()
            self.paymentItems = paymentItems
            self.hasAccountsOnFile = paymentItems?.hasAccountsOnFile ?? false
            prepareItems(paymentItems: paymentItems)
        }

        func didSelect(item: PaymentProductsRow, accountOnFile: Bool) {
            // ***************************************************************************
            //
            // After selecting a payment product or an account on file associated to a
            // payment product in the payment product selection screen, the ConnectSDK.clientApi
            // object is used to retrieve all information for this payment product.
            //
            // Afterwards, a screen is shown that allows the user to fill in all
            // relevant information, unless the payment product has no fields.
            // This screen is also not part of the SDK and is offered for demonstration
            // purposes only.
            //
            // If the payment product has no fields, the merchant is responsible for
            // fetching the URL for a redirect to a third party and show the corresponding
            // website.
            //
            // ***************************************************************************
            guard let paymentItem = paymentItems?.paymentItem(withIdentifier: item.paymentProductIdentifier) else {
                fatalError("should not be empty")
            }

            isLoading = true

            if paymentItem is BasicPaymentProduct {
                ConnectSDK.clientApi.paymentProduct(
                    withId: paymentItem.identifier,
                    success: { paymentProduct in
                        if paymentItem.identifier.isEqual(SDKConstants.kApplePayIdentifier) {
                            self.isLoading = false
                            self.showApplePayPaymentItem(paymentProduct: paymentProduct)
                        } else {
                            self.isLoading = false

                            if paymentProduct.fields.paymentProductFields.count > 0 {
                                let tempAccountOnFile: AccountOnFile?
                                if accountOnFile {
                                    tempAccountOnFile =
                                    paymentProduct.accountOnFile(withIdentifier: item.accountOnFileIdentifier)
                                    self.selectedAccountOnFile = tempAccountOnFile
                                    self.selectedPaymentItem = paymentProduct
                                    self.show(paymentItem: paymentProduct)
                                } else {
                                    self.selectedAccountOnFile = nil
                                    self.selectedPaymentItem = paymentProduct
                                    self.show(paymentItem: paymentProduct)
                                }
                            } else {
                                self.showBottomSheet(text: "ProductNotAvailable".localized)
                            }
                        }
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
            } else if paymentItem is BasicPaymentProductGroup {
                ConnectSDK.clientApi.paymentProductGroup(
                    withId: paymentItem.identifier,
                    success: { paymentProductGroup in
                        self.isLoading = false
                        self.selectedAccountOnFile = nil
                        self.selectedPaymentItem = paymentProductGroup
                        self.show(paymentItem: paymentProductGroup)
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
        }

        // MARK: - Helpers
        private func show(paymentItem: PaymentItem) {
            if (paymentItem is PaymentProductGroup && paymentItem.identifier == "cards") ||
                (paymentItem as? PaymentProduct)?.paymentMethod == "card" {
                self.showCardProductScreen = true
            } else {
                self.showBottomSheet(text: "ProductNotAvailable".localized)
            }
        }

        func prepareItems(paymentItems: PaymentItems?) {
            guard let paymentItems = paymentItems else { return }

            if hasAccountsOnFile {
                self.accountsOnFile =
                    generateRowsFrom(accountsOnFile: paymentItems.accountsOnFile, paymentItems: paymentItems)
            }
            self.paymentProductRows = generateRowsFrom(paymentItems: paymentItems)
        }

        private func generateRowsFrom(paymentItems: PaymentItems) -> [PaymentProductsRow] {
            var items: [PaymentProductsRow] = []

            for paymentItem in paymentItems.paymentItems.sorted(by: { paymentItemA, paymentItemB in
                return paymentItemA.displayHints.displayOrder ?? Int.max <
                    paymentItemB.displayHints.displayOrder ?? Int.max
            }) {
                let paymentProductKey = localizationKey(with: paymentItem)
                let paymentProductValue =
                    NSLocalizedString(
                        paymentProductKey,
                        tableName: AppConstants.assetsLocalizable,
                        bundle: AppConstants.assetsBundle,
                        value: "",
                        comment: ""
                    )
                let row = PaymentProductsRow(name: paymentProductValue,
                                             accountOnFileIdentifier: "",
                                             paymentProductIdentifier: paymentItem.identifier,
                                             logo: paymentItem.displayHints.logoImage ?? UIImage())
                items.append(row)

            }
            return items
        }

        private func generateRowsFrom(
            accountsOnFile: [AccountOnFile],
            paymentItems: PaymentItems
        ) -> [PaymentProductsRow] {
            var items: [PaymentProductsRow] = []

            for accountOnFile in accountsOnFile.sorted(by: { (accountOnFileA, accountOnFileB) -> Bool in
                paymentItems.paymentItem(
                    withIdentifier: accountOnFileA.paymentProductIdentifier
                )?.displayHints.displayOrder ?? Int.max <
                    paymentItems.paymentItem(
                        withIdentifier: accountOnFileB.paymentProductIdentifier
                    )?.displayHints.displayOrder ?? Int.max
            }) {

                if let product = paymentItems.paymentItem(withIdentifier: accountOnFile.paymentProductIdentifier) {
                    let row = PaymentProductsRow(name: accountOnFile.label,
                                                 accountOnFileIdentifier: accountOnFile.identifier,
                                                 paymentProductIdentifier: accountOnFile.paymentProductIdentifier,
                                                 logo: product.displayHints.logoImage ?? UIImage())
                    items.append(row)
                }
            }
            return items
        }

        private func localizationKey(with paymentItem: BasicPaymentItem) -> String {
            switch paymentItem {
            case is BasicPaymentProduct:
                return "gc.general.paymentProducts.\(paymentItem.identifier).name"

            case is BasicPaymentProductGroup:
                return "gc.general.paymentProductGroups.\(paymentItem.identifier).name"

            default:
                return ""
            }
        }

        private func showAlert(text: String) {
            errorMessage = text
            showAlert = true
        }

        private func showBottomSheet(text: String) {
            infoText = text
            showBottomSheet = true
        }

        // MARK: - ApplePay selection handling

        func showApplePayPaymentItem(paymentProduct: PaymentProduct?) {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "13.0") &&
               PKPaymentAuthorizationViewController.canMakePayments() {
                guard let paymentProduct = paymentProduct else {
                    return
                }

                // ***************************************************************************
                //
                // We retrieve the networks from the paymentProduct and then feed it to the
                // Apple Pay configuration.
                //
                // Then a view controller for Apple Pay will be shown.
                //
                // ***************************************************************************

                guard let networks  = paymentProduct.paymentProduct302SpecificData?.networks else {
                    self.showAlert(text: "PaymentProductNetworksErrorExplanation".localized)
                    return
                }

                let availableNetworks = networks.map { PKPaymentNetwork(rawValue: $0) }

                self.showApplePaySheet(for: paymentProduct, context: context, withAvailableNetworks: availableNetworks)
            }
        }

        func showApplePaySheet(
            for paymentProduct: PaymentProduct,
            context: PaymentContext,
            withAvailableNetworks paymentNetworks: [PKPaymentNetwork]
        ) {
            if UserDefaults.standard.object(forKey: AppConstants.MerchantId) == nil {
                return
            }

            // This merchant should be the merchant id specified in the merchants developer portal.
            let merchantId = UserDefaults.standard.value(forKey: AppConstants.MerchantId) as? String ?? ""

            generateSummaryItems(context: context)
            let paymentRequest = PKPaymentRequest()

            if let acquirerCountry = paymentProduct.acquirerCountry,
               !acquirerCountry.isEmpty {
                paymentRequest.countryCode = acquirerCountry
            } else {
                paymentRequest.countryCode = context.countryCode
            }

            paymentRequest.currencyCode = context.amountOfMoney.currencyCode
            paymentRequest.supportedNetworks = paymentNetworks
            paymentRequest.paymentSummaryItems = summaryItems
            paymentRequest.merchantCapabilities = [.capability3DS, .capabilityDebit, .capabilityCredit]

            // This merchant id is set in the merchants apple developer portal and is linked to a certificate
            paymentRequest.merchantIdentifier = merchantId

            // These shipping contact fields are optional and can be chosen by the merchant
            paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
            authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            authorizationViewController?.delegate = self

            // The authorizationViewController will be nil if the paymentRequest was incomplete or not created correctly
            if let authorizationViewController = authorizationViewController,
               PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
                applePayPaymentProduct = paymentProduct
                UIApplication.shared.rootViewController?.present(
                    authorizationViewController,
                    animated: true,
                    completion: nil
                )
            }
        }

        func generateSummaryItems(context: PaymentContext) {

            // ***************************************************************************
            //
            // The summaryItems for the paymentRequest is a list of values with the last
            // value being the total and having the name of the merchant as label.
            //
            // The values are specified in cents and converted to a NSDecimalNumber with
            // a exponent of -2.
            //
            // You can add subtotal, shipping, etc. to the items below
            //
            // ***************************************************************************

            let total = context.amountOfMoney.totalAmount

            var summaryItems = [PKPaymentSummaryItem]()

            summaryItems.append(
                PKPaymentSummaryItem(
                    label: "Merchant Name",
                    amount: NSDecimalNumber(mantissa: UInt64(total), exponent: -2, isNegative: false),
                    type: .final
                )
            )

            self.summaryItems = summaryItems
        }

        // MARK: - Payment request target

        func didSubmitPaymentRequest(_ paymentRequest: PaymentRequest, success: (() -> Void)?, failure: (() -> Void)?) {
            isLoading = true

            ConnectSDK.encryptPaymentRequest(
                paymentRequest,
                success: { preparedPaymentRequest in
                    self.isLoading = false

                    // ***************************************************************************
                    //
                    // The information contained in preparedPaymentRequest is stored in such a way
                    // that it can be sent to the Worldline Global Collect platform via your server.
                    //
                    // ***************************************************************************
                    self.preparedPaymentRequest = preparedPaymentRequest
                    success?()
                    self.showSuccessScreen = true
                },
                failure: { error in
                    self.isLoading = false
                    self.showAlert(text: error.localizedDescription)

                    failure?()
                },
                apiFailure: { errorResponse in
                    self.isLoading = false
                    self.showAlert(text: errorResponse.errors[0].message)

                    failure?()
                }
            )
        }

        // MARK: - PKPaymentAuthorizationViewControllerDelegate
        // Sent to the delegate after the user has acted on the payment request.  The application
        // should inspect the payment to determine whether the payment request was authorized.
        //
        // If the application requested a shipping address then the full addresses is now part of the payment.
        //
        // The delegate must call completion with an appropriate authorization status, as may be determined
        // by submitting the payment credential to a processing gateway for payment authorization.
        //
        // MARK: - PKPaymentAuthorizationViewControllerDelegate
        // Sent to the delegate after the user has acted on the payment request.  The application
        // should inspect the payment to determine whether the payment request was authorized.
        //
        // If the application requested a shipping address then the full addresses is now part of the payment.
        //
        // The delegate must call completion with an appropriate authorization status, as may be determined
        // by submitting the payment credential to a processing gateway for payment authorization.
        func paymentAuthorizationViewController(
            _ controller: PKPaymentAuthorizationViewController,
            didAuthorizePayment payment: PKPayment,
            completion: @escaping (PKPaymentAuthorizationStatus) -> Void
        ) {
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                execute: {() -> Void in

                    // ***************************************************************************
                    //
                    // The information contained in preparedPaymentRequest is stored in such a way
                    // that it can be sent to the Worldline Global Collect platform via your server.
                    //
                    // ***************************************************************************

                    guard let applePayPaymentProduct = self.applePayPaymentProduct else {
                        Macros.DLog(message: "Invalid Apple pay product.")
                        return
                    }

                    let request = PaymentRequest(paymentProduct: applePayPaymentProduct)
                    guard let paymentDataString =
                            String(data: payment.token.paymentData, encoding: String.Encoding.utf8) else {
                        completion(.failure)
                        return
                    }
                    request.setValue(forField: "encryptedPaymentData", value: paymentDataString)
                    request.setValue(forField: "transactionId", value: payment.token.transactionIdentifier)

                    self.didSubmitPaymentRequest(request, success: {() -> Void in
                        completion(.success)
                    }, failure: {() -> Void in
                        completion(.failure)
                    })
                }
            )
        }

        // Sent to the delegate when payment authorization is finished.  This may occur when
        // the user cancels the request, or after the PKPaymentAuthorizationStatus parameter of the
        // paymentAuthorizationViewController:didAuthorizePayment:completion: has been shown to the user.
        //
        // The delegate is responsible for dismissing the view controller in this method.

        @objc func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
            applePayPaymentProduct = nil
            controller.dismiss(animated: true, completion: { return })
        }

        // Sent when the user has selected a new payment card.  Use this delegate callback if you need to
        // update the summary items in response to the card type changing (for example, applying credit card surcharges)
        //
        // The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
        // until it has invoked the completion block.

        func paymentAuthorizationViewController(
            _ controller: PKPaymentAuthorizationViewController,
            didSelect paymentMethod: PKPaymentMethod,
            completion: @escaping ([PKPaymentSummaryItem]) -> Void
        ) {
            completion(summaryItems)
        }

    }
}
