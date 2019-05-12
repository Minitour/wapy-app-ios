//
//  CalibrationService.swift
//  bluetooth-test
//
//  Created by Antonio Zaitoun on 25/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import CoreBluetooth
import Foundation

enum WapyError: Error {
    case notDiscovered
    case bluetoothNotAvailable
}

enum WapyCharacteristic: String {
    case info = "d60bc3bc20694eb78c69e2ba01b03553"
    case wifi = "307fd0967cd34a159fa05cfdbca97342"
    case token = "a33c9d54e26e42e8ad99b58293e4249a"
    case ssid = "62221e9cfea145de865c8d718dd6a98f"
    case cameraId = "3367142e91d445128ac6e64bb57ae9c8"
    case read = "0aadbf253f94452d82c9ce3f045ee51f"
    case write = "805b0d5b00d9427c84517441c22b46ca"
    case unknown = ""
}

extension CBCharacteristic {
    var wapyCharacteristic: WapyCharacteristic {
        return WapyCharacteristic(rawValue: uuid.uuidString.lowercased().replacingOccurrences(of: "-", with: "")) ?? .unknown
    }
}

extension CBPeripheral {
    func write(_ value: String, to characteristic: CBCharacteristic?, type: CBCharacteristicWriteType = .withResponse) {
        guard let characteristic = characteristic else { return }
        self.writeValue(value.data(using: .utf8)!, for: characteristic, type: type)
    }

    func read(from characteristic: CBCharacteristic?) {
        guard let characteristic = characteristic else { return }
        self.readValue(for: characteristic)
    }
}

public typealias CalibrationServiceAction = (CalibrationService) -> Void

/**
 # How to add a new characteristic:

 1) Add to the enum with valid UUID.
 2) Add a reference in Characteristics section.
 3) Add in didDiscoverCharacteristicsFor.

 ## If READ characteristic:
 1) Add a variable which stores the data and add observers to it. (I.E: wifiData)
 2) Add an open function which makes the initial read call. (I.E getBoxInfo)
 3) implement reading logic at `didUpdateValueFor`.

 ## If WRITE characteristic:
 For write all you simply have to do is add a wraping function which receives the value and call:
 ```swift
 wapyPeripheral.write(_, to:)
 ```
 */
open class CalibrationService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    public static let shared = CalibrationService()

    // MARK:-  field properties

    /// The central bluetooth manager.
    fileprivate var centralManager: CBCentralManager!

    /// The wapy peripheral.
    fileprivate var wapyPeripheral: CBPeripheral!

    fileprivate var maxLength: Int?

    // MARK:- Characteristics

    /// The info characteristic provides data about the box.
    fileprivate var info: CBCharacteristic!

    /// The wifi characteristic provides data about available networks.
    fileprivate var wifi: CBCharacteristic!

    /// The token characteristic is a write only characteristic which we use to provide the box with an auth token.
    fileprivate var token: CBCharacteristic!

    /// The ssid is a write characteristic with which we provided the box the WiFi credentials.
    fileprivate var ssid: CBCharacteristic!

    /// used to update the calibartion service with the id that firebase provided.
    fileprivate var cameraId: CBCharacteristic!

    /// The read characteristic is a write only with which we update the current read offset when reading large amounts of data.
    fileprivate var read: CBCharacteristic!

    /// unused - remove
    fileprivate var write: CBCharacteristic!

    /// The current characteristic we are reading from or writing to.
    fileprivate var activeCharacteristic: CBCharacteristic?

    open fileprivate(set) var isBluetoothAvailable: Bool = false {
        didSet{
            if isBluetoothAvailable {
                onBluetoothAvailable?(self)
            }
        }
    }

    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - handlers

    fileprivate var completion: ((String)-> Void)?

    fileprivate var writeCompletion: CalibrationServiceAction?

    /// called when bluetooth is available.
    open var onBluetoothAvailable: CalibrationServiceAction?

    /// called when peripheral is discovered in range.
    open var didDiscover: CalibrationServiceAction?

    /// called after peripheral has been connected.
    open var didConnect: CalibrationServiceAction?

    // MARK: - data collected

    open fileprivate(set) var wifiData: String = "" {
        didSet {
            guard isValidJson(wifiData) else { return }
            completion?(wifiData)
            completion = nil
        }
    }

    open fileprivate(set) var infoData: String = "" {
        didSet {
            guard isValidJson(infoData) else { return }
            completion?(infoData)
            completion = nil
        }
    }

    // MARK: - Actions

    open func getBoxInfo(completion: ((String)-> Void)?=nil) {
        self.completion = completion

        infoData = ""

        // the the active char to wifi.
        activeCharacteristic = info

        // this will set the global read offset to 0
        // Then it will invoke didWriteValueFor, which will invoke a read request on the wifi characterisitc.
        // It will then enter a loop which keeps making a read request and a write request
        updateReadOffset(0)
    }

    open func getAvailableWifi(completion: ((String)-> Void)?=nil) {
        self.completion = completion

        wifiData = ""

        // the the active char to wifi.
        activeCharacteristic = wifi

        // this will set the global read offset to 0
        // Then it will invoke didWriteValueFor, which will invoke a read request on the wifi characterisitc.
        // It will then enter a loop which keeps making a read request and a write request
        updateReadOffset(0)
    }

    open func updateCameraId(_ id: String, completion: CalibrationServiceAction? = nil) {
        writeCompletion = completion
        activeCharacteristic = cameraId

        let str = "{\"camera_id\":\"\(id)\"}"
        wapyPeripheral.write(str, to: cameraId)
    }

    open func updateToken(_ tokenValue: String, completion: CalibrationServiceAction? = nil){
        writeCompletion = completion
        activeCharacteristic = token

        let str = "{\"token\":\"\(tokenValue)\"}"
        wapyPeripheral.write(str, to: token)
    }

    open func updateNetwork(bssid: String, password: String?, completion: CalibrationServiceAction? = nil) {
        writeCompletion = completion
        activeCharacteristic = ssid
        let passwordValue = password == nil ? "null" : "\"\(password!)\""
        let str = "{\"bssid\":\"\(bssid)\",\"password\":\(passwordValue)}"
        wapyPeripheral.write(str, to: ssid)
    }

    /// Call to scan for peripherals
    open func scan() throws {
        guard isBluetoothAvailable else { throw WapyError.bluetoothNotAvailable }
        if centralManager.isScanning { return }
        centralManager.scanForPeripherals(withServices: nil)
    }

    /// Call to connect to peripheral.
    open func connect() throws {
        guard wapyPeripheral != nil else { throw WapyError.notDiscovered }
        centralManager.connect(wapyPeripheral)
    }

    /// Call to end connection.
    open func disconnect() {
        centralManager.cancelPeripheralConnection(wapyPeripheral)
    }

    // MARK: - Internal Actions

    /// Updates the reading offset
    ///
    /// - Parameter offset: The new offset to set.
    fileprivate func updateReadOffset(_ offset: Int) {
        self.wapyPeripheral.write("{\"offset\":\(offset)}", to: read)
    }


    /// Updates the writing offset.
    ///
    /// - Parameter offset: The new offset to set.
    fileprivate func updateWriteOffset(_ offset: Int) {
        self.wapyPeripheral.write("{\"offset\":\(offset)}", to: write)
    }

    // MARK:- Central Manager Delegate

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.identifier.uuidString == "B8E4A73D-947D-BF41-4CAC-98C71BFC1FB5" {
            peripheral.delegate = self
            self.wapyPeripheral = peripheral
            central.stopScan()
            didDiscover?(self)
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        maxLength = peripheral.maximumWriteValueLength(for: .withResponse)
        didConnect?(self)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect")
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothAvailable = true
        default:
            isBluetoothAvailable = false
            break
        }
    }

    // MARK:- Peripheral Delegate

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }

        switch characteristic.wapyCharacteristic {
        case .wifi:
            if data.count > 0, let str = String(data: data, encoding: .utf8) {
                // success
                wifiData += str

                // update offset
                updateReadOffset(wifiData.data(using: .utf8)!.count)
            }
        case .info:
            if data.count > 0, let str = String(data: data, encoding: .utf8) {
                // success
                infoData += str

                // update offset
                updateReadOffset(infoData.data(using: .utf8)!.count)
            }
        case .unknown:
            break
        default:
            break
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else { print(error!.localizedDescription); return }

        // check if we just wrote data to either the `read` or `write` CBCharacteristic. In that case we need to call for action continuation.
        switch characteristic.wapyCharacteristic {
        case .read:
            // continue reading
            peripheral.read(from: activeCharacteristic)
        default:
            writeCompletion?(self)
            writeCompletion = nil
            break
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            switch characteristic.wapyCharacteristic {
            case .info:
                self.info = characteristic
            case .wifi:
                self.wifi = characteristic
            case .read:
                self.read = characteristic
            case .write:
                self.write = characteristic
            case .unknown:
                print("unknown characteristic \(characteristic.uuid)")
            case .token:
                self.token = characteristic
            case .ssid:
                self.ssid = characteristic
            case .cameraId:
                self.cameraId = characteristic
            }
        }
    }

    func isValidJson(_ json: String) -> Bool {
        do {
            let _ = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: [])
        } catch {
            return false
        }
        return true
    }
}
