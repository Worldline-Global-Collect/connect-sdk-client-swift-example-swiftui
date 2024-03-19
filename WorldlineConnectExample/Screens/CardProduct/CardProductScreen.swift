//
//  CardProductScreen.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import SwiftUI

struct CardProductScreen: View {

    private enum Constants {
        static let borderColor = Color(UIColor.gray)
        static let accentColor = Color(UIColor.darkGray)
        static let inactiveColor = Color(white: 0.8, opacity: 1.0)
    }

    // MARK: - State
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: ViewModel

    @State private var showBottomSheet: Bool = false

    // MARK: - Body
    var body: some View {
        LoadingView(isShowing: $viewModel.isLoading) {
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.top)
                .padding(.leading)
                HeaderView()
                    .padding(.bottom, 30)

                ScrollView {
                    VStack(spacing: 20) {
                        ProductTextFieldView(leadingImage: Image(systemName: "creditcard"),
                                             trailingImage:
                                                .image(
                                                    Image(
                                                        uiImage: viewModel.paymentItem?.displayHints.logoImage ??
                                                                 UIImage()
                                                    )
                                             ),
                                             placeholder:
                                                viewModel.placeholder(forField: viewModel.creditCardField) ?? "",
                                             text: viewModel.creditCardFieldEnabled ?
                                                 Binding<String>(
                                                    get: {
                                                        viewModel.maskedValue(forField: viewModel.creditCardField)
                                                    },
                                                    set: {
                                                        viewModel.setValue(
                                                            value: $0,
                                                            forField: viewModel.creditCardField
                                                        )
                                                        viewModel.didChangeCreditCardField()
                                                    }
                                                 ) :
                                             .constant(viewModel.accountOnFile?.label ?? ""),
                                             accentColor:
                                                viewModel.creditCardFieldEnabled ?
                                                Constants.accentColor :
                                                Constants.inactiveColor,
                                             borderColor:
                                                viewModel.creditCardFieldEnabled ?
                                                Constants.borderColor :
                                                Constants.inactiveColor,
                                             errorText: viewModel.creditCardError ?? nil,
                                             onEditingChanged: { _ in },
                                             onCommit: { }
                        )
                        .disabled(!viewModel.creditCardFieldEnabled)

                        HStack(alignment: .top) {
                            ProductTextFieldView(leadingImage: Image(systemName: "calendar"),
                                                 trailingImage: .none,
                                                 placeholder:
                                                    viewModel.placeholder(forField: viewModel.expiryDateField) ?? "",
                                                 text: Binding<String>(
                                                    get: {
                                                        viewModel.maskedValue(forField: viewModel.expiryDateField)
                                                    },
                                                    set: {
                                                        viewModel.setValue(
                                                            value: $0,
                                                            forField: viewModel.expiryDateField
                                                        )
                                                        viewModel.didChangeExpiryDateField()
                                                    }
                                                 ),
                                                 accentColor:
                                                    viewModel.creditCardFieldEnabled ?
                                                    Constants.accentColor :
                                                    Constants.inactiveColor,
                                                 borderColor:
                                                    viewModel.creditCardFieldEnabled ?
                                                    Constants.borderColor :
                                                    Constants.inactiveColor,
                                                 errorText: viewModel.expiryDateError,
                                                 onEditingChanged: { _ in },
                                                 onCommit: {}
                            )
                            .disabled(!viewModel.expiryDateFieldEnabled)

                            ProductTextFieldView(leadingImage: Image(systemName: "lock"),
                                                 placeholder: viewModel.placeholder(forField: viewModel.cvvField) ?? "",
                                                 text: Binding<String>(
                                                    get: { viewModel.maskedValue(forField: viewModel.cvvField) },
                                                    set: { viewModel.setValue(value: $0, forField: viewModel.cvvField)
                                                        viewModel.didChangeCvvField()
                                                    }
                                                 ),
                                                 errorText: viewModel.cvvError,
                                                 onEditingChanged: { _ in },
                                                 onCommit: {},
                                                 buttonCallback: {
                                                    showBottomSheetWithCVVImage()
                                                }
                            )
                        }

                        ProductTextFieldView(leadingImage: Image(systemName: "person.fill"),
                                             trailingImage: .none,
                                             placeholder:
                                                viewModel.placeholder(forField: viewModel.cardHolderField) ?? "",
                                             text: Binding<String>(
                                                get: {
                                                    viewModel.maskedValue(forField: viewModel.cardHolderField)
                                                },
                                                set: {
                                                    viewModel.setValue(value: $0, forField: viewModel.cardHolderField)
                                                    viewModel.didChangeCardHolder()
                                                }
                                             ),
                                             accentColor:
                                                viewModel.creditCardFieldEnabled ?
                                                Constants.accentColor :
                                                Constants.inactiveColor,
                                             borderColor:
                                                viewModel.creditCardFieldEnabled ?
                                                Constants.borderColor :
                                                Constants.inactiveColor,
                                             errorText: viewModel.cardHolderError,
                                             onEditingChanged: { _ in },
                                             onCommit: {}
                        )
                        .disabled(!self.viewModel.cardHolderFieldEnabled)

                        if viewModel.accountOnFile == nil {
                            Toggle(isOn: $viewModel.rememberPaymentDetails) {
                                Text("RememberMyDetails".localized)
                                    .font(.footnote)
                            }
                        }
                        payButton

                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)

                    Spacer()

                    NavigationLink("", isActive: $viewModel.showEndScreen) {
                        EndScreen(
                            viewModel:
                                EndScreen.ViewModel(
                                    preparedPaymentRequest: self.viewModel.preparedPaymentRequest
                                )
                        )
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert, content: getAlert)
            .bottomSheet(isPresented: $showBottomSheet,
                         headerType: .handle,
                         height: UIScreen.main.bounds.size.height * 0.3,
                         content: {
                HStack {
                    Text("CVVTooltip".localized)
                        .padding(.horizontal)
                    Image(uiImage: self.viewModel.cvvField?.displayHints?.tooltip?.image ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)

                }.padding(.horizontal)
            })
        }
    }

    // MARK: - Views
    private var payButton: some View {
        Button(action: {
            viewModel.pay()
        }, label: {
            Text("Pay".localized)
                .fontWeight(.semibold)
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(viewModel.payIsActive ? Color.green : Color(UIColor.lightGray))
                .cornerRadius(5)
        })
        .disabled(!viewModel.payIsActive)
    }

    // MARK: - Functions
    private func showBottomSheetWithCVVImage() {
        self.showBottomSheet = true
    }

    private func getAlert() -> Alert {
        return Alert(
            title: Text("Something went wrong"),
            message: Text(viewModel.errorMessage ?? ""),
            dismissButton: .default(Text("OK"))
        )
    }
}

// MARK: - Previews
#Preview {
    CardProductScreen(
        viewModel:
            CardProductScreen.ViewModel(
                paymentItem: nil,
                accountOnFile: nil
            )
    )
}
