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
import FirebaseStorage

public typealias GenerateTokenResponse = (String?, Error?) -> Void
public typealias UpdateAccountResponse = (Bool, Error?) -> Void
public typealias CreateCameraResponse = (String?, Error?) -> Void
public typealias GetStoresResponse = ([Store], Error?) -> Void
public typealias GetProductsResponse = ([Product], Error?) -> Void

public typealias UploadResponse = (URL?, Error?) -> Void

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
        functions.httpsCallable("updateAccount").call(data) { (result, error) in
            guard result != nil else {
                response(false,error)
                return
            }

            response(true,nil)
        }
    }

    open func createCamera(name: String?, storeId: String?,
                           version: String, mmo: MapModelObject?,
                           heatMapItems: [HeatMapItem]?,
                           imageUrl: String?,
                           response: @escaping CreateCameraResponse) {

        var data = [String: Any]()

        if let storeId = storeId { data["storeId"] = storeId }
        data["version"] = version
        data["name"] = name

        if let mmoDict = mmo?.dictionary {
            data["mmo"] = mmoDict
        }

        if let heatMapItems = heatMapItems?.dictionary {
            data["heatmap"] = heatMapItems
        }

        if let imageUrl = imageUrl {
            data["image"] = imageUrl
        }
        
        functions.httpsCallable("createCamera").call(data) { (result, error) in
            let id = result?.value["generatedId"] as? String
            response(id,error)
        }
    }


    open func updateCamera() {

    }

    open func getCamera(id: String) {
        functions.httpsCallable("getCamera").call(["cameraId" : id]) { (result, error) in
            //TODO: complete handl
        }
    }

    open func getStores(response: @escaping GetStoresResponse) {
        functions.httpsCallable("getStores").call { (result, error) in
            if let error = error {
                response([],error)
                return
            }
            guard let data = result?.data as? [String : Any] else { response([],nil); return }
            guard let stores = data["data"] as? Array<Dictionary<String,Any>> else { response([],nil); return }

            var resArr = [Store]()
            for store in stores {
                resArr.append(Store(id: store["id"] as? String,
                                    name: store["name"] as? String,
                                    image: store["image"] as? String,
                                    ownerId: store["owner_uid"] as? String))
            }
            response(resArr,nil)
        }
    }

    open func getProducts(response: @escaping GetProductsResponse) {
        functions.httpsCallable("getProducts").call { (result, error) in
            if let error = error {
                response([],error)
                return
            }
            guard let data = result?.data as? [String : Any] else { return }
            guard let stores = data["data"] as? Array<Dictionary<String,Any>> else { return }

            var resArr = [Product]()
            for store in stores {
                let pro = Product(id: store["id"] as? String,
                                  name: store["name"] as? String,
                                  image: store["image"] as? String)
                resArr.append(pro)
            }
            response(resArr,nil)
        }
    }

    open func upload(image: UIImage, response: @escaping UploadResponse) {
        guard let data = image.pngData() else { return }
        upload(file: data, withExtension: "png", response: response)
    }

    open func upload(file: Data, withExtension fileExt: String, response: @escaping UploadResponse) {
        let storage = Storage.storage()
        guard let user = Auth.auth().currentUser else { return }

        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(user.uid)/\(UUID().uuidString).\(fileExt)")

        fileRef.putData(file, metadata: nil) { (metadata, error) in
            fileRef.downloadURL { (url, err) in
                response(url,err)
            }
        }
    }
    
}

extension HTTPSCallableResult {
    var value: [String: Any] {
        return data as? [String: Any] ?? [:]
    }
}
