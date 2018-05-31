//
//  collaboratorModel.swift
//  Collaborator
//  s5062234
//  Created by Ashman Malik on 2/5/18.
//  Copyright © 2018 Ashman Malik. All rights reserved.
//

import Foundation

class colitem {
    var task: String // Tasks are the initial tasks that are
    var collaboration: String // Collaboration are for collaborators Peers that will be shown by Multipeers
    var log = [String]() // Logs are for logs
    
    init(task: String, collaboration: String, log: [(String)]){ // Initializing Constructor
        self.task = task
        self.collaboration = collaboration
        self.log = log
    }
}
