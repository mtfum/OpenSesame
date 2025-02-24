//
//  NewAccountView.swift
//  NewAccountView
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI
import AuthenticationServices
import KeychainAccess

struct NewAccountView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    // MARK: - CoreData
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var vaults: FetchedResults<Vault>
    
    // MARK: - Variables
    @State private var website: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State var vault: Int = 0
    
    // MARK: - View
    var body: some View {
        VStack {
            Text("New Account")
                .font(.title.bold())
                .frame(maxWidth: .infinity)
                .padding([.top, .horizontal])
            GroupBox {
                VStack(spacing: 10) {
                    VStack(alignment: .leading) {
                        Label("Website", systemImage: "globe")
                            .foregroundColor(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Website", text: $website)
                            .textFieldStyle(.roundedBorder)
#if os(iOS)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.none)
#endif
                            .disableAutocorrection(true)
                    }
                    VStack(alignment: .leading) {
                        Label("Email or Username", systemImage: "person.fill")
                            .foregroundColor(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Email or Username", text: $username)
                            .textFieldStyle(.roundedBorder)
#if os(iOS)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
#endif
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading) {
                        Label("Password", systemImage: "key.fill")
                            .foregroundColor(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            TextField("Password", text: $password)
                                .textFieldStyle(.roundedBorder)
#if os(iOS)
                                .autocapitalization(.none)
#endif
                                .disableAutocorrection(true)
#if os(iOS)
                            Button {
                                password = Keychain.generatePassword()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .imageScale(.large)
                            }
#endif
                        }
                    }
                }
#if os(macOS)
                .padding(5)
#endif
            }
            .padding()
            Picker("Vault", selection: $vault) {
                ForEach(0..<vaults.count) { i in
                    Text(vaults[i].name!)
                        .tag(i)
                }
            }
            .padding(.horizontal)
            Spacer()
            GroupBox {
                HStack {
                    Button("Cancel") {
                        dismiss.callAsFunction()
                    }.keyboardShortcut(.cancelAction)
                    Spacer()
                    Button("Add", action: add)
                        .keyboardShortcut(.defaultAction)
                }.padding(5)
            }
        }
#if os(macOS)
        .frame(width: 300, height: 400)
#endif
    }
    
    private func add() {
        do {
            let encryptedPassword = try CryptoSecurityService.encrypt(password)
            print("Encrypted password")
            
            let newAccount = Account(context: viewContext)
            newAccount.dateAdded = Date()
            
            newAccount.passwordLength = Int16(password.count)
            newAccount.password = encryptedPassword?.value
            newAccount.encryptionTag = encryptedPassword?.tag
            newAccount.nonce = CryptoSecurityService.nonceStr
            
            newAccount.domain = website
            newAccount.username = username
            
            vaults[vault].addToAccounts(newAccount)
            
            try viewContext.save()
            
            ASCredentialIdentityStore.shared.getState { state in
                if state.isEnabled {
                    
                    let domainIdentifer = ASPasswordCredentialIdentity(serviceIdentifier: ASCredentialServiceIdentifier(identifier: website, type: .domain),
                                                                       user: username,
                                                                       recordIdentifier: nil)
                    
                    
                    ASCredentialIdentityStore.shared.saveCredentialIdentities([domainIdentifer], completion: {(_,error) -> Void in
                        print(error?.localizedDescription ?? "No errors in saving credentials")
                    })
                }
            }
            
            dismiss.callAsFunction()
        } catch {
            print(error)
            
#if os(macOS)
            NSAlert(error: error).runModal()
#endif
        }
    }
}

struct NewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NewAccountView()
    }
}
