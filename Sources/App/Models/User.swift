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
    var facebookId: String
    var email: String
    var name: String
    var avatar: String?
    var pushToken: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(facebookId: String, email: String, name: String) {
        self.facebookId = facebookId
        self.email = email
        self.name = name
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = AuthToken
}

extension User: Migration { }
extension User: Content { }
