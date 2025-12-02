//
//  CardProductScreenViewModel.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import Combine
import WorldlineConnectKit
import SwiftUI

extension CardProductScreen {

    class ViewModel: ObservableObject {

        // MARK: - Properties
        private var creditCardFirstSixDigits: String = ""
        private var tokenize = false
        private var formatter = StringFormatter()

        var fieldValues = [String: String]()
        var accountOnFile: AccountOnFile?
        var paymentItem: PaymentItem?
        var paymentRequest: PaymentRequest?
        var preparedPaymentRequest: PreparedPaymentRequest?
        var cardFieldLimit: Int = 6

        // MARK: - State
        @Published var creditCardField: PaymentProductField?
        @Published var creditCardFieldEnabled: Bool = true
        @Published var creditCardError: String?

        @Published var expiryDateField: PaymentProductField?
        @Published var expiryDateFieldEnabled: Bool = true
        @Published var expiryDateError: String?

        @Published var cvvField: PaymentProductField?
        @Published var cvvError: String?

        @Published var cardHolderField: PaymentProductField?
        @Published var cardHolderFieldEnabled: Bool = true
        @Published var cardHolderError: String?

        @Published var rememberPaymentDetails: Bool = false

        @Published var errorMessage: String?
        @Published var showAlert: Bool = false
        @Published var isLoading: Bool = false
        @Published var showEndScreen: Bool = false
        @Published var triedToSubmit: Bool = false
        @Published var payIsActive: Bool = false

        // MARK: - Life cycle
        init(paymentItem: PaymentItem?, accountOnFile: AccountOnFile?) {
            self.paymentItem = paymentItem
            self.accountOnFile = accountOnFile

            self.configureData()
        }

        // MARK: - Fields callbacks
        func didChangeCreditCardField() {
            evaluatePayButton()
            if self.triedToSubmit {
                self.validateCreditCard()
            }

         let inputData = self.unmaskedValue(forField: self.creditCardField)
            if inputData.count == self.cardFieldLimit && self.creditCardFirstSixDigits != inputData {
                self.creditCardFirstSixDigits = inputData
                self.getIinDetails()
            }
        }

        func didChangeExpiryDateField() {
            evaluatePayButton()
            if self.triedToSubmit {
                self.validateExpiryDate()
            }
        }

        func didChangeCvvField() {
            evaluatePayButton()
            if self.triedToSubmit {
                self.validateCVV()
            }
        }

        func didChangeCardHolder() {
            evaluatePayButton()
            if self.triedToSubmit {
                self.validateCardHolderName()
            }
        }

        // MARK: - Fields helpers
        func setValue(value: String, forField paymentProductField: PaymentProductField?) {
            let fieldId = paymentProductField?.identifier ?? ""
            fieldValues[fieldId] = value
        }

        func value(forField paymentProductField: PaymentProductField?) -> String {
            let fieldId = paymentProductField?.identifier ?? ""

            guard let value = fieldValues[fieldId] else {
                return ""
            }

            return value
        }

        func maskedValue(forField paymentProductField: PaymentProductField?) -> String {
            var cursorPosition = 0
            return maskedValue(forField: paymentProductField, cursorPosition: &cursorPosition)
        }

        func maskedValue(forField paymentProductField: PaymentProductField?, cursorPosition: inout Int) -> String {
            let value = self.value(forField: paymentProductField)
            guard let maskValue = mask(forField: paymentProductField) else {
                return value
            }
            return formatter.formatString(string: value, mask: maskValue, cursorPosition: &cursorPosition)
        }

        func unmaskedValue(forField paymentProductField: PaymentProductField?) -> String {
            let value = self.value(forField: paymentProductField)
            guard let maskValue = mask(forField: paymentProductField) else {
                return value
            }
            let unformattedString = formatter.unformatString(string: value, mask: maskValue)
            return unformattedString
        }

        func fieldIsPartOfAccountOnFile(paymentProductFieldId: String) -> Bool {
            return accountOnFile?.hasValue(forField: paymentProductFieldId) ?? false
        }

        func fieldIsReadOnly(paymentProductField: PaymentProductField?) -> Bool {
            let fieldId = paymentProductField?.identifier ?? ""
            if !fieldIsPartOfAccountOnFile(paymentProductFieldId: fieldId) {
                return false
            } else {
                return accountOnFile?.isReadOnly(field: fieldId) ?? false
            }
        }

        func placeholder(forField paymentProductField: PaymentProductField?) -> String? {
            guard let paymentProductField = paymentProductField else {
                return nil
            }

            let field = self.paymentItem?.paymentProductField(withId: paymentProductField.identifier)

            return field?.displayHints?.label
        }

        func mask(forField paymentProductField: PaymentProductField?) -> String? {
            let fieldId = paymentProductField?.identifier ?? ""
            let field = self.paymentItem?.paymentProductField(withId: fieldId )

            return field?.displayHints?.mask
        }

        // MARK: - Validators
        func evaluatePayButton() {
            if (self.unmaskedValue(forField: creditCardField).count >= 6 && creditCardError == nil) &&
               (value(forField: expiryDateField) != "" && expiryDateError == nil) &&
               (value(forField: cvvField) != "" && cvvError == nil) {
                payIsActive = true
            } else {
                payIsActive = false
            }
        }

        func validateCreditCard() {
            guard let creditCardField else {
                return
            }

            let errorMessageIds =
                creditCardField.validateValue(value: self.unmaskedValue(forField: self.creditCardField))

            creditCardError = getErrorMessage(validationErrors: errorMessageIds)
        }

        func validateExpiryDate() {
            guard let expiryDateField else {
                return
            }

            let errorMessageIds =
                expiryDateField.validateValue(value: self.unmaskedValue(forField: self.expiryDateField))

            expiryDateError = getErrorMessage(validationErrors: errorMessageIds)
        }

        func validateCVV() {
            guard let cvvField else {
                return
            }

            let errorMessageIds = cvvField.validateValue(value: self.unmaskedValue(forField: self.cvvField))

            cvvError = getErrorMessage(validationErrors: errorMessageIds)
        }

        func validateCardHolderName() {
            guard let cardHolderField else {
                return
            }

            let errorMessageIds =
                cardHolderField.validateValue(value: self.unmaskedValue(forField: self.cardHolderField))

            cardHolderError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func getErrorMessage(validationErrors: [ValidationError]) -> String? {
            return validationErrors.count != 0 ?
                ErrorHandler.errorMessage(for: validationErrors[0], withCurrency: false) :
                nil
        }

        // MARK: - General Helpers
        func createPaymentRequest() -> PaymentRequest {
            guard let paymentProduct = paymentItem as? PaymentProduct else {
                fatalError("Invalid paymentItem")
            }

            let paymentRequest =
                PaymentRequest(
                    paymentProduct: paymentProduct,
                    accountOnFile: accountOnFile,
                    tokenize: self.tokenize
                )

            let keys = Array(fieldValues.keys)

            for key: String in keys {
                if let value = fieldValues[key] {
                    paymentRequest.setValue(forField: key, value: value)
                }
            }

            return paymentRequest
        }

        func configureData() {
            guard let paymentItem else {
                return
            }

            self.creditCardField = paymentItem.paymentProductField(withId: AppConstants.CreditCardField)
            self.expiryDateField = paymentItem.paymentProductField(withId: AppConstants.ExpiryDateField)
            self.cvvField = paymentItem.paymentProductField(withId: AppConstants.CVVField)
            self.cardHolderField = paymentItem.paymentProductField(withId: AppConstants.CardHolderField)

            guard let accountOnFile = accountOnFile else {
                return
            }

            if fieldIsReadOnly(paymentProductField: creditCardField) {
                let fieldId = creditCardField?.identifier ?? ""
                let value = accountOnFile.maskedValue(forField: fieldId)
                self.setValue(value: value, forField: creditCardField)
                creditCardFieldEnabled = !accountOnFile.isReadOnly(field: fieldId)
            }

            if fieldIsReadOnly(paymentProductField: expiryDateField) {
                let fieldId = expiryDateField?.identifier ?? ""
                let value = accountOnFile.maskedValue(forField: fieldId)
                self.setValue(value: value, forField: expiryDateField)
                expiryDateFieldEnabled = !accountOnFile.isReadOnly(field: fieldId)
            }

            if fieldIsReadOnly(paymentProductField: cardHolderField) {
                let fieldId = cardHolderField?.identifier ?? ""
                let value = accountOnFile.maskedValue(forField: fieldId)
                self.setValue(value: value, forField: cardHolderField)
                cardHolderFieldEnabled = !accountOnFile.isReadOnly(field: fieldId)
            }
        }

        // MARK: - Actions
        func pay() {
            self.paymentRequest = self.createPaymentRequest()

            if accountOnFile == nil {
                validateCreditCard()
                validateExpiryDate()
                validateCVV()
                if let validateName = cardHolderField?.dataRestrictions.isRequired {
                    if validateName {
                        validateCardHolderName()
                    }
                }
            } else {
                validateCVV()
            }
            guard creditCardError == nil &&
                    expiryDateError == nil &&
                    cvvError == nil &&
                    cardHolderError == nil else {
                        triedToSubmit = true
                        return
                    }

            self.tokenize = rememberPaymentDetails

            guard let paymentRequest = self.paymentRequest else {
                return
            }

            self.isLoading = true

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
                    self.showEndScreen = true
                },
                failure: { error in
                    self.isLoading = false
                    self.showAlert(text: error.localizedDescription)
                },
                apiFailure: { errorResponse in
                    self.isLoading = false
                    self.showAlert(text: errorResponse.errors[0].message)
                }
            )
        }

        private func getIinDetails() {
            ConnectSDK.clientApi.iinDetails(
                forPartialCreditCardNumber: self.unmaskedValue(forField: self.creditCardField),
                success: { iinDetailsResponse in
                    switch iinDetailsResponse.status {
                    case .supported:
                        self.switchToPaymentProduct(paymentProductId: iinDetailsResponse.paymentProductId)
                    case .existingButNotAllowed:
                        self.creditCardError =
                            NSLocalizedString(
                                "gc.general.paymentProductFields.validationErrors.allowedInContext.label",
                                tableName: AppConstants.assetsLocalizable,
                                bundle: AppConstants.assetsBundle,
                                value: "",
                                comment:
                                    """
                                    The card you entered is not supported.
                                    Please enter another card or try another payment method.
                                    """
                            )
                    default:
                        self.showAlert(text: "iinUnknown".localized)
                    }
                },
                failure: { error in
                    self.showAlert(text: error.localizedDescription)
                },
                apiFailure: { errorResponse in
                    self.showAlert(text: errorResponse.errors[0].message)
                }
            )
        }

        private func switchToPaymentProduct(paymentProductId: String?) {
            if let paymentProductId {
                ConnectSDK.clientApi.paymentProduct(
                    withId: paymentProductId,
                    success: { paymentProduct in
                        self.paymentItem = paymentProduct
                        self.creditCardError = nil
                    },
                    failure: { error in
                        self.showAlert(text: error.localizedDescription)
                    },
                    apiFailure: { errorResponse in
                        self.showAlert(text: errorResponse.errors[0].message)
                    }
                )
            }
        }

        private func showAlert(text: String) {
            errorMessage = text
            showAlert = true
        }
    }
}
