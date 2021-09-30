//
//  NetworkableTasks.swift
//  MBNetworking
//
//  Created by Rashid Ramazanov on 9/30/21.
//  Copyright © 2021 Mobven. All rights reserved.
//

import Foundation

/// `NetworkableTasks` helper enum.
public enum NetworkableTasks {
    /// Cancels all the tasks those are in progress.
    /// Tasks those are cancelled will return with `Result.failure(NetworkingError.dataTaskCancelled)`.
    public static func cancellAll() {
        for task in Session.shared.tasksInProgress.values {
            task.cancel()
        }
        Session.shared.tasksInProgress.removeAll()
    }
}
