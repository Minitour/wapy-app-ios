//
//  TaskManager.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 06/04/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import Foundation

public struct TaskManager {

    var currentIndex: Int = 0
    var tasks: [Task] = []

    public func current() -> Task? {
        if currentIndex >= tasks.count {
            return nil
        }

        // return next task to complete
        return tasks[currentIndex]
    }

    public mutating func addTask(_ task: Task) {
        tasks.append(task)
    }

    public mutating func didCompleteTask() -> Task? {
        currentIndex += 1
        if currentIndex >= tasks.count {
            return nil
        }

        // return next task to complete
        return tasks[currentIndex]
    }

    public mutating func reset() {
        currentIndex = 0
    }
}
