//
//  RepresentativeInfoByAddress.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/26/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents the political geography and representative information for a single address.
public struct RepresentativeInfoByAddress: CivicInformationResponse {
    /// Identifies what kind of resource this is. Value: the fixed string "civicinfo#representativeInfoResponse".
    public var kind: String
    /// The normalized version of the requested address.
    public var requestedAddress: Address
    /// Political geographic divisions that contain the requested address.
    public var divisions: [Division]
    /// Elected offices referenced by the divisions listed above. Will only be present if `includeOffices` was true in the request.
    public var offices: [Office]?
    /// Officials holding the offices listed above. Will only be present if `includeOffices` was true in the request.
    public var officials: [Official]?
    
    /// Represents an address within Google's Civic Information.
    public struct Address: Codable {
        /// The name of the location.
        public var name: String
        /// The street name and number of this address.
        public var line1: String
        /// The second line the address, if needed.
        public var line2: String?
        /// The third line of the address, if needed.
        public var line3: String?
        /// The city or town for the address.
        public var city: String
        /// The US two letter state abbreviation of the address.
        public var state: String
        /// The US Postal Zip Code of the address.
        public var zip: String
        
        private enum CodingKeys: String, CodingKey {
            case name = "locationName"
            case line1
            case line2
            case line3
            case city
            case state
            case zip
        }
    }
    
    /// Represents a political geographic divisions that contain the requested address.
    public struct Division: Codable {
        /// The unique Open Civic Data identifier for this division.
        public var key: Key
        
        /// Represents the unique Open Civic Data identifier for this division.
        public struct Key: Codable {
            /// The name of the division.
            public var name: String
            /// Any other valid OCD IDs that refer to the same division. Because OCD IDs are meant to be human-readable and at least somewhat predictable, there are occasionally several identifiers for a single division. These identifiers are defined to be equivalent to one another, and one is always indicated as the primary identifier. The primary identifier will be returned in ocd_id above, and any other equivalent valid identifiers will be returned in this list. For example, if this division's OCD ID is ocd-division/country:us/district:dc, this will contain ocd-division/country:us/state:dc.
            public var alsoKnownAs: [String]
            /// List of indices in the offices array, one for each office elected from this division. Will only be present if `includeOffices` was true in the request.
            public var officeIndices: [Int]?
        }
        
        private enum CodingKeys: String, CodingKey {
            case key = "(key)"
        }
    }
    
    /// Represents the elected offices referenced by the divisions.
    public struct Office: Codable {
        /// The OCD ID of the division with which this office is associated.
        public var divisionID: String
        /// The levels of government of which this office is part. There may be more than one in cases where a jurisdiction effectively acts at two different levels of government; for example, the mayor of the District of Columbia acts at "locality" level, but also effectively at both administrativeArea2 and administrativeArea1.
        public var levels: [Level]
        /// The human-readable name of the office.
        public var name: String
        /// List of indices in the officials array of people who presently hold this office.
        public var officialIndices: [Int]
        /// The roles which this office fulfills. Roles are not meant to be exhaustive, or to exactly specify the entire set of responsibilities of a given office, but are meant to be rough categories that are useful for general selection from or sorting of a list of offices.
        public var roles: [Role]
        /// A list of sources for this office. If multiple sources are listed, the data has been aggregated from those sources.
        public var sources: [Source]
        
        /// The office level that should be used to filter results.
        public enum Level: String, Codable {
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
        public enum Role: String, Codable {
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
        
        /// Represents a source used to populate the data in Google's Civic Information.
        public struct Source: Codable {
            /// The name of the data source.
            public var name: String
            /// Whether this data comes from an official government source.
            public var official: Bool
        }
        
        private enum CodingKeys: String, CodingKey {
            case divisionID = "divisionId"
            case levels
            case name
            case officialIndices
            case roles
            case sources
        }
    }
    
    /// Represents a government official and their contact information in Google's Civic Information.
    public struct Official: Codable {
        /// The official's name.
        public var name: String
        /// The full name of the party the official belongs to.
        public var party: String
        /// Addresses at which to contact the official.
        public var address: [Address]
        /// The direct email addresses for the official.
        public var emails: [String]
        /// The official's public contact phone numbers.
        public var phones: [String]
        /// A URL for a photo of the official.
        public var photoURL: URL
        /// The official's public website URLs.
        public var urls: [URL]
        
        public struct Channel: Codable {
            public var id: String
            public var type: String
        }
        
        private enum CodingKeys: String, CodingKey {
            case name
            case party
            case address
            case emails
            case phones
            case photoURL = "photoUrl"
            case urls
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case requestedAddress = "normalizedInput"
        case divisions
        case offices
        case officials
    }
}
