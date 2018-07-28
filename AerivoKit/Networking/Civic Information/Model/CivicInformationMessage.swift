//
//  CivicInformationMessage.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/27/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

public enum CivicInformationMessage {
    case subject(placeName: String)
    case messageBody(officialsName: String, placeName: String)
    
    public var messageValue: String {
        switch self {
        case .subject(placeName: let placeName):
             return "Enviornmental Quality Concern at \(placeName)"
        case .messageBody(officialsName: let officialsName, placeName: let placeName):
            return """
            The Honorable \(officialsName)
            
            Dear \(officialsName):
            
            I am primarily concerned about the enviornmental quality at \(placeName) because it seems to be reaching very high levels. I strongly believe that more regulation and resources need to be provided to create a safer, cleaner world that future generations may enjoy.
            
            With record breaking temperatures, melting glaciers, and rising sea levels, I believe that an important step is to start taking action in our communities. Therefore, I would be very appreciative if legislation can be passed to fix this growing issue.
            
            Thank you for your consideration of my concern on this matter. I believe it is an important issue, and would like to see the legislation (pass, fail, or be amended) to ensure effective enviornmental protection for our country.
            
            Sincerely,
            
            Your name,
            Address
            Phone Number
            Email Address
            """
        }
    }
}
