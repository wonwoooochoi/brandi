//
//  ListCell.swift
//  brandi
//
//  Created by Wonwoo Choi on 2020/12/31.
//

import UIKit

class ListCell: UICollectionViewCell {
	
	var document: Document? {
		willSet {
			
			imageView.image = nil
			
			guard let thumbnailUrl = newValue?.thumbnailUrl else { return }
			
			DispatchQueue.global().async { [weak self] in
				
				guard let self = self,
					  let url = URL(string: thumbnailUrl),
					  let data = try? Data(contentsOf: url),
					  let image = UIImage(data: data)
				else { return }
				
				DispatchQueue.main.async {
					self.imageView.image = image
				}
				
			}
			
		}
	}
	
	@IBOutlet private weak var imageView: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
