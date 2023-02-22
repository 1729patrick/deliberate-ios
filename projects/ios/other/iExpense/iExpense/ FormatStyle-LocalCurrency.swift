//
//  FormatStyle-LocalCurrency.swift
//  iExpense
//
//  Created by Patrick Battisti Forsthofer on 15/01/22.
//

import Foundation

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Currency {
    static var localCurrency: Self {
        .currency(code: Locale.current.currencyCode ?? "USD")
    }
}
