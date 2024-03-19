//
//  PaymentListItemsScreen.swift
//  WorldlineConnectExample
//
//  Created for Worldline Global Collect on 27/06/2022.
//  Copyright © 2022 Worldline Global Collect. All rights reserved.
//

import WorldlineConnectKit
import SwiftUI

struct PaymentItemListScreen: View {

    // MARK: - State
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: ViewModel

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
                ScrollView {
                    if viewModel.hasAccountsOnFile && !viewModel.accountsOnFile.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Previously used accounts")
                                .padding(.leading, 10)
                            accountsOnFileList
                            Text("Other payment products")
                                .padding(.leading, 10)
                            paymentItemsList
                        }
                    } else {
                        paymentItemsList
                    }
                }
                .padding(.top, 15)

                NavigationLink("", isActive: $viewModel.showCardProductScreen) {
                    CardProductScreen(
                        viewModel:
                                .init(
                                    paymentItem: viewModel.selectedPaymentItem,
                                    accountOnFile: viewModel.selectedAccountOnFile
                                )
                    )
                }

                NavigationLink("", isActive: $viewModel.showSuccessScreen) {
                    EndScreen(viewModel: EndScreen.ViewModel(preparedPaymentRequest: viewModel.preparedPaymentRequest))
                }
            }
            .alert(isPresented: $viewModel.showAlert, content: getAlert)
            .bottomSheet(isPresented: $viewModel.showBottomSheet,
                         headerType: .handle,
                         height: UIScreen.main.bounds.size.height * 0.2,
                         content: {
                Text(viewModel.infoText)
                    .padding(.horizontal)
            })
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }.onAppear {
            UITableView.appearance().backgroundColor = UIColor.clear
            UITableView.appearance().separatorStyle = .none
        }
    }

    // MARK: - Views
    private var accountsOnFileList: some View {
        ForEach(viewModel.accountsOnFile, id: \.paymentProductIdentifier) { item in
            PaymentListItemRowView(image: item.logo, text: item.name)
                .onTapGesture(perform: {
                    viewModel.didSelect(item: item, accountOnFile: true)
                })
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
        }
    }

    private var paymentItemsList: some View {
        ForEach(viewModel.paymentProductRows, id: \.paymentProductIdentifier) { item in
            PaymentListItemRowView(image: item.logo, text: item.name)
                .onTapGesture(perform: {
                    viewModel.didSelect(item: item, accountOnFile: false)
                })
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
        }
    }

    // MARK: - Functions
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
    PaymentItemListScreen(viewModel: PaymentItemListScreen.ViewModel(paymentItems: nil))
}
