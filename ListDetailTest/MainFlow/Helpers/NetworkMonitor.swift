//
//  NetworkMonitor.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isConnected: Bool = true
    var onStatusChange: ((Bool) -> Void)?

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            DispatchQueue.main.async {
                self?.isConnected = connected
                self?.onStatusChange?(connected)
            }
        }
        monitor.start(queue: queue)
    }
}
