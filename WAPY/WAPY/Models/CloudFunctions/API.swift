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
public typealias CreateStoreResponse = (String?, Error?) -> Void
public typealias GetProductsResponse = ([Product], Error?) -> Void
public typealias CreateProductResponse = (String?, Error?) -> Void
public typealias GetCamerasResponse = ([Camera], Error?) -> Void
public typealias GetCameraResponse = (Camera?, Error?) -> Void
public typealias UpdateCameraResponse = (Bool, Error?) -> Void
public typealias UploadResponse = (URL?, Error?) -> Void

open class API {
    public static let shared = API()

    fileprivate lazy var functions = Functions.functions()
    fileprivate init(){}


    // MARK: - ACCOUNT

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

    // MARK: - CAMERAS

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

        if let heatMapItems = heatMapItems {
            var heatMapData = [[String:Any]]()
            for item in heatMapItems {
                guard let item = item.dictionary else { continue }
                heatMapData.append(item)
            }
            data["heatmap"] = heatMapData
        }

        if let imageUrl = imageUrl {
            data["image"] = imageUrl
        }
        
        functions.httpsCallable("createCamera").call(data) { (result, error) in
            let id = result?.value["generatedId"] as? String
            response(id,error)
        }
    }


    open func updateCamera(cameraId: String,
                           name: String?,
                           storeId: String?,
                           version: String,
                           mmo: MapModelObject?,
                           heatMapItems: [HeatMapItem]?,
                           imageUrl: String?,
                           response: @escaping UpdateCameraResponse) {
        var data = [String: Any]()
        data["cameraId"] = cameraId
        if let storeId = storeId { data["storeId"] = storeId }
        data["version"] = version
        data["name"] = name

        if let mmoDict = mmo?.dictionary {
            data["mmo"] = mmoDict
        }

        if let heatMapItems = heatMapItems {
            var heatMapData = [[String:Any]]()
            for item in heatMapItems {
                guard let item = item.dictionary else { continue }
                heatMapData.append(item)
            }
            data["heatmap"] = heatMapData
        }

        if let imageUrl = imageUrl {
            data["image"] = imageUrl
        }

        functions.httpsCallable("updateCamera").call(data) { (result, error) in


            if let error = error {
                response(false, error)
                return
            }

            let statusCode = result?.value["status"] as? Int ?? 0
            if statusCode != 200 {
                print(result?.value["message"] ?? "Unknown error")
            }
            response(statusCode == 200 ,nil)
        }
    }

    open func getCamera(id: String,response: @escaping GetCameraResponse) {
        functions.httpsCallable("getCamera").call(["cameraId" : id]) { (result, error) in
            guard let jsonStr = (result?.value["data"] as? [String: Any])?.jsonStringRepresentation else {
                response(nil,error)
                return
            }
            print(jsonStr)
            let camera = try? JSONDecoder().decode(Camera.self, from: jsonStr.data(using: .utf8)!)
            response(camera,error)
        }
    }

    open func getCameras(withStoreId storeId: String,response: @escaping GetCamerasResponse) {
        functions.httpsCallable("getCameras").call(["storeId" : storeId]) { (result, error) in

            guard let jsonStr = (result?.value["data"] as? [Any])?.jsonStringRepresentation else {
                response([],nil)
                return
            }
            let cameras = (try? JSONDecoder().decode([Camera].self, from: jsonStr.data(using: .utf8)!)) ??  []
            response(cameras,error)
        }
    }

    // MARK: - STORES

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

    open func createStore(name:String, image:String, address: String?, response: @escaping CreateStoreResponse) {
        var data = [String: Any]()
        data["name"] = name
        data["image"] = image
        if let address = address { data["address"] = address }

        functions.httpsCallable("createStore").call(data) { (result, error) in
            if let error = error {
                response(nil,error)
                return
            }
            response(result?.value["generatedId"] as? String, nil)
        }
    }

    // MARK: - PRODUCTS

    open func createProduct(name:String, image:String, description: String?, response: @escaping CreateProductResponse) {
        var data = [String: Any]()
        data["name"] = name
        data["image"] = image
        if let description = description { data["description"] = description }

        functions.httpsCallable("createProduct").call(data) { (result, error) in
            if let error = error {
                response(nil,error)
                return
            }
            response(result?.value["generatedId"] as? String, nil)
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

    // MARK: - UPLOAD

    open func upload(image: UIImage, withCompressionRate rate: CGFloat = 0.5,response: @escaping UploadResponse) {
        guard let data = image.jpegData(compressionQuality: rate) else { return }
        upload(file: data, withExtension: "jpeg", response: response)
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
