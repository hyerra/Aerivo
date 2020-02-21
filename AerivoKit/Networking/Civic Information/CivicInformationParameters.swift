//
//  CivicInformationParameters.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/26/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents parameters that should be used within Google's Civic Information.
protocol CivicInformationParameters: Parameters { }

/// Represents the parameters that can be used to look up political geography and representative information for a single address.
public struct RepresentativeInfoByAddressParameters: CivicInformationParameters {
    /// The address to look up. May only be specified if the field ocdId is not given in the URL.
    public var address: String?
    /// Whether to return information about offices and officials. If false, only the top-level district information will be returned. Defaults to `true`.
    public var includeOffices: Bool?
    /// A list of office levels to filter by. Only offices that serve at least one of these levels will be returned. Divisions that don't contain a matching office will not be returned.
    public var levels: [Level]?
    /// A list of office roles to filter by. Only offices fulfilling one of these roles will be returned. Divisions that don't contain a matching office will not be returned.
    public var roles: [Role]?
    /// The API Key that should be included with all requests to identify this project.
    public var key: String? = "YOUR API KEY HERE"
    
    public init() { }
    
    /// The office level that should be used to filter results.
    public enum Level: String, Encodable {
        case administrativeArea1
        case administrativeArea2
        case country
        case international
        case locality
        case regional
        case special
        case subLocality1
        case subLocality2
    }
    
    /// The office role that should be used to filter results.
    public enum Role: String, Encodable {
        case deputyHeadOfGovernment
        case executiveCouncil
        case governmentOfficer
        case headOfGovernment
        case headOfState
        case highestCourtJudge
        case judge
        case legislatorLowerBody
        case legislatorUpperBody
        case schoolBoard
        case specialPurposeOfficer
    }
    
}
