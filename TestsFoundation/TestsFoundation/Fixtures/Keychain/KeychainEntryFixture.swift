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

extension KeychainEntry {
    public static func make(
        accessToken: String = "token",
        baseURL: URL = URL(string: "https://canvas.instructure.com")!,
        expiresAt: Date? = nil,
        lastUsedAt: Date = Date(),
        locale: String? = "en",
        masquerader: URL? = nil,
        refreshToken: String? = nil,
        userAvatarURL: URL? = nil,
        userID: String = "1",
        userName: String = "Eve"
    ) -> KeychainEntry {
        return KeychainEntry(
            accessToken: accessToken,
            baseURL: baseURL,
            expiresAt: expiresAt,
            lastUsedAt: lastUsedAt,
            locale: locale,
            masquerader: masquerader,
            refreshToken: refreshToken,
            userAvatarURL: userAvatarURL,
            userID: userID,
            userName: userName
        )
    }
}
