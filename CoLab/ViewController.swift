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
        
//        let logo = UIImage(named: "CoLabScreenIcon")
//        let logoView = UIImageView(image: logo)
//        logoView.contentMode = .scaleAspectFit
//        logoView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(logoView)
//        NSLayoutConstraint.activate(
//            [
//                logoView.leadingAnchor.constraint(
//                    equalTo: view.leadingAnchor,
//                    constant: 112
//                ),
//                logoView.centerXAnchor.constraint(
//                    equalTo: view.centerXAnchor
//                ),
//                logoView.centerYAnchor.constraint(
//                    equalTo: view.centerYAnchor,
//                    constant: -100
//                )
//            ]
//        )
        
        let button = FilledGradientButton()
        button.setTitle("Log in", for: .normal)
        button.startColor = UIColor(hex: "#D1772D")
        button.endColor = UIColor(hex: "#E2A712")
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate(
            [
                button.heightAnchor.constraint(equalToConstant: 65),
                button.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 22
                ),
                button.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                )
            ]
        )
        
        let button2 = BorderGradientButton()
        button2.setTitle("Sign up", for: .normal)
        button2.startColor = UIColor(hex: "#D1772D")
        button2.endColor = UIColor(hex: "#E2A712")
        button2.setTitleColor(UIColor(hex: "#E2A712"), for: .normal)
        button2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button2)
        NSLayoutConstraint.activate(
            [
                button2.heightAnchor.constraint(equalToConstant: 65),
                button2.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 22
                ),
                button2.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                ),
                button2.topAnchor.constraint(
                    equalTo: button.bottomAnchor,
                    constant: 20
                ),
                button2.bottomAnchor.constraint(
                    equalTo: view.bottomAnchor,
                    constant: -91
                )
            ]
        )
        
        let tf = ImageTextField(image: UIImage(systemName: "envelope") ?? UIImage())
        tf.tintColor = UIColor(hex: "#7E6C4F", alpha: 0.5)
        tf.baseColor = UIColor(hex: "#4C4232")
        tf.placeholder = "Write your email"
        tf.textColor = UIColor(hex: "#7E6C4F")
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tf)
        
        NSLayoutConstraint.activate(
            [
                tf.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 22
                ),
                tf.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                ),
                tf.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 400
                ),
                tf.heightAnchor.constraint(
                    equalToConstant: 65
                )
            ]
        )
        
        
        let back = BackNavBarButton(image: UIImage(systemName: "chevron.backward") ?? UIImage())
        back.baseColor = UIColor(hex: "#4C4232")
        back.tintColor = UIColor(hex: "#7E6C4F")
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
        navigationItem.leftBarButtonItem?.hidesSharedBackground = true
        
        
    }
    
}

