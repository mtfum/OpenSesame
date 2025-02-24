//
//  LockView.swift
//  LockView
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI
import KeychainAccess
import CloudKit

struct LockView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Variables
    @Binding var isLocked: Bool
    let onSuccessfulUnlock: () -> Void
    
    
    @State var password: String = ""
    @State var attempts: Int = 0
    
    @State var canAuthenticateWithBiometrics: Bool = true
    @State var biometricsFailed: Bool = false
    
    @State var encryptionTestDoesntExist = false
    @State var encryptionTest: (test: String, tag: String, nonce: String?)? = nil
    
    @State var isAuthenticating: Bool = false
    
    
    // MARK: - Variable Types
    public enum UnlockMethod {
        case biometrics
        case password
    }
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image("Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .animation(.default, value: isLocked)
            textField
            .blur(radius: isAuthenticating ? 2.5 : 0)
            Spacer()
        }
        .padding()
#if os(macOS)
        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
#endif
        .allowsHitTesting(!isAuthenticating)
        .animation(.default, value: isAuthenticating)
        .padding()
        .navigationTitle("OpenSesame")
        
        // MARK: - Master Password Creation
        .sheet(isPresented: $encryptionTestDoesntExist) {
            CreatePasswordView(completionAction: createMasterPassword)
        }
        .onAppear {
            loadEncryptionTest()
        }
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView(isLocked: .constant(true)) {
            
        }
    }
}
