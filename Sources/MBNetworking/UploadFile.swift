//
//  UploadFile.swift
//  Networking
//
//  Created by Rashid Ramazanov on 12.01.2021.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation

/// Multipart body file
public struct File {
    
    /// File name
    public var name: String
    /// Mime type
    public var mimeType: String
    /// Data
    public var data: Data
    
    /// Initialize multipart File
    /// - Parameters:
    ///   - name: File name
    ///   - mimeType: Mime type
    ///   - data: Data
    public init(name: String, mimeType: String, data: Data) {
        self.name = name
        self.mimeType = mimeType
        self.data = data
    }
    
}
