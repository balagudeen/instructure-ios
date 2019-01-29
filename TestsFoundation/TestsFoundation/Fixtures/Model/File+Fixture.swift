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
@testable import Core

extension File: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "uuid": "uuid-1234",
            "folderID": "1",
            "displayName": "File",
            "filename": "File.jpg",
            "contentType": "image/jpeg",
            "url": URL(string: "https://canvas.instructure.com/files/1/download"),
            "size": 1024,
            "createdAt": Date(),
            "updatedAt": Date(),
            "locked": false,
            "hidden": false,
            "hiddenForUser": false,
            "mimeClass": "JPEG",
            "lockedForUser": false
        ]
    }
}
