//
//  JSONEncoder+ISO8601FS.swift
//  AerivoKit
//
//  Created by Harish Yerra on 7/14/18.
//  Copyright © 2018 Harish Yerra. All rights reserved.
//

import Foundation

extension Formatter {
    static let iso8601FS: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

extension JSONEncoder.DateEncodingStrategy {
    static let iso8601FS = custom { date, encoder throws in
        var container = encoder.singleValueContainer()
        try container.encode(Formatter.iso8601FS.string(from: date))
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601FS = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = Formatter.iso8601FS.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}
