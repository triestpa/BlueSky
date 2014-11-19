//
//  TraitOverrideSplitViewController.swift
//  BlueSky
//
//  Copied by Patrick on 11/19/14.
//  Created by Imre Kelényi
//

import UIKit

class TraitOverrideSplitViewController: UISplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performTraitCollectionOverrideForSize(view.bounds.size)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            
            super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
            performTraitCollectionOverrideForSize(size)
    }
    
    private func performTraitCollectionOverrideForSize(size: CGSize) {
        var overrideTraitCollection: UITraitCollection? = nil
        if size.width > 320 {
            overrideTraitCollection = UITraitCollection(horizontalSizeClass: .Regular)
        }
        for vc in self.childViewControllers as [UIViewController] {
            setOverrideTraitCollection(overrideTraitCollection, forChildViewController: vc)
        }
    }
}