//
//  AuthMainScreenBusinessLogic.swift
//  CoLab
//
//  Created by User on 03.02.2026.
//

import Foundation

protocol AuthMainScreenBusinessLogic: AnyObject {
    typealias Model = AuthMainScreenModels
    
    func loadStart()
}
