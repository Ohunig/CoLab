//
//  AuthMainScreenPresentationLogic.swift
//  CoLab
//
//  Created by User on 03.02.2026.
//

import Foundation

protocol AuthMainScreenPresentationLogic: AnyObject {
    typealias Model = AuthMainScreenModels

    func presentStart(_ response: Model.Start.Response)
}
