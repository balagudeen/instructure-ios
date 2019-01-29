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

extension APIFile: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "uuid": "uuid-1234",
            "folder_id": "1",
            "display_name": "File",
            "filename": "File.jpg",
            "content-type": "image/jpeg",
            "url": "https://canvas.instructure.com/files/1/download",
            "size": 1024,
            "created_at": Date().isoString(),
            "updated_at": Date().isoString(),
            "modified_at": Date().isoString(),
            "locked": false,
            "hidden": false,
            "hidden_for_user": false,
            "mime_class": "JPEG",
            "locked_for_user": false
        ]
    }
}
