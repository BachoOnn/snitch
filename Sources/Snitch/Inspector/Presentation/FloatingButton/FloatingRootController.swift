//
//  FloatingRootController.swift
//  Snitch
//
//  Created by BOniani on 13/11/2026.
//

import UIKit

final class FloatingRootController: UIViewController {
    private var app: UIViewController? { InspectorPresenter.topViewController() }

    override var prefersStatusBarHidden: Bool { app?.prefersStatusBarHidden ?? false }
    override var preferredStatusBarStyle: UIStatusBarStyle { app?.preferredStatusBarStyle ?? .default }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        app?.supportedInterfaceOrientations ?? .all
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
    }
}
