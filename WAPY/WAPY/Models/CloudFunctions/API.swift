//
//  API.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 25/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation
import FirebaseFunctions
import FirebaseAuth

public typealias GenerateTokenResponse = (String?, Error?) -> Void
public typealias UpdateAccountResponse = (Bool, Error?) -> Void

open class API {
    public static let shared = API()

    fileprivate lazy var functions = Functions.functions()
    fileprivate init(){}



    /// Used to generate a sign in token.
    ///
    /// - Parameter response: Completion block.
    open func generateToken(response: @escaping GenerateTokenResponse) {
        functions.httpsCallable("generateToken").call { (result, error) in
            guard let result = result else {
                response(nil,error)
                return
            }

            let token = result.value["token"] as? String
            response(token,nil)
        }
    }

    open func updateAccount(data: [String: Any], response: @escaping UpdateAccountResponse) {
        functions.httpsCallable("updateAccount").call { (result, error) in
            guard result != nil else {
                response(false,error)
                return
            }

            response(true,nil)
        }
    }
}

extension HTTPSCallableResult {
    var value: [String: Any] {
        return data as? [String: Any] ?? [:]
    }
}
