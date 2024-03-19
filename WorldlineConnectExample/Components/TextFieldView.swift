//
//  TextFieldView.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import SwiftUI

struct TextFieldView: View {

    private enum Constants {
        static let offset: CGFloat = -18
        static let normalTextSize: CGFloat = 16
    }

    // MARK: - Properties
    var placeholder: String
    var errorText: String?
    var isSecureTextEntry: Bool
    var autocorrection: Bool
    var autocapitalization: UITextAutocapitalizationType
    var keyboardType: UIKit.UIKeyboardType
    var isFocused: (Bool) -> Void
    var buttonCallback: (() -> Void)?

    // MARK: - State
    @Binding var text: String
    @State private var isSecureTextOn: Bool = true

    // MARK: - Init
    init(
        placeholder: String = "Placeholder",
        text: Binding<String>,
        errorText: String?,
        isSecureTextEntry: Bool = false,
        isFocused: @escaping (Bool) -> Void,
        autocorrection: Bool = false,
        autocapitalization: UITextAutocapitalizationType = .none,
        keyboardType: UIKit.UIKeyboardType = .default,
        buttonCallback: (() -> Void)? = nil
    ) {
        self._text = text
        self.errorText = errorText
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecureTextEntry
        self.isFocused = isFocused
        self.autocorrection = autocorrection
        self.autocapitalization = autocapitalization
        self.keyboardType = keyboardType
        self.buttonCallback = buttonCallback
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 20) {
                Text(placeholder)
                    .font(text.isEmpty ? .body : .system(size: 8))
                    .foregroundColor(Color(UIColor.darkGray))
                    .offset(y: text.isEmpty ? 0 : Constants.offset)
                    .padding(.leading, 13)
                Spacer()
                if let errorText = errorText {
                    Text(errorText)
                        .font(.system(size: 8))
                        .lineLimit(2)
                        .foregroundColor(.red)
                        .offset(y: Constants.offset)
                        .padding(.trailing, 10)
                }
            }
            HStack {
                if isSecureTextEntry && isSecureTextOn {
                    // a workaround because SecureField below iOS15 versions doesn't
                    // have onEditingChanged available.
                    ZStack {
                        SecureField("", text: $text)
                            .foregroundColor(Color(UIColor.darkGray))
                        TextField("", text: $text, onEditingChanged: self.isFocused)
                            .foregroundColor(.clear)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    .font(.system(size: Constants.normalTextSize, design: .monospaced))
                    .padding(.leading, 13)
                    .frame(maxWidth: .infinity)
                    Image(systemName: isSecureTextEntry && isSecureTextOn ? "eye" : "eye.slash")
                        .padding(.trailing, 20)
                        .onTapGesture {
                            isSecureTextOn.toggle()
                        }
                        .opacity(isSecureTextEntry ? 1 : 0)
                } else {
                    TextField("", text: $text, onEditingChanged: self.isFocused)
                        .font(.body)
                        .disableAutocorrection(!autocorrection)
                        .autocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                        .foregroundColor(Color(UIColor.darkGray))
                        .padding(.leading, 13)
                        .frame(maxWidth: .infinity)
                    InfoButtonView {
                        if let buttonCallback = buttonCallback {
                            buttonCallback()
                        }
                    }
                }

            }
            .frame(height: 20)
        }
        .padding(.vertical, 20)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(errorText == nil ? Color.gray : .red, lineWidth: 2)
        )
    }
}

// MARK: - Previews
#Preview("ExampleText") {
    TextFieldView(
        text: .constant("some example text"),
        errorText: "this is a short error",
        isFocused: { _ in }
    )
    .previewLayout(.sizeThatFits)
}

#Preview("Password") {
    TextFieldView(
        placeholder: "Password",
        text: .constant("some example text"),
        errorText: "",
        isSecureTextEntry: true,
        isFocused: { _ in },
        autocorrection: false,
        autocapitalization: .none,
        keyboardType: .default
    )
    .previewLayout(.sizeThatFits)
}

#Preview("PasswordLongErrorDarkMode") {
    TextFieldView(
        placeholder: "Password",
        text: .constant("some example text"),
        errorText: "this is a very long error this, is a very long error, this is a very long error",
        isSecureTextEntry: true,
        isFocused: { _ in }
    )
    .previewLayout(.sizeThatFits)
    .preferredColorScheme(.dark)
}

#Preview("PasswordDarkMode") {
    TextFieldView(
        placeholder: "Password",
        text: .constant("some example text"),
        errorText: "",
        isSecureTextEntry: true,
        isFocused: { _ in },
        autocorrection: false,
        autocapitalization: .none,
        keyboardType: .default
    )
    .previewLayout(.sizeThatFits)
    .preferredColorScheme(.dark)
}
