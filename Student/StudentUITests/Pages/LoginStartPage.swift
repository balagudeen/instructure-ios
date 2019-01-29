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

import Core

enum LoginStartPage: String, UITestElement, CaseIterable {
    case authenticationMethodLabel
    case canvasNetworkButton
    case findSchoolButton
    case helpButton
    case logoView
    case whatsNewLabel
    case whatsNewLink
}

struct LoginPreviousUserItem: RawRepresentable, UITestElement {
    let rawValue: String

    static func item(entry: KeychainEntry) -> LoginPreviousUserItem {
        return LoginPreviousUserItem(rawValue: "\(entry.baseURL.host ?? "").\(entry.userID)")
    }

    static func removeButton(entry: KeychainEntry) -> LoginPreviousUserItem {
        return LoginPreviousUserItem(rawValue: "\(entry.baseURL.host ?? "").\(entry.userID).removeButton")
    }
}
