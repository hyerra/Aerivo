//
//  NWQPStation.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/19/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents the stations available in the National Water Quality Portal.
public struct NWQPStation: NWQPResponse {
    /// The organization that the station belongs to.
    public var organizations: [Organization]?
    
    public struct Organization: Codable {
        /// A description of the information of the organization.
        public var description: Description
        /// The monitoring location that belongs to the organiation.
        public var monitoringLocations: [MonitoringLocation]
        
        /// Represents a description of the organization.
        public struct Description: Codable {
            /// A designator used to uniquely identify a unique business establishment within a context.
            public var id: String
            /// The legal designator of an organization.
            public var formalName: String
            
            private enum CodingKeys: String, CodingKey {
                case id = "OrganizationIdentifier"
                case formalName = "OrganizationFormalName"
            }
        }
        
        /// Represents a monitoring location.
        public struct MonitoringLocation: Codable {
            /// A designator used to describe the unique name, number, or code assigned to identify the monitoring location.
            public var identity: Identity
            /// The geospatial information of the monitoring location.
            public var geospatial: Geospatial
            
            /// Represents the identifying information for the monitoring location.
            public struct Identity: Codable {
                /// A designator used to describe the unique name, number, or code assigned to identify the monitoring location.
                public var locationID: String
                /// The designator specified by the sampling organization for the site at which sampling or other activities are conducted.
                public var locationName: String
                /// The descriptive name for a type of monitoring location.
                public var locationType: String
                /// The 8 digit federal code used to identify the hydrologic unit of the monitoring location to the cataloging unit level of precision.
                public var huc: String
                /// The drainage basin of a lake, stream, wetland, or estuary site.
                public var drainageArea: DrainageArea?
                
                /// Represents the drainage area of the location.
                public struct DrainageArea: Codable {
                    /// The drainage basin of a lake, stream, wetland, or estuary site.
                    public var value: Double
                    /// The code that represents the unit for measuring the item.
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
                /// The measure of the angular distance on a meridian north or south of the equator.
                public var latitude: Double
                /// The measure of the angular distance on a meridian east or west of the prime meridian.
                public var longitude: Double
                /// The number that represents the proportional distance on the ground for one unit of measure on the map or photo.
                public var sourceMapScaleNumeric: Double?
                /// The horizontal measure of the relative accuracy of the latitude and longitude coordinates.
                public var horizontalAccuracy: HorizontalAccuracy?
                /// The name that identifies the method used to determine the latitude and longitude coordinates for a point on the earth.
                public var horizontalCollectionMethodName: String?
                /// The name that describes the reference datum used in determining latitude and longitude coordinates.
                public var horizontalCoordinateReferenceSystemDatumName: String?
                /// The measure of elevation, above or below a reference datum.
                public var verticalMeasurement: VerticalMeasurement?
                /// The vertical measure of the relative accuracy of the latitude and longitude coordinates.
                public var verticalAccuracy: VerticalAccuracy?
                /// The name that identifies the method used to collect the vertical measure of a reference point.
                public var verticalCollectionMethodName: String?
                /// The name of the reference datum used to determine the vertical measure.
                public var verticalCoordinateReferenceSystemDatumName: String?
                /// A code designator used to identify a primary geopolitical unit of the world.
                public var countryCode: String
                /// A code designator used to identify a principal administrative subdivision of the United States, Canada, or Mexico.
                public var stateCode: String
                /// A code designator used to identify a U.S. county or county equivalent.
                public var countyCode: String
                
                /// Represents the horizontal accuracy for the geospatial data.
                public struct HorizontalAccuracy: Codable {
                    /// The horizontal measure of the relative accuracy of the latitude and longitude coordinates.
                    public var value: String
                    /// The code that represents the unit for measuring the item.
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
                    /// The measure of elevation, above or below a reference datum.
                    public var value: Double
                    /// The code that represents the unit for measuring the item.
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
                    /// The vertical measure of the relative accuracy of the latitude and longitude coordinates.
                    public var value: Double
                    /// The code that represents the unit for measuring the item.
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
