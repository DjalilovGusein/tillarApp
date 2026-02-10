//
//  RequirmentsCard.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 25/09/25.
//

import SwiftUI

struct RequirementsCard: View {
    struct Row: Identifiable { let id = UUID(); let text: String; let ok: Bool }
    var rows: [Row]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                Text("passwordReq".localized())
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(rows) { row in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: row.ok ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(row.ok ? .green : .secondary)
                        Text(row.text)
                            .font(.footnote)
                            .foregroundStyle(.primary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)  
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
