//
//  AuthToken.swift
//  App
//
//  Created by Huu Tai Vuong on 11/19/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

struct AuthToken: MySQLModel {
    var id: Int?
    var token: String
    var userId: User.ID
    
    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
    
    var user: Parent<AuthToken, User> {
        return parent(\.userId)
    }
}

extension AuthToken: BearerAuthenticatable {
    static var tokenKey: WritableKeyPath<AuthToken, String> {
        return \AuthToken.token
    }
}

extension AuthToken: Authentication.Token {
    typealias UserType = User
    typealias UserIDType = User.ID
    static var userIDKey: WritableKeyPath<AuthToken, User.ID> {
        return \AuthToken.userId
    }
}

extension AuthToken: Migration { }
extension AuthToken: Content { }
