//
//  TabBarInteractor.swift
//  CoLab
//
//  Created by User on 07.03.2026.
//

import Foundation

final class TabBarInteractor: TabBarBusinessLogic {
    
    private let presenter: TabBarPresentationLogic
    
    private let colorRepository: ColorStorageLogic
    
    // MARK: Lifecycle
    
    init(
        presenter: TabBarPresentationLogic,
        colorRepository: ColorStorageLogic
    ) {
        self.presenter = presenter
        self.colorRepository = colorRepository
    }
    
    // MARK: Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                firstGradient: colorRepository.firstGradientColor,
                secondGradient: colorRepository.secondGradientColor,
                buttonsColor: colorRepository.tabBarButtonsColor,
                wrapperColor: colorRepository.tabBarWrapperColor
            )
        )
    }
}
