//
//  NWQPStation.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/19/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents the stations available in the National Water Quality Portal.
public struct NWQPStation: Codable {
    /// The organization that the station belongs to.
    public var organizations: [Organization]?
    
    public struct Organization: Codable {
        /// A description of the information of the organization.
        public var description: Description
        /// The monitoring location that belongs to the organiation.
        public var monitoringLocations: [MonitoringLocation]
        
        /// Represents a description of the organization.
        public struct Description: Codable {
            /// The `id` of the organization.
            public var id: String
            /// The formal name of the organization.
            public var formalName: String
            
            private enum CodingKeys: String, CodingKey {
                case id = "OrganizationIdentifier"
                case formalName = "OrganizationFormalName"
            }
        }
        
        /// Represents a monitoring location.
        public struct MonitoringLocation: Codable {
            /// Identifying information for the monitoring location.
            public var identity: Identity
            /// The geospatial information of the monitoring location.
            public var geospatial: Geospatial
            
            /// Represents the identifying information for the monitoring location.
            public struct Identity: Codable {
                /// The identifier of the location.
                public var locationID: String
                /// The name of the location.
                public var locationName: String
                /// The type of the location.
                public var locationType: String
                /// The huc eight digit code of the location.
                public var huc: String
                /// The drainage area of the location.
                public var drainageArea: DrainageArea?
                
                /// Represents the drainage area of the location.
                public struct DrainageArea: Codable {
                    /// The value of the drainage area.
                    public var value: Double
                    /// The unit code of the drainage.
                    public var unitCode: UnitCode
                    
                    /// Represents a unit code for the drainage area.
                    public enum UnitCode: String, Codable {
                        case squareMiles = "sq mi"
                    }
                    
                    private enum CodingKeys: String, CodingKey {
                        case value = "MeasureValue"
                        case unitCode = "MeasureUnitCode"
                    }
                }
                
                private enum CodingKeys: String, CodingKey {
                    case locationID = "MonitoringLocationIdentifier"
                    case locationName = "MonitoringLocationName"
                    case locationType = "MonitoringLocationTypeName"
                    case huc = "HUCEightDigitCode"
                    case drainageArea = "DrainageAreaMeasure"
                }
            }
            
            /// Represents the geospatial information for the location.
            public struct Geospatial: Codable {
                /// The latitude of the location.
                public var latitude: Double
                /// The longitude of the location.
                public var longitude: Double
                /// The scale numeric for the source map.
                public var sourceMapScaleNumeric: Double?
                /// The horizontal accuracy of the geospatial data.
                public var horizontalAccuracy: HorizontalAccuracy?
                /// The collection method name for the horizontal dimension.
                public var horizontalCollectionMethodName: String?
                /// The horizontal coordinate reference system datum name.
                public var horizontalCoordinateReferenceSystemDatumName: String?
                /// The vertical measurement for the geospatial data.
                public var verticalMeasurement: VerticalMeasurement?
                /// The vertical accuracy of the geospatial data.
                public var verticalAccuracy: VerticalAccuracy?
                /// The collection method name for the vertical dimension.
                public var verticalCollectionMethodName: String?
                /// The vertical coordinate reference system datum name.
                public var verticalCoordinateReferenceSystemDatumName: String?
                /// The country code for the monitoring location.
                public var countryCode: String
                /// The state code for the monitoring location.
                public var stateCode: String
                /// The country code for the monitoring location.
                public var countyCode: String
                
                /// Represents the horizontal accuracy for the geospatial data.
                public struct HorizontalAccuracy: Codable {
                    /// The value of the horizontal accuracy.
                    public var value: String
                    /// The unit code of the horizontal accuracy.
                    public var unitCode: UnitCode
                    
                    /// Represents a unit code for the horizontal accuracy.
                    public enum UnitCode: String, Codable {
                        case seconds
                        case minutes
                        case m
                        case unknown = "Unknown"
                    }
                    
                    private enum CodingKeys: String, CodingKey {
                        case value = "MeasureValue"
                        case unitCode = "MeasureUnitCode"
                    }
                }
                
                /// Represents the vertical measurement for the geospatial data.
                public struct VerticalMeasurement: Codable {
                    /// The value of the vertical measurement.
                    public var value: Double
                    /// The unit code of the vertical measurement.
                    public var unitCode: UnitCode
                    
                    /// Represents a unit code for the vertical measurement.
                    public enum UnitCode: String, Codable {
                        case feet
                        case ft
                        case m
                    }
                    
                    private enum CodingKeys: String, CodingKey {
                        case value = "MeasureValue"
                        case unitCode = "MeasureUnitCode"
                    }
                }
                
                /// Represents the vertical accuracy of the geospatial data.
                public struct VerticalAccuracy: Codable {
                    /// The value of the vertical accuracy.
                    public var value: Double
                    /// The unit code of the vertical accuracy.
                    public var unitCode: UnitCode
                    
                    /// Represents a unit code for the vertical accuracy.
                    public enum UnitCode: String, Codable {
                        case feet
                    }
                    
                    private enum CodingKeys: String, CodingKey {
                        case value = "MeasureValue"
                        case unitCode = "MeasureUnitCode"
                    }
                }
                
                private enum CodingKeys: String, CodingKey {
                    case latitude = "LatitudeMeasure"
                    case longitude = "LongitudeMeasure"
                    case sourceMapScaleNumeric = "SourceMapScaleNumeric"
                    case horizontalAccuracy = "HorizontalAccuracyMeasure"
                    case horizontalCollectionMethodName = "HorizontalCollectionMethodName"
                    case horizontalCoordinateReferenceSystemDatumName = "HorizontalCoordinateReferenceSystemDatumName"
                    case verticalMeasurement = "VerticalMeasure"
                    case verticalAccuracy = "VerticalAccuracyMeasure"
                    case verticalCollectionMethodName = "VerticalCollectionMethodName"
                    case verticalCoordinateReferenceSystemDatumName = "VerticalCoordinateReferenceSystemDatumName"
                    case countryCode = "CountryCode"
                    case stateCode = "StateCode"
                    case countyCode = "CountyCode"
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case identity = "MonitoringLocationIdentity"
                case geospatial = "MonitoringLocationGeospatial"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case description = "OrganizationDescription"
            case monitoringLocations = "MonitoringLocation"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case organizations = "Organization"
    }
}
