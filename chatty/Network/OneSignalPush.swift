//
//  OneSignalPush.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 22.08.23.
//

import Foundation

struct OneSignalPush: Codable {
    let appId: String
    let includeAliases: ExternalId
    let targetChannel: String
    let headings: [String: String]
    let contents: [String: String]
    let iosBadgeType: String
    let iosBadgeCount: Int

    struct ExternalId: Codable {
        let externalId: [String]

        init(externalId: [String]) {
            self.externalId = externalId
        }

        enum CodingKeys: String, CodingKey {
            case externalId = "external_id"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: OneSignalPush.ExternalId.CodingKeys.self)
            self.externalId = try container.decode([String].self, forKey: OneSignalPush.ExternalId.CodingKeys.externalId)
        }
    }

    init(appId: String,
         includeAliases: ExternalId,
         targetChannel: String,
         headings: [String : String],
         contents: [String : String],
         iosBadgeType: String = "Increase",
         iosBadgeCount: Int = 1) {
        self.appId = appId
        self.includeAliases = includeAliases
        self.targetChannel = targetChannel
        self.headings = headings
        self.contents = contents
        self.iosBadgeType = iosBadgeType
        self.iosBadgeCount = iosBadgeCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OneSignalPush.CodingKeys.self)
        appId = try container.decode(String.self, forKey: .appId)
        includeAliases = try container.decode(ExternalId.self, forKey: .includeAliases)
        targetChannel = try container.decode(String.self, forKey: .targetChannel)
        headings = try container.decode([String : String].self, forKey: .headings)
        contents = try container.decode([String : String].self, forKey: .contents)
        iosBadgeType = try container.decode(String.self, forKey: .iosBadgeType)
        iosBadgeCount = try container.decode(Int.self, forKey: .iosBadgeCount)
    }

    enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case includeAliases = "include_aliases"
        case targetChannel = "target_channel"
        case headings
        case contents
        case iosBadgeType = "ios_badgeType"
        case iosBadgeCount = "ios_badgeCount"
    }
}
