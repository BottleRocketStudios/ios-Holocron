//
//  FileSystemStorageProvider.swift
//  Holocron-iOS
//
//  Created by Pranjal Satija on 4/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

public extension StorageProvider {
    typealias FileSystem = FileSystemStorageProvider
}

public struct FileSystemStorageProvider {
    let baseURL: URL
    let readTransformer: Transformer
    let writeTransformer: Transformer
    
    init(baseURL: URL, readTransformer: @escaping Transformer = { $0 }, writeTransformer: @escaping Transformer = { $0 }) {
        self.baseURL = baseURL
        self.readTransformer = readTransformer
        self.writeTransformer = writeTransformer
    }
    
    func url(for key: String) -> URL {
        return baseURL.appendingPathComponent(key)
    }
    
    typealias Transformer = (Data) -> Data
}

// MARK: Public API
extension FileSystemStorageProvider {
    /// Writes a value for a specific key.
    /// - parameter value: The value to store.
    /// - parameter key: The key to associate with `value`.
    /// - parameter options: The options to use when writing the file.
    public func write<T: Encodable>(_ value: T, for key: String, options: Data.WritingOptions) throws {
        try writeTransformer(defaultEncoded(value)).write(to: url(for: key), options: options)
    }
}

// MARK: StorageProvider
extension FileSystemStorageProvider: StorageProvider {
    public func deleteValue(for key: String) throws {
        try FileManager.default.removeItem(at: url(for: key))
    }
    
    public func value<T: Decodable>(for key: String) throws -> T? {
        guard let data = FileManager.default.contents(atPath: url(for: key).path) else {
            return nil
        }
        
        return try defaultDecoded(readTransformer(data))
    }
    
    public func write<T: Encodable>(_ value: T, for key: String) throws {
        try write(value, for: key, options: [])
    }
}
