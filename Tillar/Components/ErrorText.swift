//
//  ErrorText.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 25/09/25.
//

import SwiftUI

struct ErrorText: View {
    var text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.circle.fill")
                .imageScale(.small)
            Text(text)
                .font(.footnote)
                
        }
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, -6)
    }
}
