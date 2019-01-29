//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData
import Core

public var singleSharedTestDatabase: Persistence  = resetSingleSharedTestDatabase()

public func resetSingleSharedTestDatabase() -> Persistence {
    let bundle = Bundle.core
    let modelURL = bundle.url(forResource: "Database", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    let container = NSPersistentContainer(name: "Database", managedObjectModel: model)
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    description.shouldAddStoreAsynchronously = false

    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { (description, error) in
        // Check if the data store is in memory
        precondition( description.type == NSInMemoryStoreType )

        // Check if creating container wrong
        if let error = error {
            fatalError("Create an in-memory coordinator failed \(error)")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    return container
}
