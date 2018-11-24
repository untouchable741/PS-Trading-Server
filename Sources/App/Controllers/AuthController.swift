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
import S3
import Crypto

struct FacebookResponse: Content {
    var email: String
    var name: String
    var id: String
    var avatar: String?
}

struct LoginResponse: Content {
    var token: String
    var profile: User
}

final class AuthController {
    func login(_ req: Request) throws -> Future<LoginResponse> {
        return try fetchFacebookProfile(on: req)
                    .flatMap { try self.createUser(for: $0, on: req) }
                    .flatMap { try self.createAuthToken(for: $0, on: req)
                        .map { LoginResponse(token: $0.0.token, profile: $0.1) }
        }
    }
}


//MAKR - Helpers
extension AuthController {
    func createAuthToken(for user: User, on req: Request) throws -> Future<(AuthToken, User)> {
        return try user.authTokens.query(on: req).first().flatMap { existingToken in
            if let token = existingToken {
                return Future.map(on: req) { (token, user) }
            } else {
                let tokenString = try URandom().generateData(count: 32).base64URLEncodedString()
                let authToken = AuthToken(token: tokenString, userId: try user.requireID())
                return authToken.save(on: req).map { ($0, user) }
            }
        }
    }
    
    func createUser(for fbResponse: FacebookResponse, on req: Request) throws -> Future<User> {
        return User.query(on: req).filter(\.facebookId == fbResponse.id).first().flatMap {
            existingUser in
            if let user = existingUser {
                return Future.map(on: req) { user }
            } else {
                let newUser = User(facebookId: fbResponse.id,
                                   email: fbResponse.email,
                                   name: fbResponse.name,
                                   avatar: fbResponse.avatar)
                return newUser.save(on: req)
            }
        }
    }
    
    func fetchFacebookProfile(on req: Request) throws -> Future<FacebookResponse> {
        guard let facebookToken = try? req.content.syncGet(String.self, at: ["facebook_token"]) else {
            throw Abort(.badRequest)
        }
        var urlComponents = URLComponents(string: "https://graph.facebook.com/me")
        urlComponents?.queryItems = [
            URLQueryItem(name: "fields", value: "email,name"),
            URLQueryItem(name: "access_token", value: facebookToken),
        ]
        
        return try req.client().get((urlComponents?.url)!, headers: [:]).flatMap { response in
            guard response.http.status == .ok else {
                throw Abort(.badRequest)
            }
            
            return try response.content.decode(FacebookResponse.self).flatMap { fbResponse in
                var urlComponents = URLComponents(string: "https://graph.facebook.com/\(fbResponse.id)/picture")
                urlComponents?.queryItems = [
                    URLQueryItem(name: "height", value: "300"),
                    URLQueryItem(name: "width", value: "300"),
                    URLQueryItem(name: "access_token", value: facebookToken),
                ]
                return try req.client().get((urlComponents?.url)!, headers: [:]).flatMap { response in
                    let imagePathUrl = URL(fileURLWithPath: "\(DirectoryConfig.detect().workDir)\(fbResponse.id).jpg")
                    return response.http.body.consumeData(on: req).flatMap { data in
                        try data.write(to: imagePathUrl)
                        let s3 = try req.makeS3Client()
                        let avatarPath = "avatars/\(fbResponse.id).jpg"
                        return try s3.put(file: imagePathUrl,
                                   destination: avatarPath,
                                        access: .publicRead,
                                            on: req).map { response in
                            try FileManager.default.removeItem(at: imagePathUrl)
                            var newFbResponse = fbResponse
                            newFbResponse.avatar = Environment.get("s3_avatars_base_url")! + avatarPath
                            return newFbResponse
                        }
                    }
                }
            }
        }
    }
}
