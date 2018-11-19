//
//  AuthController.swift
//  App
//
//  Created by Huu Tai Vuong on 11/19/18.
//

import Foundation
import Vapor
import FluentSQLite
import Random

struct FacebookResponse: Content {
    var email: String
    var name: String
    var id: String
}

final class AuthController {
    func register(_ req: Request) throws -> Future<AuthToken> {
        return req.content.get(String.self, at: ["facebook_token"]).flatMap { facebookToken in
            var urlComponents = URLComponents(string: "https://graph.facebook.com/me")
            urlComponents?.queryItems = [
                URLQueryItem(name: "fields", value: "email,name"),
                URLQueryItem(name: "access_token", value: facebookToken),
            ]
            return try req.client().get((urlComponents?.url)!, headers: [:]).flatMap { response in
                guard response.http.status == .ok else {
                    throw Abort(.badRequest)
                }
                return try response.content.decode(FacebookResponse.self).flatMap { response in
                    return try self.createUser(for: response, on: req)
                }
            }.flatMap { user in
                return try self.createAuthToken(for: user, on: req)
            }
        }
    }
}


//MAKR - Helpers
extension AuthController {
    func createAuthToken(for user: User, on req: Request) throws -> Future<AuthToken> {
        return try user.authTokens.query(on: req).first().flatMap { existingToken in
            if let token = existingToken {
                return Future.map(on: req) { token }
            } else {
                let tokenString = try URandom().generateData(count: 32).base64URLEncodedString()
                let authToken = AuthToken(token: tokenString, userId: try user.requireID())
                return authToken.save(on: req)
            }
        }
    }
    
    func createUser(for fbResponse: FacebookResponse, on req: Request) throws -> Future<User> {
        return User.query(on: req).filter(\.facebookId == fbResponse.id).first().flatMap {
            existingUser in
            if let user = existingUser {
                return Future.map(on: req) { user }
            } else {
                let newUser = User(facebookId: fbResponse.id, email: fbResponse.email, name: fbResponse.name)
                return newUser.save(on: req)
            }
        }
    }
}
