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
    
    var body: some View {
        HStack {
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
                
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(Color.separatorPrimary)
                }
                .padding(.trailing, 8)
                
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(contentType)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(Color.primaryText)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
