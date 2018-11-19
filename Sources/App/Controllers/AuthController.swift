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

struct RegisterForm: Content {
    var facebook_token: String
}

struct FacebookLoginResult: Content {
    var email: String
    var name: String
    var id: String
}

final class AuthController {
    func register(_ req: Request) throws -> Future<AuthToken> {
        return try req.content.decode(RegisterForm.self).flatMap { form in
            var urlComponents = URLComponents(string: "https://graph.facebook.com/me")
            urlComponents?.queryItems = [
                URLQueryItem(name: "fields", value: "email,name"),
                URLQueryItem(name: "access_token", value: form.facebook_token),
            ]
            return try req.client().get((urlComponents?.url)!, headers: [:]).flatMap { response in
                guard response.http.status == .ok else {
                    throw Abort(.badRequest)
                }
                return try response.content.decode(FacebookLoginResult.self).flatMap { result in
                    return try self.createUser(for: result, on: req)
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
    
    func createUser(for fbResult: FacebookLoginResult, on req: Request) throws -> Future<User> {
        return User.query(on: req).filter(\.facebookId == fbResult.id).first().flatMap {
            existingUser in
            if let user = existingUser {
                return Future.map(on: req) { user }
            } else {
                let newUser = User(facebookId: fbResult.id, email: fbResult.email, name: fbResult.name)
                return newUser.save(on: req)
            }
        }
    }
}
