//: Playground - noun: a place where people can play

import UIKit
import CoreData

let request = NSFetchRequest(entityName: "Person")
request.relationshipKeyPathsForPrefetching = ["addresses", "addresses.postalCode"]
request.resultType = .ManagedObjectIDResultType
request.includesPropertyValues = false

class Example: NSEntityMigrationPolicy {

    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject,
        entityMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws

    override func createRelationshipsForDestinationInstance(dInstance: NSManagedObject,
        entityMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws
}