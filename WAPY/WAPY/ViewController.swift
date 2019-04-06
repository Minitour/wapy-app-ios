//
//  ViewController.swift
//  WAPY
//
//  Created by Antonio Zaitoun on 20/03/2019.
//  Copyright © 2019 Antonio Zaitoun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // The first task
        let task1 = Task(info: "Please look around", details: "Keep looking around in order to give the camera a better indication of where everything is. Look at the ground, at the walls, at the objects around.", completed: false)

        // find the camera
        let task2 = Task(info: "Find the camera", details: "Please look at the camera until you are prompted to continue.", completed: false)

        // mark the products
        let task3 = Task(info: "Mark your products", details: "Go up to your products with your device. Get really close as if your device is physically touching the item and then click on the \"Mark\" button.", completed: false)

        // mark the window
        let task4 = Task(info: "Mark your window", details: "Go up to the most upper right corner of your window and click the \"Mark Start\" button, then proceed into going to the lowest left corner of the window and click the \"Mark End\" button. While scanning you will see a line drawn across the edge.", completed: false)

        // review everything
        let task5 = Task(info: "Review", details: "Go ahead and look around to see if this is everything you wanted. After this you cannot make any modifications.", completed: false)

        let controller = RoomMapController()

        controller.taskManager.addTask(task1)
        controller.taskManager.addTask(task2)
        controller.taskManager.addTask(task3)
        controller.taskManager.addTask(task4)
        controller.taskManager.addTask(task5)

        present(controller, animated: true, completion: nil)
    }
}

