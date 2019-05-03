//
//  AppServicesManager.swift
//  PluggableAppDelegate
//
//  Created by Fernando Ortiz on 2/24/17.
//  Modified by Mikhail Pchelnikov on 31/07/2018.
//  Copyright © 2018 Michael Pchelnikov. All rights reserved.
//

import UIKit

/// This is only a tagging protocol.
/// It doesn't add more functionalities yet.
public protocol ApplicationService: UIApplicationDelegate {}

extension ApplicationService {
    public var window: UIWindow? {
        return UIApplication.shared.delegate?.window ?? nil
    }
}

open class PluggableApplicationDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?

    open var services: [ApplicationService] { return [] }

    internal lazy var _services: [ApplicationService] = {
        return self.services
    }()

    @discardableResult
    internal func apply<T, S>(_ work: (ApplicationService, @escaping (T) -> Void) -> S?, completionHandler: @escaping ([T]) -> Swift.Void) -> [S] {
        let dispatchGroup = DispatchGroup()
        var results: [T] = []
        var returns: [S] = []

        for service in _services {
            dispatchGroup.enter()
            let returned = work(service, { result in
                results.append(result)
                dispatchGroup.leave()
            })
            if let returned = returned {
                returns.append(returned)
            } else { // delegate doesn't impliment method
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completionHandler(results)
        }

        return returns
    }
    
    //service,service.completion) ->service.completion
    //[service,service.completion) ->service.completion]
    //*[service.completion]
    @discardableResult
    internal func apply2<ReturnType>(_ work:
        (ApplicationService, @escaping () -> Swift.Void) -> ReturnType?,
        completionHandler: @escaping () -> Swift.Void) -> [ReturnType] {
        let dispatchGroup = DispatchGroup()
       // var results: [T] = []
        var returns: [ReturnType] = []
        
        for service in _services {
            dispatchGroup.enter()
            let returned = work(service, { 
                //results.append(result)
                dispatchGroup.leave()
            })
            if let returned = returned {
                returns.append(returned)
            } else { // delegate doesn't impliment method
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completionHandler()
        }
        
        return returns
    }
    
    
}
