//
//  DetailViewController.swift
//  brandi
//
//  Created by Wonwoo Choi on 2020/12/31.
//

import UIKit
import RxCocoa
import RxSwift

class DetailViewController: UIViewController {
	
	var document: Document?
	
	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var siteLabel: UILabel!
	@IBOutlet private weak var dateLabel: UILabel!
	@IBOutlet private weak var closeButton: UIButton!
	@IBOutlet private weak var imageHeight: NSLayoutConstraint!

	private let disposeBag = DisposeBag()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setUp()
		setUpView()
    }
	
	
	private func setUp() {
		
		guard let urlStrig = document?.imageUrl else { return }
		
		DispatchQueue.global().async { [weak self] in
			
			guard let self = self,
				  let url = URL(string: urlStrig),
				  let data = try? Data(contentsOf: url),
				  let image = UIImage(data: data)
			else { return }
			
			let ratio = image.size.width / image.size.height
			let screenSize = UIScreen.main.bounds.size
			let height = screenSize.width / ratio
			
			DispatchQueue.main.async {
				self.imageView.image = image
				self.imageHeight.constant = height
			}
			
		}
		
	}
	
	
	private func setUpView() {
		
		siteLabel.text = document?.displaySitename
		dateLabel.text = document?.datetime
		
		closeButton.rx.tap
			.subscribe { [weak self] _ in
				self?.dismiss(animated: true, completion: nil)
			}
			.disposed(by: disposeBag)
		
	}

}
