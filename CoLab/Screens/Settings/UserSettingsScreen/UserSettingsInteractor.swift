//
//  UserSettingsInteractor.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation

final class UserSettingsInteractor: UserSettingsBusinessLogic {
    
    private let presenter: UserSettingsPresentationLogic
    
    private let colorRepository: ColorStorageLogic
    
    // MARK: Lifecycle
    
    init(
        presenter: UserSettingsPresentationLogic,
        colorRepository: ColorStorageLogic
    ) {
        self.presenter = presenter
        self.colorRepository = colorRepository
    }
    
    // MARK: Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                tint: colorRepository.tintColor,
                textColor: colorRepository.mainTextColor
            )
        )
    }
}
