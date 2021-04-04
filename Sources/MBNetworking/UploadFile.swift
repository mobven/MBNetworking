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
    
    /// Key of multipart form data.
    public var name: String
    /// File name
    public var fileName: String
    /// File extension
    public var fileExtension: String
    /// Mime type
    public var mimeType: String
    /// Data
    public var data: Data

    var fileNameWithExtension: String {
        var fileName = self.fileName
        if !fileExtension.isEmpty {
            fileName.append(".")
            fileName.append(fileExtension)
        }
        return fileName
    }

    /// Initializes multipart file upload with key "image", file name with specifed name without extension.
    @available(*, deprecated, message: "Use initializer with fileName and extension instead.")
    public init(name: String, mimeType: String, data: Data) {
        self.init(name: "image", fileName: name, fileExtension: "", mimeType: mimeType, data: data)
    }

    /// Initialize multipart File
    /// - Parameters:
    ///   - name: Key of multipart form data.
    ///   - fileName: Name of the file.
    ///   - fileExtension: Extension of the file.
    ///   - mimeType: Mime type.
    ///   - data: Data.
    public init(name: String, fileName: String, fileExtension: String, mimeType: String, data: Data) {
        self.name = name
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.mimeType = mimeType
        self.data = data
    }
    
}
