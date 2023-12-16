//
//  NetworkMonitor.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 9/25/23.
//

import Foundation
import Network


class NetworkMonitor: ObservableObject {
    
    private let queue = DispatchQueue(label: "Monitor")
    private let monitor = NWPathMonitor()
    @Published var isConnected = false
    @Published var connectionType =  NWInterface.InterfaceType.other
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                
                let connectionTypes: [NWInterface.InterfaceType] = [.cellular, .wifi, .wiredEthernet]
                
                self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other
            }
            
            
        }
        monitor.start(queue: queue)
    }
    
}
