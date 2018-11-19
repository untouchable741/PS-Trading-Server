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
}
