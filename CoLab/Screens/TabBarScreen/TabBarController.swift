//
//  TabBarController.swift
//  CoLab
//
//  Created by User on 07.03.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let houseImage = "house.fill"
        static let searchImage = "magnifyingglass"
        static let personImage = "person.fill"
        static let gearImage = "gearshape.fill"
        static let plusImage = "plus"
        
        static let horisontalInset: CGFloat = 22
        static let tabBarHeight: CGFloat = 90
        static let startSelectedButton = 0
        
        static let notHiddenTabBarTrailing: CGFloat = 0
        static let hiddenTabBarTrailing: CGFloat = 200
        static let hideTabBarDuration: CGFloat = 0.25
        
        static let maxScreensCountWithTabBar = 1
    }
    
    private let interactor: TabBarBusinessLogic

    private let customBar: CustomTabBar
    
    lazy private var bottomConstraint: NSLayoutConstraint = customBar.bottomAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.bottomAnchor
    )
    
    override var viewControllers: [UIViewController]? {
        didSet {
            assignNavDelegates()
        }
    }
    
    // MARK: Lifecycle
    
    init(interactor: TabBarBusinessLogic) {
        self.interactor = interactor
        
        // Создаём customBar
        let imgs = [
            UIImage(systemName: Constants.houseImage),
            UIImage(systemName: Constants.searchImage),
            UIImage(systemName: Constants.personImage),
            UIImage(systemName: Constants.gearImage)
        ]
        let actionImage = UIImage(systemName: Constants.plusImage)
        customBar = CustomTabBar(
            itemImages: imgs,
            actionImage: actionImage
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabBar()
        configureNavigationBar()
    }
    
    // MARK: Configure UI
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func configureTabBar() {
        tabBar.isHidden = true
        selectedIndex = Constants.startSelectedButton
        customBar.selectButton(at: Constants.startSelectedButton)
        customBar.delegate = self
        customBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customBar)
        
        bottomConstraint = customBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            customBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset),
            customBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horisontalInset),
            customBar.heightAnchor.constraint(equalToConstant: Constants.tabBarHeight),
            // Выставляем нижний констрейнт
            bottomConstraint
        ])
    }
    
    // MARK: Set tab bar state
    
    func setTabBar(hidden: Bool, animated: Bool = true) {
        bottomConstraint.constant = hidden ? Constants.hiddenTabBarTrailing : Constants.notHiddenTabBarTrailing
        if animated {
            UIView.animate(withDuration: Constants.hideTabBarDuration) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
    
    // MARK: Assign nav delegates
    
    private func assignNavDelegates() {
        guard let vcs = viewControllers else { return }
        for vc in vcs {
            if let nav = vc as? UINavigationController {
                nav.delegate = self
            }
        }
    }
}

// MARK: - CustomTabBarDelegate

extension TabBarController: CustomTabBarDelegate {
    
    func customTabBar(_ bar: CustomTabBar, didSelectIndex index: Int) {
        selectedIndex = index
    }

    func customTabBarDidTapActionButton(_ bar: CustomTabBar) {
        let modal = UINavigationController(rootViewController: ModalActionVC())
        modal.modalPresentationStyle = .fullScreen
        present(modal, animated: true, completion: nil)
    }
}

// MARK: - TabBarDisplayLogic

extension TabBarController: TabBarDisplayLogic {
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Прокидываем нужные цвета в таб бар
        customBar.gradientColors = (
            UIColor(hex: viewModel.firstGradient.hex, alpha: viewModel.firstGradient.a),
            UIColor(hex: viewModel.secondGradient.hex, alpha: viewModel.secondGradient.a)
        )
        customBar.standardButtonColor = UIColor(hex: viewModel.buttonsColor.hex, alpha: viewModel.buttonsColor.a)
        customBar.wrapperColor = UIColor(hex: viewModel.wrapperColor.hex, alpha: viewModel.wrapperColor.a)
    }
}

// MARK: - Navigation controller delegate

extension TabBarController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Если количество экранов в контроллере больше одного, скрываем таб бар всегда
        if navigationController.viewControllers.count > Constants.maxScreensCountWithTabBar {
            setTabBar(hidden: true)
        } else {
            setTabBar(hidden: false)
        }
    }
}

class ModalActionVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let lbl = UILabel()
        lbl.text = "Modal / Full Screen"
        lbl.font = .systemFont(ofSize: 24, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(close))
    }
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
