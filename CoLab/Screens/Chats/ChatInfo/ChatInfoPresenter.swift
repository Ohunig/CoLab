//
//  ChatInfoPresenter.swift
//  CoLab
//
//  Created by User on 14.04.2026.
//

import Foundation

final class ChatInfoPresenter: ChatInfoPresentationLogic {
    
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
    }
    
    weak var controller: ChatInfoDisplayLogic?
    
    // MARK: Present
    
    func presentStart(_ response: Model.Start.Response) {
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (hex: response.bgGradient.hex, a: response.bgGradient.alpha),
                elementsBase: (hex: response.elementsBase.hex, a: response.elementsBase.alpha),
                tint: (hex: response.tint.hex, a: response.tint.alpha),
                textColor: (hex: response.textColor.hex, a: response.textColor.alpha)
            )
        )
    }
    
    func presentChatData(_ response: Model.GetChatData.Response) {
        controller?.displayChatData(
            Model.GetChatData.ViewModel(
                avatarData: response.avatarData,
                isAvatarLoading: response.isAvatarLoading,
                title: response.title,
                memberNames: response.memberNames
            )
        )
    }
    
    func presentError(_ response: Model.ShowError.Response) {
        controller?.displayError(
            Model.ShowError.ViewModel(
                errorTitle: Constants.errorTitle,
                errorDescription: response.error.localizedDescription,
                buttonText: Constants.alertOk
            )
        )
    }
}
