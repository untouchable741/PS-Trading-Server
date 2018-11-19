//
//  DiskController.swift
//  App
//
//  Created by Huu Tai Vuong on 11/19/18.
//

import Foundation
import FluentSQLite
import Vapor
import Fluent

struct DeleteDiskResponse: Content {
    var error: Bool
    var message: String
}

final class DiskController {
    func create(_ req: Request) throws -> Future<Disk> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Disk.CreateDiskForm.self).flatMap { diskForm in
            let newDisk = Disk(name: diskForm.name, poster: diskForm.poster, price: diskForm.price, location: diskForm.location, description: diskForm.description, contact: try user.requireID())
            return newDisk.save(on: req)
        }
    }
    
    func list(_ req: Request) throws -> Future<[String:[Disk]]> {
        let user = try req.requireAuthenticated(User.self)
        return try user.disks.query(on: req).all().map { disks in
            return ["disks": disks]
        }
    }
    
    func update(_ req: Request) throws -> Future<Disk> {
        let _ = try req.requireAuthenticated(User.self)
        let targetDiskId = try req.parameters.next(Int.self)
        return try req.content.decode(Disk.UpdateDiskForm.self).flatMap { diskForm in
            return Disk.find(targetDiskId, on: req).flatMap { existingDisk in
                guard var disk = existingDisk else {
                    throw Abort(.badRequest)
                }
                disk.name = diskForm.name ?? disk.name
                disk.price = diskForm.price ?? disk.price
                disk.location = diskForm.location ?? disk.location
                disk.description = diskForm.description ?? disk.description
                return disk.save(on: req)
            }
        }
    }
    
    func delete(_ req: Request) throws -> Future<DeleteDiskResponse> {
        let user = try req.requireAuthenticated(User.self)
        let targetDiskId = try req.parameters.next(Int.self)
        return try user.disks.query(on: req).filter(\.id == targetDiskId).first().flatMap { existingDisk in
            guard let disk = existingDisk else {
                throw Abort(.badRequest)
            }
            
            return disk.delete(on: req).map {
                return DeleteDiskResponse(error: false, message: "Disk has been deleted successfully")
            }
        }
    }
}
