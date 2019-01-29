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

extension APIEnrollment: Fixture {
    public static var template: Template {
        return [
            "type": "student",
            "role": "StudentEnrollment",
            "role_id": "3",
            "user_id": "12",
            "enrollment_state": "active",
            "computed_current_score": 74.38,
            "computed_final_score": 49.03,
            "computed_current_grade": nil,
            "computed_final_grade": nil,
            "has_grading_periods": true,
            "multiple_grading_periods_enabled": true,
            "totals_for_all_grading_periods_option": true,
            "current_grading_period_title": "Forever",
            "current_grading_period_id": "1",
            "current_period_computed_current_score": 74.38,
            "current_period_computed_final_score": 49.03,
            "current_period_computed_current_grade": nil,
            "current_period_computed_final_grade": nil
        ]
    }
}
