//
//  User.swift
//  App
//
//  Created by Huu Tai Vuong on 11/19/18.
//

import Foundation
import FluentSQLite
import Vapor
import Authentication

struct User: SQLiteModel {
    var id: Int?
    var name: String
    var phone: String?
    var avatar: String?
    var location: String?
    
    //From facebook
    var facebookId: String?
    var email: String
    
    var pushToken: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var inventories: Children<User, Inventory> {
        return children(\.ownerId)
    }
    
    init(facebookId: String, email: String, name: String) {
        self.facebookId = facebookId
        self.email = email
        self.name = name
    }
    
    struct UpdateUserForm: Content {
        var name: String?
        var pushToken: String?
        
        enum CodingKeys: String, CodingKey {
            case name
            case pushToken = "push_token"
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(phone, forKey: .phone)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(location, forKey: .location)
        try container.encode(facebookId, forKey: .facebookId)
        try container.encode(email, forKey: .email)
        try container.encode(pushToken, forKey: .pushToken)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case avatar
        case location
        case facebookId = "facebook_id"
        case email
        case pushToken = "push_token"
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = AuthToken
}

extension User: Migration { }
extension User: Content { }
