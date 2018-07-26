//
//  NWQPResult.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/18/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

/// Represents a result returned by the National Water Quality Portal.
public struct NWQPResult: NWQPResponse {
    /// The organization that provided the result.
    public var organizations: [Organization]?
    
    /// Represents an organization within the National Water Quality Portal.
    public struct Organization: Codable {
        /// A description of the organization's information.
        public var description: Description
        /// The activity from the organization.
        public var activity: [Activity]
        
        /// Represents a description of the organization.
        public struct Description: Codable {
            /// A designator used to uniquely identify a unique business establishment within a context.
            public var id: String?
            /// The legal designator of an organization.
            public var formalName: String?
            
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
            public var sample: Sample?
            /// A description of the result.
            public var results: [Result]
            
            /// Represents a description of the activity.
            public struct Description: Codable {
                /// Designator that uniquely identifies an activity within an organization.
                public var id: String
                /// The text describing the type of activity.
                public var typeCode: String
                /// Name or code indicating the environmental medium where the sample was taken.
                public var mediaName: String
                /// Name or code indicating the environmental matrix as a subdivision of the sample media.
                public var mediaSubdivisionName: String?
                /// The calendar date on which the field activity is started.
                public var startDate: Date
                /// A name of the Organization conducting an activity.
                public var conductingOrganization: String?
                /// A designator used to describe the unique name, number, or code assigned to identify the monitoring location.
                public var monitoringLocationID: String
                /// Hydrologic condition is the hydrologic condition that is represented by the sample collected (i.e. ? normal, falling, rising, peak stage).
                public var hydrolicCondition: String?
                /// A hydrologic event that is represented by the sample collected (i.e. - storm, drought, snowmelt).
                public var hydrolicEvent: String?
                
                private enum CodingKeys: String, CodingKey {
                    case id = "ActivityIdentifier"
                    case typeCode = "ActivityTypeCode"
                    case mediaName = "ActivityMediaName"
                    case mediaSubdivisionName = "ActivityMediaSubdivisionName"
                    case startDate = "ActivityStartDate"
                    case conductingOrganization = "ActivityConductingOrganizationText"
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
                    /// The identification number or code assigned by the method publisher.
                    public var id: String
                    /// Identifies the source or data system that created or defined the identifier.
                    public var identifierContext: String
                    /// The title that appears on the method from the method publisher.
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
                public var analyticalMethod: AnalyticalMethod?
                /// The information of the laboratory that produced the result.
                public var labInformation: LabInformation?
                
                /// Represents a description of the result.
                public struct Description: Codable {
                    /// The object, property, or substance which is evaluated or enumerated by either a direct field measurement, a direct field observation, or by laboratory analysis of material collected in the field.
                    public var characteristicName: CharacteristicName
                    /// The measurement information.
                    public var measurement: Measurement?
                    /// Indicates the acceptability of the result with respect to QA/QC criteria.
                    public var statusID: String?
                    /// A name that qualifies the process which was used in the determination of the result value (e.g., actual, estimated, calculated).
                    public var valueType: String
                    /// 5-digit number used in the US Geological Survey computerized data system, National Water Information System (NWIS), to uniquely identify a specific constituent.
                    public var usgspCode: String?
                    
                    /// Represents a name of the characteristics.
                    public enum CharacteristicName: String, Codable {
                        case beckBioticIndex = "Beck Biotic Index"
                        case brillouinTaxonomicDiversityIndex = "Brillouin Taxonomic Diversity Index"
                        case dissolvedOxygen = "Dissolved oxygen (DO)"
                        case waterTemperature = "Temperature, water"
                        case turbiditySeverity = "Turbidity"
                        case hydrocarbons = "C12 Hydrocarbons"
                    }
                    
                    /// Represents a measurement for the result.
                    public struct Measurement: Codable {
                        /// The reportable measure of the result for the chemical, microbiological or other characteristic being analyzed.
                        public var value: Double
                        /// The code that represents the unit for measuring the item.
                        public var unitCode: UnitCode
                        
                        /// Represents a unit code for the measurement.
                        public enum UnitCode: String, Codable {
                            case fahrenheit = "deg F"
                            case celsius = "deg C"
                            case milligramsPerLiter = "mg/l"
                            case nephelometricTurbidityRatioUnit = "NTRU"
                            case formazinNephelometricUnits = "FNU"
                            case nephelometricTurbidityUnits = "NTU"
                            
                            public var standardizedUnit: Unit {
                                switch self {
                                case .fahrenheit: return UnitTemperature.fahrenheit
                                case .celsius: return UnitTemperature.celsius
                                case .milligramsPerLiter: return UnitConcentrationMass.milligramsPerLiter
                                case .nephelometricTurbidityRatioUnit: return UnitTurbidity.nephelometricTurbidityRatioUnit
                                case .formazinNephelometricUnits: return UnitTurbidity.formazinNephelometricUnit
                                case .nephelometricTurbidityUnits: return UnitTurbidity.nephelometricTurbidityRatioUnit
                                }
                            }
                            
                            public var isCustomUnit: Bool {
                                switch self {
                                case .fahrenheit: return false
                                case .celsius: return false
                                case .milligramsPerLiter: return true
                                case .nephelometricTurbidityRatioUnit: return true
                                case .formazinNephelometricUnits: return true
                                case .nephelometricTurbidityUnits: return true
                                }
                            }
                        }
                        
                        private enum CodingKeys: String, CodingKey {
                            case value = "ResultMeasureValue"
                            case unitCode = "MeasureUnitCode"
                        }
                    }
                    
                    public var information: String {
                        switch characteristicName {
                        case .beckBioticIndex: return NSLocalizedString("Beck Biotic Index: A method for showing the quality of an environment by indicating the types of organisms present in it and their ability to live in polluted enviornments.", comment: "Description of the beck biotic index for measuring water quality.")
                        case .brillouinTaxonomicDiversityIndex: return NSLocalizedString("Brillouin Taxonomic Diversity Index: An index representing the diversity of organisims living in a body of water.", comment: "Description of the brillouin taxonomic diversity index for measuring water quality..")
                        case .dissolvedOxygen: return NSLocalizedString("Dissolved Oxygen: Amount of gaseous oxygen dissolved in the water. As dissolved oxygen levels drop below 5.0 mg/L, the aquatic life is put under stress.", comment: "Description of the dissolved oxygen for measuring water quality.")
                        case .waterTemperature: return NSLocalizedString("Water Temperature: Represents the temperature recorded in the water. The temperature of the water can influence many things such as the amount of oxygen and pH of the water. High temperatures can have a negative effect on the life in the water.", comment: "Description of the water temperature for measuring water quality.")
                        case .turbiditySeverity: return NSLocalizedString("Turbidity Severity: A measurement of how cloudy, opaque, or thick the water is. High amounts of turbidity can block light and smother/contaminate organisms. During periods of low flow, the turbidity should be less than 10 NTU.", comment: "Description of the turbidity severity for measuring water quality.")
                        case .hydrocarbons: return NSLocalizedString("Hydrocarbons: Natural sources of hydrocarbons include petroleum and natural gas deposits. Can be toxic to organisms if found in high amounts.", comment: "Description of hydrocarbons for measuring water quality.")
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
                    /// The identification number or code assigned by the method publisher.
                    public var id: String
                    /// Identifies the source or data system that created or defined the identifier.
                    public var identifierContext: String
                    /// The title that appears on the method from the method publisher.
                    public var name: String?
                    /// A brief summary that provides general information about the method.
                    public var descriptionText: String?
                    
                    private enum CodingKeys: String, CodingKey {
                        case id = "MethodIdentifier"
                        case identifierContext = "MethodIdentifierContext"
                        case name = "MethodName"
                        case descriptionText = "MethodDescriptionText"
                    }
                }
                
                /// Represents the laboratory information of the lab that produced the result.
                public struct LabInformation: Codable {
                    /// The name of the lab responsible for the result.
                    public var name: String?
                    
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
                case results = "Result"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case description = "OrganizationDescription"
            case activity = "Activity"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case organizations = "Organization"
    }
}
