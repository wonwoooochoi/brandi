//
//  ListViewController.swift
//  brandi
//
//  Created by Wonwoo Choi on 2020/12/31.
//

import UIKit
import RxCocoa
import RxSwift

final class ListViewController: UIViewController {
	
	@IBOutlet private weak var searchBar: UISearchBar!
	@IBOutlet private weak var collectionView: UICollectionView!
	
	private let viewModel = ListViewModel()
	private let disposeBag = DisposeBag()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .purple
		
		setUpSearchBar()
		setUpCollectionView()
		setUpViewModel()
		
    }
	
}


extension ListViewController {
	
	private func setUpSearchBar() {
		searchBar.rx.text.orEmpty
			.distinctUntilChanged()
			.debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
			.subscribe { [weak self] text in
				self?.viewModel.keyword.accept(text)
			}
			.disposed(by: disposeBag)
		
	}
	
	
	private func setUpCollectionView() {
		
		let width = UIScreen.main.bounds.width / 3
		
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: width, height: width)
		layout.sectionInset = .zero
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		
		collectionView.collectionViewLayout = layout
		collectionView.register(ListCell.self)
		
		collectionView.rx.willDisplayCell
			.map { [weak self] event -> Bool in
				
				guard let self = self else { return false }
				
				let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
				
				guard numberOfItems > 0 else { return false }
				
				let item = event.at.item
				let isLast = item == numberOfItems - 1
				
				return isLast
				
			}
			.filter { $0 == true }
			.subscribe { [weak self] item in
				self?.viewModel.loadMore()
			}
			.disposed(by: disposeBag)
		
		collectionView.rx.itemSelected
			.subscribe(onNext:{ [weak self] indexPath in
				self?.view.endEditing (true)
				self?.presentDetail(at: indexPath.item)
			})
			.disposed(by: disposeBag)
		
	}
	
	
	private func setUpViewModel() {
		
		viewModel.documents.asObservable()
			.bind(to: collectionView.rx.items) { (collectionView, row, element) -> UICollectionViewCell in
				return self.listCell(document: element, row: row) ?? UICollectionViewCell()
			}
			.disposed(by: disposeBag)
		
		viewModel.errorMessage
			.observeOn(MainScheduler.instance)
			.subscribe { [weak self] errorMessage in
				self?.showAlert(message: errorMessage)
			}
			.disposed(by: disposeBag)

	}
	
}


// MARK: - Cell

extension ListViewController {
	
	private func listCell(document: Document, row: Int) -> UICollectionViewCell? {
		
		let cell = collectionView.dequeueReusableCell(ListCell.self, for: IndexPath(item: row, section: 0))
		cell.document = document
		
		return cell
		
	}
	
}


// MARK: - Present

extension ListViewController {
	
	private func showAlert(message: String) {
		
		let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
		
	}
	
	
	private func presentDetail(at index: Int) {
		
		let detail = DetailViewController.instantiate()
		detail.document = viewModel.document(at: index)
		
		present(detail, animated: true, completion: nil)
		
	}
	
}
