//
//  LabeledField.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 24/09/25.
//

import SwiftUI

struct LabeledField: View {
    @Binding var text: String
    let placeholder: String
    let contentType: UITextContentType
    let keyboardType: UIKeyboardType
    let isSecure: Bool

    @State private var isPasswordVisible: Bool = false

    private var isPhoneField: Bool {
        keyboardType == .phonePad
    }

    var body: some View {
        HStack(spacing: 0) {
            if isSecure {
                Group {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                            .textContentType(contentType)
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField(placeholder, text: $text)
                            .textContentType(contentType)
                            .keyboardType(keyboardType)
                    }
                }
                .foregroundStyle(Color.primaryText)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(Color.separatorPrimary)
                }
                .padding(.trailing, 8)

            } else {
                if isPhoneField {
                    Text("+998 ")
                        .foregroundStyle(Color.primaryText)
                }

                TextField(placeholder, text: $text)
                    .textContentType(contentType)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(Color.primaryText)
                    .onChange(of: text) { newValue in
                        if isPhoneField {
                            text = formatPhone(newValue)
                        }
                    }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatPhone(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        let limited = String(digits.prefix(9))

        var result = ""

        for (index, char) in limited.enumerated() {
            switch index {
            case 0...1:
                result.append(char)
            case 2:
                result.append(" ")
                result.append(char)
            case 3...4:
                result.append(char)
            case 5:
                result.append(" ")
                result.append(char)
            case 6:
                result.append(char)
            case 7:
                result.append(" ")
                result.append(char)
            case 8:
                result.append(char)
            default:
                break
            }
        }

        return result
    }
}
