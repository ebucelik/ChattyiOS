//
//  ReportReason.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.08.23.
//

import Foundation

enum ReportReason: String, CaseIterable {
    case dontLikeIt = "I just don't like it"
    case itsSpam = "It's spam"
    case nudityOrSexualActivity = "Nudity or sexual activity"
    case hateSpeechOrSymbols = "Hate speech or symbols"
    case falseInformation = "False information"
    case bullyingOrHarassment = "Bullying or harassment"
    case scamOrFraud = "Scam or fraud"
    case violenceOrDangerousOrganisations = "Violance or dangerous organisations"
    case saleOfIllegalOrRegulatedGoods = "Sale of illegal or regulated goos"
    case suicideOrSelfInjury = "Suicide or self-injury"
    case eatingDisorders = "Eating disorders"
    case reportAsUnlawful = "Report as unlawful"
    case somethingElse = "Something else"
    case none = ""
}
