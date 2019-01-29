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

class GetContextTabsTest: CoreTestCase {

    let context = ContextModel(.group, id: "1")
    lazy var request: GetTabsRequest = { [weak self] in
        return GetTabsRequest(context: self!.context)
    }()

    func testItCreatesTabs() {
        let groupTab = APITab.make(["html_url": "https://twilson.instructure.com/groups/16"])
        api.mock(request, value: [groupTab], response: nil, error: nil)

        let getContextTabs = GetContextTabs(context: context, env: environment)
        addOperationAndWait(getContextTabs)

        let tabs: [Tab] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(tabs.count, 1)
        XCTAssertEqual(tabs.first?.label, "Home")
        XCTAssertEqual(tabs.first?.htmlURL.absoluteString, "https://twilson.instructure.com/groups/16")
    }

    func testItCreatesTabsMultipleRequests() {
        let context1 = ContextModel(.group, id: Group.make(["id": "1"]).id)
        let context2 = ContextModel(.group, id: Group.make(["id": "2"]).id)

        let groupTab1 = APITab.make(["id": "home", "html_url": "https://twilson.instructure.com/groups/1"])
        let groupTab2 = APITab.make(["id": "assignments", "html_url": "https://twilson.instructure.com/groups/2"])

        let req1 = GetTabsRequest(context: context1)
        api.mock(req1, value: [groupTab1], response: nil, error: nil)

        let getContextTabs1 = GetContextTabs(context: context1, env: environment)
        addOperationAndWait(getContextTabs1)

        let req2 = GetTabsRequest(context: context2)
        api.mock(req2, value: [groupTab2], response: nil, error: nil)

        let getContextTabs2 = GetContextTabs(context: context2, env: environment)
        addOperationAndWait(getContextTabs2)

        XCTAssert(getContextTabs1.errors.isEmpty)
        XCTAssert(getContextTabs2.errors.isEmpty)

        let tabs: [Tab] = databaseClient.fetch()
        let home = tabs.filter { $0.id == "home" }.first
        let assignments = tabs.filter { $0.id == "assignments" }.first
        XCTAssertEqual(tabs.count, 2)
        XCTAssertEqual(home?.htmlURL.absoluteString, "https://twilson.instructure.com/groups/1")
        XCTAssertEqual(assignments?.htmlURL.absoluteString, "https://twilson.instructure.com/groups/2")
    }

    func testItDeletesTabsThatNoLongerExist() {
        let tab = Tab.make(["contextRaw": context.canvasContextID])
        api.mock(request, value: [], response: nil, error: nil)

        let getContextTabs = GetContextTabs(context: context, env: environment)
        addOperationAndWait(getContextTabs)

        let tabs: [Tab] = databaseClient.fetch()
        XCTAssertFalse(tabs.contains(tab))
    }
}
