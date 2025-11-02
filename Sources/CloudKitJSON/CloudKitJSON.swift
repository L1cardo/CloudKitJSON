//
//  CloudKitJSON.swift
//  CloudKitJSON
//
//  Created by Licardo on 2025/11/2.
//

import Foundation
import SwiftData

/// A property wrapper that seamlessly encodes/decodes Codable objects to JSON Data for SwiftData compatibility
/// This allows storing complex objects in SwiftData models without modifying the model structure
@propertyWrapper
@dynamicMemberLookup
public struct CloudKitJSON<T: Codable>: Codable {

    /// The stored JSON data - using var to allow mutations
    private var data: Data

    /// Initialize with a Codable object
    /// - Parameter object: The object to be encoded as JSON
    public init(_ object: T) {
        self.data = try! JSONEncoder().encode(object)
    }

    /// Initialize with wrapped value (for property wrapper syntax)
    /// - Parameter wrappedValue: The object to be encoded as JSON
    public init(wrappedValue: T) {
        self.init(wrappedValue)
    }

    /// Initialize from raw data (for Codable conformance)
    /// - Parameter data: Raw JSON data
    public init(data: Data) {
        self.data = data
    }

    // MARK: - Property Wrapper Implementation

    /// The wrapped value - automatically handles encoding/decoding
    public var wrappedValue: T {
        get {
            return try! JSONDecoder().decode(T.self, from: data)
        }
        set {
            // Directly encode and store the new value
            self.data = try! JSONEncoder().encode(newValue)
        }
    }

    /// Mutable proxy for property access
    public var mutable: MutableProxy<T> {
        return MutableProxy(self)
    }

    // MARK: - Codable Conformance

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let data = try? container.decodeIfPresent(Data.self, forKey: .data) {
            // Handle keyed container (SwiftData compatibility)
            self.data = data
        } else {
            // Handle single value container
            let container = try decoder.singleValueContainer()
            self.data = try container.decode(Data.self)
        }
    }

    public func encode(to encoder: Encoder) throws {
        // Try keyed container first for SwiftData compatibility
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }

    private enum CodingKeys: String, CodingKey {
        case data
    }
}

// MARK: - Dynamic Member Lookup for Direct Property Access

extension CloudKitJSON {

    /// Allows seamless read access to properties using dot syntax
    /// - Parameter keyPath: Key path to the desired property
    /// - Returns: The value of the property
    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        return wrappedValue[keyPath: keyPath]
    }
}

/// Mutable proxy for property modifications
@dynamicMemberLookup
public class MutableProxy<T: Codable> {
    private var cloudKitJSON: CloudKitJSON<T>

    init(_ cloudKitJSON: CloudKitJSON<T>) {
        self.cloudKitJSON = cloudKitJSON
    }

    /// Access and modify properties
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<T, U>) -> U {
        get {
            return cloudKitJSON.wrappedValue[keyPath: keyPath]
        }
        set {
            var object = cloudKitJSON.wrappedValue
            object[keyPath: keyPath] = newValue
            cloudKitJSON.wrappedValue = object
        }
    }

    /// Read-only access
    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        return cloudKitJSON.wrappedValue[keyPath: keyPath]
    }
}

// MARK: - Convenience Property Access Extensions for SwiftData Models

/// Extension to provide property wrapper-like access for SwiftData models
extension CloudKitJSON where T: AnyObject {

    /// Read-only property access for reference types
    /// - Parameter keyPath: Key path to the desired property
    /// - Returns: The value of the property
    public func access<U>(_ keyPath: KeyPath<T, U>) -> U {
        return wrappedValue[keyPath: keyPath]
    }
}

// MARK: - Convenience Methods

extension CloudKitJSON {

    /// Get the JSON string representation
    public var jsonString: String? {
        String(data: data, encoding: .utf8)
    }

    /// Initialize from JSON string
    /// - Parameter jsonString: JSON string to decode
    public init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        self.init(data: data)
    }

    /// Create a new instance with refreshed decoding (always creates fresh decode)
    public func refreshed() -> CloudKitJSON<T> {
        return CloudKitJSON(data: data)
    }
}

// MARK: - SwiftData Integration

/// Type alias for better readability in SwiftData models
public typealias JSONField<T: Codable> = CloudKitJSON<T>
