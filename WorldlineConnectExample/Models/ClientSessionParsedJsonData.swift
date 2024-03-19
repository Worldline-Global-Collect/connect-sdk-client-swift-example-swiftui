//
//  StartPaymentParsedJsonData.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import Foundation

struct ClientSessionParsedJsonData: Codable {
    var clientId: String?
    var customerId: String?
    var baseUrl: String?
    var assetUrl: String?

    private enum CodingKeys: String, CodingKey {
        case clientId = "clientSessionId"
        case customerId = "customerId"
        case baseUrl = "clientApiUrl"
        case assetUrl = "assetUrl"
    }
}
