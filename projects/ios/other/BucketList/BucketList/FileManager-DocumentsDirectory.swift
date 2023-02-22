//
//  FileManager-DocumentsDirectory.swift
//  BucketList
//
//  Created by Patrick Battisti Forsthofer on 14/02/22.
//

import Foundation


extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
