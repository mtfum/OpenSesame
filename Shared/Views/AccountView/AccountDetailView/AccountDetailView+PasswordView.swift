//
//  AccountDetailsView+PasswordView.swift
//  AccountDetailsView+PasswordView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension AccountView.AccountDetailsView {
    var passwordView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Label("Password", systemImage: "key.fill")
                    .foregroundColor(Color.secondary)
                if isEditing {
                    TextField("Password", text: $newPassword)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(displayedPassword)
                        .font(.system(.headline, design: .monospaced))
                        .blur(radius: isShowingPassword ? 0 : 8)
                        .animation(.default, value: isShowingPassword)
                        .onTapGesture {
                            if !isShowingPassword {
                                do {
                                    decryptedPassword = try CryptoSecurityService.decrypt(account.password!, tag: account.encryptionTag!, nonce: account.nonce)
                                    
                                    displayedPassword = decryptedPassword ?? displayedPassword
                                    isShowingPassword = true
                                } catch {
                                    print(error)
                                    
#if os(macOS)
                                    NSAlert(error: error).runModal()
#endif
                                }
                            } else {
                                isShowingPassword.toggle()
                                decryptedPassword = nil
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    displayedPassword = CryptoSecurityService.randomString(length: Int(account.passwordLength))
                                }
                            }
                        }
                        .onHover { isHovering in
#if os(macOS)
                            if isHovering {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
#endif
                        }
                }
            }
            if !isEditing {
                Spacer()
                Button {
                    guard let decryptedPassword = decryptedPassword else { return }
#if os(macOS)
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(decryptedPassword, forType: .string)
#else
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = decryptedPassword
#endif
                } label: {
                    Image(systemName: "doc.on.doc.fill")
                }
                .opacity(isShowingPassword ? 1 : 0)
                .blur(radius: isShowingPassword ? 0 : 5)
                .animation(.default, value: isShowingPassword)
                .allowsHitTesting(isShowingPassword)
#if os(iOS)
                .hoverEffect()
#endif
            }
        }
    }
}
