//
//  Disk.swift
//  App
//
//  Created by Huu Tai Vuong on 11/19/18.
//

import Foundation
import Vapor
import FluentSQLite

struct Disk: SQLiteModel {
    var id: Int?
    var name: String
    var poster: String
    var price: Double
    var location: String
    var description: String
    var contactId: User.ID
    
    struct UpdateDiskForm: Content {
        var name: String?
        var price: Double?
        var location: String?
        var description: String?
    }
    
    struct CreateDiskForm: Content {
        var name: String
        var poster: String
        var price: Double
        var location: String
        var description: String
    }
    
    init(name: String, poster: String, price: Double, location: String, description: String, contact: User.ID) {
        self.name = name
        self.poster = poster
        self.price = price
        self.location = location
        self.description = description
        self.contactId = contact
    }
}

extension Disk: Migration { }
extension Disk: Content { }
