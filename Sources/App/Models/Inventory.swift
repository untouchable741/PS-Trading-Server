//
//  Inventory.swift
//  App
//
//  Created by Huu Tai Vuong on 11/19/18.
//

import Foundation
import Vapor
import FluentPostgreSQL


struct Inventory: PostgreSQLModel {
    var id: Int?
    var gameId: Int
    var tradeItemIds: String?
    var price: Double
    var region: String
    var location: String
    var status: String
    var type: String
    
    //External information
    var cover: String?
    var name: String?
    var description: String?
    
    var ownerId: User.ID
    
    struct CreateInventoryForm: Content {
        var game_id: Int?
        var trade_item_ids: [Int]?
        var price: Double?
        var region: String?
        var location: String?
        var status: String?
        var type: String?
        
        //External information
        var cover: String?
        var name: String?
        var description: String?
    }

    init(form: CreateInventoryForm,
         gameId: Int,
         ownerId: User.ID) {
        self.gameId = gameId
        self.tradeItemIds = (form.trade_item_ids ?? []).toString()
        self.price = form.price ?? 0
        self.region = form.region ?? ""
        self.location = form.location ?? ""
        self.status = form.status ?? ""
        self.type = form.type ?? ""
        self.cover = form.cover
        self.name = form.name
        self.description = form.description
        self.ownerId = ownerId
    }
    
    mutating func updated(from form: CreateInventoryForm) {
        self.gameId = form.game_id ?? gameId
        self.tradeItemIds = (form.trade_item_ids != nil ? form.trade_item_ids?.toString() : tradeItemIds)
        self.price = form.price ?? price
        self.region = form.region ?? region
        self.location = form.location ?? location
        self.status = form.status ?? status
        self.type = form.type ?? type
        self.cover = form.cover ?? cover
        self.name = form.name ?? name
        self.description = form.description ?? description
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(gameId, forKey: .gameId)
        try container.encode(tradeItemIds?.toIntArray(), forKey: .tradeItemIds)
        try container.encode(price, forKey: .price)
        try container.encode(region, forKey: .region)
        try container.encode(location, forKey: .location)
        try container.encode(status, forKey: .status)
        try container.encode(type, forKey: .type)
        try container.encode(cover, forKey: .cover)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(ownerId, forKey: .ownerId)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        gameId = try container.decode(Int.self, forKey: .gameId)
        let tradeIds = try container.decode([Int]?.self, forKey: .tradeItemIds)
        tradeItemIds = tradeIds?.toString()
        price = try container.decode(Double.self, forKey: .price)
        region = try container.decode(String.self, forKey: .region)
        location = try container.decode(String.self, forKey: .location)
        status = try container.decode(String.self, forKey: .status)
        type = try container.decode(String.self, forKey: .type)
        cover = try container.decode(String.self, forKey: .cover)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        ownerId = try container.decode(Int.self, forKey: .ownerId)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case gameId = "game_id"
        case tradeItemIds = "trade_item_ids"
        case price
        case region
        case location
        case status
        case type
        case cover
        case name
        case description
        case ownerId
    }
}

extension Inventory: Migration { }

extension Inventory: Content { }


extension Array where Element == Int {
    func toString() -> String? {
        return self.map { "\($0)"}.joined(separator: ",")
    }
}

extension String {
    func toIntArray() -> [Int]? {
        return self.components(separatedBy: ",").compactMap { Int($0) }
    }
}
