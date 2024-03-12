//
//  NetworkLogMonitoring.swift
//  MBNetworking
//
//  Created by Hasan Güler on 12.03.2024.
//

import Foundation

public protocol NetworkLogMonitoringDelegate {
    func logTaskCreated(task: URLSessionTask)
    func logDataTask(dataTask: URLSessionDataTask, didReceive data: Data)
    func logTask(task: URLSessionTask, didCompleteWithError error: Error?)
}
