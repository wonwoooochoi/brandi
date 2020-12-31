//
//  Item.swift
//  brandi
//
//  Created by Wonwoo Choi on 2020/12/31.
//

import Foundation

struct Document: Codable {
	
	let collection: String
	let datetime: String
	let displaySitename: String
	let docUrl: String
	let height: Int
	let imageUrl: String
	let thumbnailUrl: String
	let width: Int

	enum CodingKeys: String, CodingKey {
		case collection
		case datetime
		case displaySitename = "display_sitename"
		case docUrl = "doc_url"
		case height
		case imageUrl = "image_url"
		case thumbnailUrl = "thumbnail_url"
		case width
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.collection = (try? container.decode(String.self, forKey: .collection)) ?? ""
		self.datetime = (try? container.decode(String.self, forKey: .datetime)) ?? ""
		self.displaySitename = (try? container.decode(String.self, forKey: .displaySitename)) ?? ""
		self.docUrl = (try? container.decode(String.self, forKey: .docUrl)) ?? ""
		self.height = (try? container.decode(Int.self, forKey: .height)) ?? 0
		self.imageUrl = (try? container.decode(String.self, forKey: .imageUrl)) ?? ""
		self.thumbnailUrl = (try? container.decode(String.self, forKey: .thumbnailUrl)) ?? ""
		self.width = (try? container.decode(Int.self, forKey: .width)) ?? 0
	}
	
}

extension Document: Equatable {
	
	static func == (lhs: Document, rhs: Document) -> Bool {
		return lhs.imageUrl == rhs.imageUrl
	}
	
}


struct Meta: Codable {
	
	let isEnd: Bool
	let pageableCount: Int
	let totalCount: Int
	
	enum CodingKeys: String, CodingKey {
		case isEnd = "is_end"
		case pageableCount = "pageable_count"
		case totalCount = "total_count"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.isEnd = (try? container.decode(Bool.self, forKey: .isEnd)) ?? true
		self.pageableCount = (try? container.decode(Int.self, forKey: .pageableCount)) ?? 0
		self.totalCount = (try? container.decode(Int.self, forKey: .totalCount)) ?? 0
	}
	
}


struct Items: Codable {
	
	let documents: [Document]
	let meta: Meta?
	
	enum CodingKeys: String, CodingKey {
		case documents
		case meta
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.documents = (try? container.decode([Document].self, forKey: .documents)) ?? []
		self.meta = try? container.decode(Meta.self, forKey: .meta)
	}
	
}
