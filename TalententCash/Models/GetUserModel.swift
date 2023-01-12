// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let contactDetails = try? newJSONDecoder().decode(ContactDetails.self, from: jsonData)

import UIKit
import Combine

// MARK: - ContactDetails
class QuickLoginModel: Codable {
    let status: Bool
    let message: String
    let user: User?
}




