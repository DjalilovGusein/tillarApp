//
//  SignInView.swift
//  Tillar
//
//  Created by Gusein Djalilov on 23/10/25.
//

import SwiftUI

struct SignInView: View {
    
    @State var login: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            LabeledField(text: $login, placeholder: "Login", contentType: .username, keyboardType: .emailAddress, isSecure: false)
                .padding(.horizontal, 16)
            LabeledField(text: $login, placeholder: "Password", contentType: .password, keyboardType: .default, isSecure: true)
                .padding(.horizontal, 16)
        }
    }
}

#Preview {
    SignInView()
}
