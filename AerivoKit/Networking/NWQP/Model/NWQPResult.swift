//
//  NWQPResult.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/18/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a result returned by the National Water Quality Portal.
public struct NWQPResult: Codable {
    /// The organization that provided the result.
    public var organization: [Organization]
    
    /// Represents an organization within the National Water Quality Portal.
    public struct Organization: Codable {
        /// A description of the organization's information.
        public var description: Description
        /// The activity from the organization.
        public var activity: [Activity]
        
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
        
        /// Represents activity coming from the organization.
        public struct Activity: Codable {
            /// A description of the activity.
            public var description: Description
            /// A description of the sample.
            public var sample: Sample
            /// A description of the result.
            public var result: Result
            
            /// Represents a description of the activity.
            public struct Description: Codable {
                /// The `id` of the activity.
                public var id: String
                /// The type of the activity.
                public var typeCode: String
                /// The media name of the activity
                public var mediaName: String
                /// The media subdivision name of the activity.
                public var mediaSubdivisionName: String
                /// The activity start date.
                public var startDate: Date
                /// The organization conducting the activity.
                public var conductionOrganization: String
                /// The id of the monitoring location.
                public var monitoringLocationID: String
                /// The condition of the hydrolics.
                public var hydrolicCondition: String
                /// The name of the hydrolic event.
                public var hydrolicEvent: String
                
                private enum CodingKeys: String, CodingKey {
                    case id = "ActivityIdentifier"
                    case typeCode = "ActivityTypeCode"
                    case mediaName = "ActivityMediaName"
                    case mediaSubdivisionName = "ActivityMediaSubdivisionName"
                    case startDate = "ActivityStartDate"
                    case conductionOrganization = "ActivityConductingOrganizationText"
                    case monitoringLocationID = "MonitoringLocationIdentifier"
                    case hydrolicCondition = "HydrologicCondition"
                    case hydrolicEvent = "HydrologicEvent"
                }
            }
            
            /// Represents a description of the sample.
            public struct Sample: Codable {
                /// The method used for collecting the sample.
                public var collectionMethod: CollectionMethod
                /// The name of the equipment that produced the sample.
                public var equipmentName: String
                
                /// Represents the method used for collecting the sample.
                public struct CollectionMethod: Codable {
                    /// The identifier of the collection method.
                    public var id: String
                    /// The collection method identifier context.
                    public var identifierContext: String
                    /// The name of the method used to collect the data.
                    public var name: String
                    
                    private enum CodingKeys: String, CodingKey {
                        case id = "MethodIdentifier"
                        case identifierContext = "MethodIdentifierContext"
                        case name = "MethodName"
                    }
                }
                
                private enum CodingKeys: String, CodingKey {
                    case collectionMethod = "SampleCollectionMethod"
                    case equipmentName = "SampleCollectionEquipmentName"
                }
            }
            
            /// Represents a description of the result.
            public struct Result: Codable {
                /// The description of the result.
                public var description: Description
                /// The analytical method used to produce the result.
                public var analyticalMethod: AnalyticalMethod
                /// The information of the laboratory that produced the result.
                public var labInformation: LabInformation
                
                /// Represents a description of the result.
                public struct Description: Codable {
                    /// The name of the characteristic this result is providing information about.
                    public var characteristicName: CharacteristicName
                    /// The measurement information.
                    public var measurement: Measurement
                    /// The `id` of the status.
                    public var statusID: String
                    /// The value type of the result.
                    public var valueType: String
                    /// The USGSP code for the information.
                    public var usgspCode: String
                    
                    /// Represents a name of the characteristics.
                    public enum CharacteristicName: String, Codable {
                        case waterTemperature = "Temperature, water"
                    }
                    
                    /// Represents a measurement for the result.
                    public struct Measurement: Codable {
                        /// The value of the measurement.
                        public var value: Double
                        /// The unit code of the measurement.
                        public var unitCode: UnitCode
                        
                        /// Represents a unit code for the measurement.
                        public enum UnitCode: String, Codable {
                            case celsius = "deg C"
                        }
                        
                        private enum CodingKeys: String, CodingKey {
                            case value = "ResultMeasureValue"
                            case unitCode = "MeasureUnitCode"
                        }
                    }
                    
                    private enum CodingKeys: String, CodingKey {
                        case characteristicName = "CharacteristicName"
                        case measurement = "ResultMeasure"
                        case statusID = "ResultStatusIdentifier"
                        case valueType = "ResultValueTypeName"
                        case usgspCode = "USGSPCode"
                    }
                }
                
                /// Represents the analytical method used to produce the result.
                public struct AnalyticalMethod: Codable {
                    /// The id of the analytical method.
                    public var id: String
                    /// The identifier context of the analytical method.
                    public var identifierContext: String
                    /// The name of the analytical method.
                    public var name: String
                    /// The description of the analytical method.
                    public var descriptionText: String
                    
                    private enum CodingKeys: String, CodingKey {
                        case id = "MethodIdentifier"
                        case identifierContext = "MethodIdentifierContext"
                        case name = "MethodName"
                        case descriptionText = "MethodDescriptionText"
                    }
                }
                
                /// Represents the laboratory information of the lab that produced the result.
                public struct LabInformation: Codable {
                    /// The name of the laboratory that produced the result.
                    public var name: String
                    
                    private enum CodingKeys: String, CodingKey {
                        case name = "LaboratoryName"
                    }
                }
                
                private enum CodingKeys: String, CodingKey {
                    case description = "ResultDescription"
                    case analyticalMethod = "ResultAnalyticalMethod"
                    case labInformation = "ResultLabInformation"
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case description = "ActivityDescription"
                case sample = "SampleDescription"
                case result = "Result"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case description = "OrganizationDescription"
            case activity = "Activity"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case organization = "Organization"
    }
}
