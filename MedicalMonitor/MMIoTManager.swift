//
//  MMIoTManager.swift
//  MedicalMonitor
//
//  Created by Weidian on 8/8/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

import UIKit
import AWSIoT

class MMIoTManager: NSObject {
    static let sharedInstance = MMIoTManager();
    var connected = false;
    var iotDataManager: AWSIoTDataManager!;
    var iotData: AWSIoTData!
    var iotManager: AWSIoTManager!;
    var iot: AWSIoT!
    var lblStatus: UILabel!;
    var topic: String! = "alert/emergency";
    
    override init() {
        super.init()
        initIoT()
    }

    func initIoT() {
        // Init IOT
        //
        // Set up Cognito
        //
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AwsRegion, identityPoolId: CognitoIdentityPoolId)
        let iotEndPoint = AWSEndpoint(urlString: IOT_ENDPOINT)
        //configuration for AWSIoT control plane APIs
        let iotConfiguration = AWSServiceConfiguration(region: AwsRegion,
                                                       credentialsProvider: credentialsProvider)
        //configuration for AWSIoT Data plane APIs
        let iotDataConfiguration = AWSServiceConfiguration(region: AwsRegion,
                                                           endpoint: iotEndPoint,
                                                           credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = iotConfiguration
        
        iotManager = AWSIoTManager.default()
        iot = AWSIoT.default()
        
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: "MyIotDataManager")
        iotDataManager = AWSIoTDataManager(forKey: "MyIotDataManager")
        
        AWSIoTData.register(with: iotDataConfiguration!, forKey: "MyIotData")
        iotData = AWSIoTData(forKey: "MyIotData")
    }
    
    func connect() {
        func mqttEventCallback( _ status: AWSIoTMQTTStatus )
        {
            DispatchQueue.main.async {
                print("connection status = \(status.rawValue)")
                switch(status)
                {
                case .connecting:
                    self.lblStatus?.text = "Connecting...";
                    print( "Connecting..." )
                    break;
                case .connected:
                    print( "Connected..." )
                    self.connected = true
                    let uuid = UUID().uuidString;
                    let defaults = UserDefaults.standard
                    let certificateId = defaults.string( forKey: "certificateId")
                    
                    print("Using certificate:\n\(certificateId!)\n\n\nClient ID:\n\(uuid)")
                    self.lblStatus?.text = "Using certificate:\n\(certificateId!)\n\nClient ID:\n\(uuid)";
                    break;
                case .disconnected:
                    print( "Disconnected..." )
                    break;
                case .connectionRefused:
                    print("Connection Refused")
                    break;
                case .connectionError:
                    print("Connection Error")
                    break;
                case .protocolError:
                    print("Protocol Error")
                    break;
                default:
                    print("unknown state: \(status.rawValue)")
                    
                }
                NotificationCenter.default.post( name: Notification.Name(rawValue: "connectionStatusChanged"), object: self )
            }
            
        }
        
        if (connected == false)
        {
//            activityIndicatorView.startAnimating()
            
            let defaults = UserDefaults.standard
            var certificateId = defaults.string( forKey: "certificateId")
            
            if (certificateId == nil)
            {
                DispatchQueue.main.async {
                    print("No identity available, searching bundle...")
                }
                //
                // No certificate ID has been stored in the user defaults; check to see if any .p12 files
                // exist in the bundle.
                //
                let myBundle = Bundle.main
                let myImages = myBundle.paths(forResourcesOfType: "p12" as String, inDirectory:nil)
                let uuid = UUID().uuidString;
                
                if (myImages.count > 0) {
                    //
                    // At least one PKCS12 file exists in the bundle.  Attempt to load the first one
                    // into the keychain (the others are ignored), and set the certificate ID in the
                    // user defaults as the filename.  If the PKCS12 file requires a passphrase,
                    // you'll need to provide that here; this code is written to expect that the
                    // PKCS12 file will not have a passphrase.
                    //
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: myImages[0])) {
                        DispatchQueue.main.async {
                            print("found identity \(myImages[0]), importing...")
                        }
                        if AWSIoTManager.importIdentity( fromPKCS12Data: data, passPhrase:"", certificateId:myImages[0]) {
                            //
                            // Set the certificate ID and ARN values to indicate that we have imported
                            // our identity from the PKCS12 file in the bundle.
                            //
                            defaults.set(myImages[0], forKey:"certificateId")
                            defaults.set("from-bundle", forKey:"certificateArn")
                            DispatchQueue.main.async {
                                print("Using certificate: \(myImages[0]))")
                                self.iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:myImages[0], statusCallback: mqttEventCallback)
                            }
                        }
                    }
                }
                certificateId = defaults.string( forKey: "certificateId")
                if (certificateId == nil) {
                    DispatchQueue.main.async {
                        print("No identity found in bundle, creating one...")
                    }
                    //
                    // Now create and store the certificate ID in NSUserDefaults
                    //
                    let csrDictionary = [ "commonName":CertificateSigningRequestCommonName, "countryName":CertificateSigningRequestCountryName, "organizationName":CertificateSigningRequestOrganizationName, "organizationalUnitName":CertificateSigningRequestOrganizationalUnitName ]
                    
                    self.iotManager.createKeysAndCertificate(fromCsr: csrDictionary, callback: {  (response ) -> Void in
                        if (response != nil)
                        {
                            defaults.set(response?.certificateId, forKey:"certificateId")
                            defaults.set(response?.certificateArn, forKey:"certificateArn")
                            certificateId = response?.certificateId
                            //print("response: [\(response)]")
                            
                            let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest()
                            attachPrincipalPolicyRequest?.policyName = PolicyName
                            attachPrincipalPolicyRequest?.principal = response?.certificateArn
                            //
                            // Attach the policy to the certificate
                            //
                            self.iot.attachPrincipalPolicy(attachPrincipalPolicyRequest!).continueWith (block: { (task) -> AnyObject? in
                                if let error = task.error {
                                    print("failed: [\(error)]")
                                }
                                //print("result: [\(task.result)]")
                                //
                                // Connect to the AWS IoT platform
                                //
                                if (task.error == nil)
                                {
                                    DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                                        print("Using certificate: \(certificateId!)")
                                        self.iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:certificateId!, statusCallback: mqttEventCallback)
                                        
                                    })
                                }
                                return nil
                            })
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                print("Unable to create keys and/or certificate, check values in Constants.swift")
                            }
                        }
                    } )
                }
            }
            else
            {
                let uuid = UUID().uuidString;
                
                //
                // Connect to the AWS IoT service
                //
                iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:certificateId!, statusCallback: mqttEventCallback)
            }
        }
        else
        {
//            activityIndicatorView.startAnimating()
            print("Disconnecting...")
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                self.iotDataManager.disconnect();
                DispatchQueue.main.async {
//                    self.activityIndicatorView.stopAnimating()
                    self.connected = false
                }
            }
        }
    }
    
    func publish(data: String) {
        let iotDataManager = AWSIoTDataManager.default()
        
        iotDataManager.publishString(data, onTopic:topic, qoS:.messageDeliveryAttemptedAtMostOnce)
    }
    
    func subscribe() {
        let iotDataManager = AWSIoTDataManager.default()
        
        iotDataManager.subscribe(toTopic: topic, qoS: .messageDeliveryAttemptedAtMostOnce, messageCallback: {
            (payload) ->Void in
            let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!
            
            print("received: \(stringValue)")
            DispatchQueue.main.async {
                
            }
        } )
    }

}
