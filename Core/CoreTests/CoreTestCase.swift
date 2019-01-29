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
import XCTest
@testable import Core
import TestsFoundation

class CoreTestCase: XCTestCase {
    var database: Persistence {
        return TestsFoundation.singleSharedTestDatabase
    }
    var databaseClient: PersistenceClient {
        return database.mainClient
    }
    var api = MockAPI()
    var backgroundAPI: MockAPI {
        return environment.backgroundAPI as! MockAPI
    }
    var queue = OperationQueue()
    var router = TestRouter()
    var logger = TestLogger()
    var environment: AppEnvironment!

    let notificationCenter = MockUserNotificationCenter()
    var notificationManager: NotificationManager!

    lazy var testFile: URL = {
        let bundle = Bundle(for: type(of: self))
        return bundle.url(forResource: "fileupload", withExtension: "txt")!
    }()

    override func setUp() {
        super.setUp()
        api = MockAPI()
        router = TestRouter()
        logger = TestLogger()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        environment = AppEnvironment.shared
        environment.api = api
        environment.backgroundAPIManager = MockBackgroundURLSessionManager(database: database)
        environment.globalDatabase = database
        environment.database = database
        queue = environment.queue
        environment.queue.maxConcurrentOperationCount = 1
        environment.router = router
        environment.logger = logger
        notificationManager = NotificationManager(notificationCenter: notificationCenter, logger: logger)
    }

    func addOperationAndWait(_ operation: Operation) {
        queue.addOperations([operation], waitUntilFinished: true)
    }
}
