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

import XCTest
import Core
import TestsFoundation

class PersistenceTestCase: XCTestCase {
    var database: Persistence {
        return TestsFoundation.singleSharedTestDatabase
    }
    var databaseClient: PersistenceClient {
        return database.mainClient
    }

    var api = MockAPI()
    var backgroundAPI: MockAPI {
        return env.backgroundAPI as! MockAPI
    }
    var queue = OperationQueue()
    var router = TestRouter()
    var env = testEnvironment()
    var logger = TestLogger()

    override func setUp() {
        super.setUp()
        queue = OperationQueue()
        router = TestRouter()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        env = testEnvironment()
        env.api = api
        env.database = database
        env.globalDatabase = database
        env.router = router
        env.logger = logger
    }
}
