//
//  NWQPParameters.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/17/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents parameters that should be used within the National Water Quality Portal.
public struct NWQPParameters: Parameters {
    /// Latitude for radial search, expressed in decimal degrees.
    public var latitude: Double?
    /// Longitude for radial search, expressed in decimal degrees.
    public var longitude: Double?
    /// Distance for radial search, expressed in decimal miles.
    public var within: Double?
    /// Two-character Federal Information Processing Standard (FIPS) country code.
    public var countryCode: String?
    /// Two-character Federal Information Processing Standard (FIPS) country code, followed by a URL-encoded colon ("%3A"), followed by a two-digit FIPS state code.
    public var stateCode: String?
    /// Two-character Federal Information Processing Standard (FIPS) country code, followed by a URL-encoded colon ("%3A"), followed by a two-digit FIPS state code, followed by a URL-encoded colon ("%3A"), followed by a three-digit FIPS county code.
    public var countyCode: String?
    /// Each data collection station is assigned a unique site-identification number. Other agencies often use different site identification numbers for the same stations.
    public var siteID: String?
    /// For USGS organization IDs, append an upper-case postal-service state abbreviation to "USGS-" to identify the USGS office managing the data collection station records. However, a few US states are serviced by one USGS office.
    public var huc: String?
    /// These groups will be expanded as part of the ongoing collaboration between USGS and USEPA. See [domain service](http://www.waterqualitydata.us/Codes/Characteristictype?mimeType=xml) for valid types.
    public var characteristicType: CharacteristicType?
    /// Characteristic names identify different types of environmental measurements. The names are derived from the [USEPA Substance Registry System](http://iaspub.epa.gov/sor_internet/registry/substreg/home/overview/home.do) (SRS). USGS uses parameter codes for the same purpose and has [associated most parameters](http://www.waterqualitydata.us/public_srsnames.jsp) to SRS names.
    public var characteristicName: CharacteristicName?
    /// Include the parameter to stream compressed data. Compression often greatly increases throughput, thus expediting the request. Kml files will be returned in the kml-specific zip format, .kmz.
    public var zip: ShouldZip?
    /// By default, requests are submitted to all the data providers. However, a particular provider may be specified using this parameter.
    public var providers: Providers?
    /// Date of earliest desired data-collection activity.
    public var startDate: Date?
    /// Date of last desired data-collection activity.
    public var endDate: Date?
    /// Number of results to return per page.
    public var pageSize: Int?
    /// Allows for results to be paginated (especially useful for endpoints with many valid responses, allows for infinite scrolling). Use along with page size.
    public var page: Int?
    /// The mime type for the data to be returned in.
    public var mimeType: MimeType = .xml
    
    public init() { }
    
    /// The characteristic type to be queried for.
    public enum CharacteristicType: String, Codable {
        case biological = "Biological"
        case information = "Information"
        case majorInorganicsMetal = "Inorganics, Major, Metals"
        case majorInorganicsNonMetal = "Inorganics, Major, Non-metals"
        case minorInorganicsMetal = "Inorganics, Minor, Metals"
        case minorInorganicsNonMetal = "Inorganics, Minor, Non-metals"
        case microbiological = "Microbiological"
        case notAssigned = "Not Assigned"
        case nutrient = "Nutrient"
        case otherOrganics = "Organics, Other"
        case pcbOrganics = "Organics, PCBs"
        case pesticideOrganics = "Organics, Pesticide"
        case physical = "Physical"
        case population = "Population/Community"
        case radiochemical = "Radiochemical"
        case sediment = "Sediment"
        case stableIsotopes = "Stable Isotopes"
        case toxicity = "Toxicity"
    }
    
    /// The characteristic name to be queried for.
    public enum CharacteristicName: String, Codable {
        case beckBioticIndex = "Beck Biotic Index"
        case brillouinTaxonomicDiversityIndex = "Brillouin Taxonomic Diversity Index"
        case dissolvedOxygen = "Dissolved oxygen (DO)"
        case waterTemperature = "Temperature, water"
        case turbiditySeverity = "Turbidity"
        case hydrocarbons = "C12 Hydrocarbons"
        
        /// TODO: When Xcode-beta comes out remove this as this is all included in the Iterable protocol or whatever.
        static var allCases: [CharacteristicName] {
            return [.beckBioticIndex, .brillouinTaxonomicDiversityIndex, .dissolvedOxygen, .waterTemperature, .turbiditySeverity, .hydrocarbons]
        }
    }
    
    /// The providers that can be used to fetch data from.
    public enum Providers: String, Codable {
        case storet = "STORET"
        case nwis = "NWIS"
        case stewards = "STEWARDS"
    }
    
    /// Determines whether the results should be zipped or not.
    public enum ShouldZip: String, Codable {
        case yes
        case no
    }
    
    /// Determines whether the results should be returned in xml or json.
    public enum MimeType: String, Codable {
        case xml
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "long"
        case within
        case countryCode = "countrycode"
        case stateCode = "statecode"
        case countyCode = "countycode"
        case siteID = "siteid"
        case huc
        case characteristicType
        case characteristicName
        case zip
        case providers
        case startDate = "startDateLo"
        case endDate = "startDateHi"
        case pageSize = "pagesize"
        case page = "pagenumber"
        case mimeType
    }
}
