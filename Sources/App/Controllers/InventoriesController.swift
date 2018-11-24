//
//  InventoriesController.swift
//  App
//
//  Created by Huu Tai Vuong on 11/19/18.
//

import Foundation
import FluentSQLite
import Vapor
import Fluent

struct DeleteInventoryResponse: Content {
    var error: Bool
    var message: String
}

final class InventoriesController {
    func create(_ req: Request) throws -> Future<Inventory> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Inventory.CreateInventoryForm.self).flatMap { form in
            guard let gameId = form.game_id else {
                throw Abort(.badRequest)
            }
            let newItem = Inventory(form: form, gameId: gameId, ownerId: try user.requireID())
            return newItem.save(on: req)
        }
    }
    
    func list(_ req: Request) throws -> Future<[String:[Inventory]]> {
        let user = try req.requireAuthenticated(User.self)
        return try user.inventories.query(on: req).all().map { items in
            return ["inventories": items]
        }
    }
    
    func update(_ req: Request) throws -> Future<Inventory> {
        let _ = try req.requireAuthenticated(User.self)
        let targetDiskId = try req.parameters.next(Int.self)
        return try req.content.decode(Inventory.CreateInventoryForm.self).flatMap { form in
            return Inventory.find(targetDiskId, on: req).flatMap { foundItem in
                guard var item = foundItem else {
                    throw Abort(.badRequest)
                }
                item.updated(from: form)
                return item.save(on: req)
            }
        }
    }
    
    func delete(_ req: Request) throws -> Future<DeleteInventoryResponse> {
        let user = try req.requireAuthenticated(User.self)
        let deletingId = try req.parameters.next(Int.self)
        return try user.inventories.query(on: req).filter(\.id == deletingId).first().flatMap { foundItem in
            guard let item = foundItem else {
                throw Abort(.badRequest)
            }
            return item.delete(on: req).map {
                return DeleteInventoryResponse(error: false, message: "User inventories has been updated")
            }
        }
    }
}
