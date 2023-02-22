//
//  String-EmptyChecking.swift
//  CupcakeCorner
//
//  Created by Patrick Battisti Forsthofer on 29/01/22.
//

import SwiftUI

extension String {
    var isReallyEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
