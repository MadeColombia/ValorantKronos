//
//  SwipeBackGestureModifier.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 23/09/26.
//  Re-enables the interactive swipe-to-go-back gesture on iOS when custom back buttons are used.
//

import UIKit
import SwiftUI

// MARK: - Global Navigation Controller Swipe-Back Support

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

// MARK: - View Modifier for Explicit Screen-Level Attachment

private struct SwipeBackModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(SwipeBackRepresentable())
    }
}

private struct SwipeBackRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            if let nav = uiViewController.navigationController {
                nav.interactivePopGestureRecognizer?.isEnabled = true
                nav.interactivePopGestureRecognizer?.delegate = context.coordinator
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
    }
}

public extension View {
    /// Ensures interactive swipe-to-go-back gesture is active on this view even with custom back buttons.
    func enableSwipeBack() -> some View {
        self.modifier(SwipeBackModifier())
    }
}
