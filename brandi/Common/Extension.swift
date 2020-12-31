//
//  Extension.swift
//  brandi
//
//  Created by Wonwoo Choi on 2020/12/31.
//

import Foundation
import UIKit

extension UICollectionView {
	
	func dequeueReusableCell<T: UICollectionViewCell>(_: T.Type, for indexPath: IndexPath) -> T {
		let name = String(describing: T.self)
		guard let cell = dequeueReusableCell(withReuseIdentifier: name, for: indexPath) as? T else {
			fatalError("dequeue fail: '\(name)'")
		}
		return cell
	}
	
	func register<T: UICollectionViewCell>(_: T.Type) {
		let name = String(describing: T.self)
		register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
	}
	
}


extension UIViewController {
	
	static func instantiate() -> Self {
		
		let name = String(describing: self)
		let storyboard = UIStoryboard(name: name, bundle: nil)
		
		guard let viewController = storyboard.instantiateViewController(withIdentifier: name) as? Self else {
			fatalError("instantiate fail: '\(self)'")
		}
		
		return viewController
		
	}
	
}
