//
//  UserController.swift
//  App
//
//  Created by Huu Tai Vuong on 11/19/18.
//

import Foundation
import Vapor

final class UserController {
    func profile(_ req: Request) throws -> Future<User> {
        return Future.map(on: req) { try req.requireAuthenticated(User.self) }
    }
    func update(_ req: Request) throws -> Future<User> {
        var user = try req.requireAuthenticated(User.self)
        return try req.content.decode(User.UpdateUserForm.self).flatMap { form in
            user.name = form.name ?? user.name
            user.email = form.email ?? user.email
            user.phone = form.phone ?? user.phone
            user.avatar = form.avatar ?? user.avatar
            user.location = form.location ?? user.location
            user.pushToken = form.pushToken ?? user.pushToken
            return user.save(on: req)
        }
    }
}
