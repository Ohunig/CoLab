//
//  ViewController.swift
//  CoLab
//
//  Created by User on 21.01.2026.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let outColor = UIColor(hex: "#553D01", alpha: 1)
        let bgColor = UIColor(hex: "#111111", alpha: 1)
        let bg = MainBackgroundView(backgroundColor: bgColor, gradientColor: outColor)
        setCustomBackground(backgroundView: bg)
    }

}

