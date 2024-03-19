//
//  ValidationErrorExtension.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import Foundation
import WorldlineConnectKit

extension ValidationError {
    @objc func errorMessageKey() -> String? {
        return nil
    }
}

extension ValidationErrorAllowed {
    @objc override func errorMessageKey() -> String? {
        return "allowedInContext"
    }
}

extension ValidationErrorEmailAddress {
    override func errorMessageKey() -> String? {
        return "emailAddress"
    }
}

extension ValidationErrorExpirationDate {
    override func errorMessageKey() -> String? {
        return "expirationDate"
    }
}

extension ValidationErrorFixedList {
    override func errorMessageKey() -> String? {
        return "fixedList"
    }
}

extension ValidationErrorIsRequired {
    override func errorMessageKey() -> String? {
        return "required"
    }
}

extension ValidationErrorLuhn {
    override func errorMessageKey() -> String? {
        return "luhn"
    }
}

extension ValidationErrorRegularExpression {
    override func errorMessageKey() -> String? {
        return "regularExpression"
    }
}

extension ValidationErrorTermsAndConditions {
    override func errorMessageKey() -> String? {
        return "termsAndConditions"
    }
}

extension ValidationErrorIBAN {
    override func errorMessageKey() -> String? {
        return "regularExpression"
    }
}

extension ValidationErrorResidentId {
    override func errorMessageKey() -> String? {
        return "residentIdNumber"
    }
}
