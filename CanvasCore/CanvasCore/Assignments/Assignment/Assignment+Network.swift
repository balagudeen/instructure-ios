//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import ReactiveSwift

import Marshal

extension Assignment {
    static func getAssignments(_ session: Session, courseID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AssignmentAPI.getAssignments(session, courseID: courseID)

        return session.paginatedJSONSignalProducer(request)
    }

    static func getAssignment(_ session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AssignmentAPI.getAssignment(session, courseID: courseID, assignmentID: assignmentID)

        return session.JSONSignalProducer(request)
    }

    @objc public var submissionsPath: String {
         return "/api/v1/courses/\(courseID)/assignments/\(id)/submissions/self/files"
    }
}
