//
//  CustomTabBarDelegate.swift
//  CoLab
//
//  Created by User on 07.03.2026.
//

import Foundation

protocol CustomTabBarDelegate: AnyObject {
    // Нажата кнопка на таб баре под выбранным индексом
    func customTabBar(_ bar: CustomTabBar, didSelectIndex index: Int)
    
    // Нажата отделённая от таб бара кнопка
    func customTabBarDidTapActionButton(_ bar: CustomTabBar)
}
