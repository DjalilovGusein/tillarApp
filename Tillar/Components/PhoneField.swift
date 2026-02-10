//
//  PhoneField.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 25/09/25.
//

import SwiftUI

struct PhoneField: View {
    let prefix: String = "+998"
    @Binding var number: String
    let placeholder: String = "12 345 67 89"

    @State private var display: String = ""

    init(number: Binding<String>) {
        self._number = number
        self._display = State(initialValue: PhoneField.formatted(number.wrappedValue))
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(prefix)
                .font(.system(size: 17))
                .foregroundStyle(.primary)

            Rectangle()
                .fill(Color.separatorPrimary)
                .frame(width: 1, height: 20)

            TextField(placeholder, text: $display)
                .keyboardType(.numberPad)
                .textContentType(.telephoneNumber)
                .foregroundStyle(Color.primary)
                .font(.system(size: 17))
                .onChange(of: display) { new in
                    let digits = PhoneField.digitsOnly(new)
                    if number != digits { number = digits }
                    let masked = PhoneField.formatted(digits)
                    if masked != new { display = masked }
                }
                .onChange(of: number) { new in
                    let masked = PhoneField.formatted(new)
                    if display != masked { display = masked }
                }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Helpers
private extension PhoneField {
    static func digitsOnly(_ string: String) -> String {
        let filtered = string.filter(\.isNumber)
        return String(filtered.prefix(9))
    }

    static func formatted(_ string: String) -> String {
        let d = digitsOnly(string)
        var res = ""
        let pattern = [2, 3, 2, 2]
        var i = d.startIndex

        for size in pattern {
            guard i < d.endIndex else { break }
            let end = d.index(i, offsetBy: size, limitedBy: d.endIndex) ?? d.endIndex
            let part = d[i..<end]
            if !res.isEmpty { res.append(" ") }
            res.append(contentsOf: part)
            i = end
        }
        return res
    }
}
