//
//  Project+CoreDataProperties.swift
//  Project Tracker
//
//  Created by hogar on 23/12/2025.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var checkpoints: NSSet?

}

// MARK: Generated accessors for checkpoints
extension Project {

    @objc(addCheckpointsObject:)
    @NSManaged public func addToCheckpoints(_ value: Checkpoint)

    @objc(removeCheckpointsObject:)
    @NSManaged public func removeFromCheckpoints(_ value: Checkpoint)

    @objc(addCheckpoints:)
    @NSManaged public func addToCheckpoints(_ values: NSSet)

    @objc(removeCheckpoints:)
    @NSManaged public func removeFromCheckpoints(_ values: NSSet)

}

extension Project : Identifiable {

}
