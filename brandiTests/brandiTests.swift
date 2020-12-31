//
//  brandiTests.swift
//  brandiTests
//
//  Created by Wonwoo Choi on 2020/12/31.
//

import XCTest
@testable import brandi

class brandiTests: XCTestCase {
	
	func testSearchAPI() throws {
		
		let expectation = self.expectation(description: "wait networking...")
		
		request(keyword: "bts", page: 2) { 
			expectation.fulfill()
			XCTAssertNotNil($0)
		} failure: {
			expectation.fulfill()
			XCTFail($0.localizedDescription)
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)		
		
	}
	
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


extension brandiTests {
	
	func request(keyword: String,
				 page: Int,
				 success:((Items) -> Void)? = nil,
				 failure: ((Error) -> Void)? = nil) -> Void {
		
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
				failure?(error)
			}
			else if let data = data {
				
				guard let items = try? JSONDecoder().decode(Items.self, from: data)
				else { failure?(RequestError.parse); return }
				
				success?(items)
				
			}
			else {
				failure?(RequestError.request)
			}
			
		}
		
		task.resume()
		
	}
	
}
