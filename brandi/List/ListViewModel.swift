//
//  ListViewModel.swift
//  brandi
//
//  Created by Wonwoo Choi on 2020/12/31.
//

import Foundation
import RxCocoa
import RxSwift

final class ListViewModel {
	
	var keyword = BehaviorRelay<String>(value: "")
	
	private(set) var documents = BehaviorRelay<[Document]>(value: [])
	private(set) var errorMessage = BehaviorRelay<String>(value: "")

	private var meta = BehaviorRelay<Meta?>(value: nil)
	private let disposeBag = DisposeBag()
	private var currentKeyword: String?
	private var currentPage = 1
	private var isEnd = false
	
	init() {
		
		keyword
			.filter { !$0.isEmpty }
			.do { [weak self] in
				self?.currentKeyword = $0
				self?.currentPage = 1
			}
			.flatMap { [weak self] keyword -> Observable<Data?> in
				return self?.requestItemData(keyword: keyword, page: 1).asObservable() ?? Observable.empty()
			}
			.compactMap { $0 }
			.flatMap { [weak self] data -> Observable<Items> in
				return self?.convertItemData(data).asObservable() ?? Observable.empty()
			}
			.subscribe { [weak self] items in
				self?.acceptItems(items, reset: true)
			} onError: { [weak self] error in
				self?.acceptErrorMessage(error: error)
			}
			.disposed(by: disposeBag)
		
	}
	
}


// MARK: - Public

extension ListViewModel {
	
	func loadMore() {
		
		guard isEnd == false,
			  let keyword = currentKeyword
		else { return }
		
		currentPage += 1
		
		requestItemData(keyword: keyword, page: currentPage)
			.asObservable()
			.compactMap { $0 }
			.flatMap { [weak self] data -> Observable<Items> in
				return self?.convertItemData(data).asObservable() ?? Observable.empty()
			}
			.subscribe { [weak self] items in
				self?.acceptItems(items)
			} onError: { [weak self] error in
				self?.acceptErrorMessage(error: error)
			}
			.disposed(by: disposeBag)
		
	}
	
	
	func document(at index: Int) -> Document {
		return documents.value[index]
	}
	
}


// MARK: - Fetch

extension ListViewModel {
	
	private func acceptItems(_ items: Items, reset: Bool = false) {
		
		var documents = [Document]()
		
		if !reset {
			documents.append(contentsOf: self.documents.value)
		}
		
		documents.append(contentsOf: items.documents)
		
		self.documents.accept(documents)
		isEnd = items.meta?.isEnd ?? false
		
		if documents.count == 0 {
			acceptErrorMessage(error: RequestError.empty)
		}
		
	}
	
	
	private func acceptErrorMessage(error: Error) {
		
		guard let requestError = error as? RequestError else { errorMessage.accept(error.localizedDescription); return }
		
		switch requestError {
			case .request: errorMessage.accept("요청이 실패하였습니다.")
			case .parse: errorMessage.accept("처리에 실패하였습니다.")
			case .empty: errorMessage.accept("검색 결과가 없습니다.")
			default: errorMessage.accept("알 수 없는 오류.")
		}
		
	}
	
}


// MARK: - Request

extension ListViewModel {
	
	private func requestItemData(keyword: String, page: Int) -> Single<Data?> {
		
		return Single<Data?>.create { single in
			
			let urlString = "https://dapi.kakao.com/v2/search/image"
			var urlComponents = URLComponents(string: urlString)!
			urlComponents.queryItems = [
				URLQueryItem(name: "query", value: keyword),
				URLQueryItem(name: "page", value: String(page)),
				URLQueryItem(name: "size", value: "30")
			]
			
			var request = URLRequest(url: urlComponents.url!)
			request.httpMethod = "GET"
			request.setValue(Config.apiKey, forHTTPHeaderField: "Authorization")
			
			let task = URLSession.shared.dataTask(with: request) { data, response, error in
				
				if let error = error {
					single(.error(error))
				}
				else if let data = data {
					single(.success(data))
				}
				else {
					single(.error(RequestError.request))
				}
				
			}
			
			task.resume()
			
			return Disposables.create()
			
		}
		
	}
	
	
	private func convertItemData(_ data: Data) -> Single<Items> {
		
		return Single<Items>.create { single in
			
			guard let items = try? JSONDecoder().decode(Items.self, from: data)
			else { return Disposables.create() }
			
			single(.success(items))
			
			return Disposables.create()
			
		}
		
	}
	
}
