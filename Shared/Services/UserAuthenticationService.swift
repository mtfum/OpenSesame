//
//  UserAuthenticationService.swift
//  UserAuthenticationService
//
//  Created by Ethan Lipnik on 8/18/21.
//

import Combine
import LocalAuthentication

class UserAuthenticationService: ObservableObject {
    
    #if os(macOS)
    static let BiometricLogin = LAPolicy.deviceOwnerAuthenticationWithBiometricsOrWatch
    #else
    static let BiometricLogin = LAPolicy.deviceOwnerAuthenticationWithBiometrics
    #endif
    
    static var cancellables = Set<AnyCancellable>()
    
    static func authenticate(reason: String = "display your password") -> Future<Bool, Never> {
        return Future { promise in
            print("Requesting authentication")
            let context = LAContext()
            var error: NSError?
            
            func authenticateWithPassword() {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                    if success {
                        promise(.success(success))
                    } else {
                        promise(.success(false))
                    }
                }
            }
            
            // check whether biometric authentication is possible
            if context.canEvaluatePolicy(UserAuthenticationService.BiometricLogin, error: &error) {
                // it's possible, so go ahead and use it
                
                context.evaluatePolicy(UserAuthenticationService.BiometricLogin, localizedReason: reason) { success, authenticationError in
                    // authentication has now completed
                    DispatchQueue.main.async {
                        if success {
                            // authenticated successfully
                            promise(.success(success))
                        } else {
                            authenticateWithPassword()
                        }
                    }
                }
            } else {
                authenticateWithPassword()
            }
        }
    }
}
