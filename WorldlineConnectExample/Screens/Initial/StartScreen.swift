//
//  InitialScreen.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import SwiftUI

struct StartScreen: View {

    // MARK: - State
    @ObservedObject var viewModel: ViewModel

    @State private var showBottomSheet: Bool = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            LoadingView(isShowing: $viewModel.isLoading) {
                VStack(spacing: 20) {
                    HeaderView()
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 30) {
                            clientSectionDetailsView
                            paymentDetailsView
                            otherOptionsView
                            proceedButtonView
                        }
                        .padding()
                    }
                    NavigationLink("", isActive: $viewModel.showPaymentList) {
                        PaymentItemListScreen(
                            viewModel:
                                PaymentItemListScreen.ViewModel(
                                    paymentItems: viewModel.paymentItems
                                )
                        )
                    }
                }
                .alert(isPresented: $viewModel.showAlert, content: getAlert)
                .bottomSheet(isPresented: $showBottomSheet,
                             headerType: .handle,
                             height: UIScreen.main.bounds.size.height * 0.2,
                             content: {
                    Text(viewModel.infoText)
                        .padding(.horizontal)
                })
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            }.edgesIgnoringSafeArea(.bottom)
        }
    }

    // MARK: - Views
    private var clientSectionDetailsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("ClientSessionDetails".localized)
                .font(.headline)
            TextFieldView(
                placeholder: "ClientSessionIdentifier".localized,
                text: $viewModel.clientSessionId,
                errorText: viewModel.clientSessionIdError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "ClientSessionIdentifierHint".localized)
                }
            )
            TextFieldView(
                placeholder: "CustomerIdentifier".localized,
                text: $viewModel.customerID,
                errorText: viewModel.customerIDError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "CustomerIdentifierHint".localized)
                }
            )
            TextFieldView(
                placeholder: "ClientIdentifier".localized,
                text: $viewModel.clientApiUrl,
                errorText: viewModel.clientApiUrlError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "ClientIdentifierHint".localized)
                }
            )
            TextFieldView(
                placeholder: "AssetsURL".localized,
                text: $viewModel.assetsUrl,
                errorText: viewModel.assetsUrlError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "AssetsURLHint".localized)
                }
            )
            HStack {
                Spacer()
                Button(action: {
                    viewModel.pasteFromJson()
                }, label: {
                    Text("Paste".localized)
                        .foregroundColor(.green)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.green, lineWidth: 2)
                        )
                })
            }
        }
    }

    private var paymentDetailsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("PaymentDetails".localized)
                .font(.headline)
            TextFieldView(
                placeholder: "AmountInCents".localized,
                text: $viewModel.amount,
                errorText: viewModel.amountError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "AmountInCentsHint".localized)
                }
            )
            TextFieldView(
                placeholder: "CountryCode".localized,
                text: $viewModel.countryCode,
                errorText: viewModel.countryCodeError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "CountryCodeHint".localized)
                }
            )
            TextFieldView(
                placeholder: "CurrencyCode".localized,
                text: $viewModel.currencyCode,
                errorText: viewModel.currencyCodeError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "CurrencyCodeHint".localized)
                }
            )
        }
    }

    private var otherOptionsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("OtherOptions".localized)
                .font(.headline)

            Toggle(isOn: $viewModel.recurringPayment) {
                HStack {
                    Text("RecurringPayment".localized)
                    InfoButtonView {
                        showBottomSheet(text: "RecurringPaymentHint".localized)
                    }
                }
            }

            Toggle(isOn: $viewModel.groupProducts) {
                HStack {
                    Text("GroupPaymentProducts".localized)
                    InfoButtonView {
                        showBottomSheet(text: "GroupPaymentProductsHint".localized)
                    }
                }
            }

            Toggle(isOn: $viewModel.applePay) {
                Text("Apple Pay")
            }

            if viewModel.applePay {
                TextFieldView(
                    placeholder: "MerchantId".localized,
                    text: $viewModel.merchantId,
                    errorText: viewModel.merchantIdError,
                    isSecureTextEntry: false,
                    isFocused: { _ in },
                    buttonCallback: {
                        showBottomSheet(text: "MerchantIdHint".localized)
                    }
                )
            }
        }
    }

    private var proceedButtonView: some View {
        Button(action: {
            viewModel.proceedToCheckout()
        }, label: {
            Text("Checkout".localized)
                .fontWeight(.semibold)
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(5)
        })
    }

    // MARK: - Functions
    private func showBottomSheet(text: String) {
        viewModel.infoText = text
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
    StartScreen(viewModel: StartScreen.ViewModel())
}
