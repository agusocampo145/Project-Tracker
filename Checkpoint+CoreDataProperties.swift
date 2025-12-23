//
//  Checkpoint+CoreDataProperties.swift
//  Project Tracker
//
//  Created by hogar on 23/12/2025.
//
//

import Foundation
import CoreData


extension Checkpoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Checkpoint> {
        return NSFetchRequest<Checkpoint>(entityName: "Checkpoint")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var isDone: Bool
    @NSManaged public var order: Int16
    @NSManaged public var details: String?
    @NSManaged public var project: Project?

}

extension Checkpoint : Identifiable {

}
