//
//  String-EmptyChecking.swift
//  Bookworm
//
//  Created by Patrick Battisti Forsthofer on 02/02/22.
//

import Foundation

extension String {
    var isReallyEmpty: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
