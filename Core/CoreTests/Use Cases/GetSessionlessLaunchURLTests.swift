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
@testable import Core

class GetSessionlessLaunchURLTests: CoreTestCase {

    func testGetSessionlessLaunchURL() {
        let context = ContextModel(.course, id: "1")
        let request = GetSessionlessLaunchURLRequest(context: context, id: "2", url: URL(string: "https://google.com")!, assignmentID: "3", moduleItemID: nil, launchType: .assessment)
        let responseBody = APIGetSessionlessLaunchResponse(id: "2", name: "An external tool", url: URL(string: "https://instructure.com")!)
        api.mock(request, value: responseBody, response: nil, error: nil)

        let getSessionlessLaunchURL = GetSessionlessLaunchURL(
            api: api,
            context: context,
            id: "2",
            url: URL(string: "https://google.com")!,
            launchType: .assessment,
            assignmentID: "3",
            moduleItemID: nil
        )
        addOperationAndWait(getSessionlessLaunchURL)

        XCTAssertEqual(getSessionlessLaunchURL.response, responseBody)
    }

}
