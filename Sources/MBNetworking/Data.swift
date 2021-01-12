//
//  Data.swift
//  Networking
//
//  Created by Rashid Ramazanov on 12.01.2021.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation

extension NSMutableData {
    
    func appendString(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        append(data)
    }
    
}
