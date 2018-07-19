//
//  XMLEncoder+CustomDates.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/19/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

extension XMLEncoder.DateEncodingStrategy {
    static let iso8601FS = custom { date, encoder throws in
        var container = encoder.singleValueContainer()
        try container.encode(Formatter.iso8601FS.string(from: date))
    }
    
    static let nwqpFormat = custom { date, encoder throws in
        var container = encoder.singleValueContainer()
        try container.encode(Formatter.nwqpEncoderFormat.string(from: date))
    }
}

extension XMLDecoder.DateDecodingStrategy {
    static let iso8601FS = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = Formatter.iso8601FS.date(from: string) else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)") }
        return date
    }
    
    static let nwqpFormat = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = Formatter.nwqpDecoderFormat.date(from: string) else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)") }
        return date
    }
}
