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

class GetUserGroupsTest: CoreTestCase {
    func testItSavesUserGroups() {
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        let group = APIGroup.make(["id": "1", "name": "Group One", "members_count": 2])
        api.mock(request, value: [group])

        let getUserGroups = GetUserGroups(env: environment)
        addOperationAndWait(getUserGroups)

        let groups: [Group] = databaseClient.fetch()
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, "1")
        XCTAssertEqual(groups.first?.showOnDashboard, true)
    }

    func testItDeletesOldUserGroups() {
        let old = Group.make(["showOnDashboard": true])
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        api.mock(request, value: [])

        let getUserGroups = GetUserGroups(env: environment)
        addOperationAndWait(getUserGroups)

        databaseClient.refresh()
        let groups: [Group] = databaseClient.fetch()
        XCTAssertFalse(groups.contains(old))
    }

    func testItDoesNotDeleteNonUserGroups() {
        let notMember = Group.make(["showOnDashboard": false])
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        api.mock(request, value: [])

        let getUserGroups = GetUserGroups(env: environment)
        addOperationAndWait(getUserGroups)

        let groups: [Group] = databaseClient.fetch()
        XCTAssert(groups.contains(notMember))
    }
}
