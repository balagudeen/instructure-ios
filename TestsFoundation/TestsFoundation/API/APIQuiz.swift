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

// https://canvas.instructure.com/doc/api/quiz_questions.html#QuizQuestion
public struct APIQuizQuestion: Codable {
    public let id: String
    public let quiz_id: String
    public let position: Int?
    public let question_name: String
    public let question_type: QuizQuestionType
    public let question_text: String
    public let points_possible: Int
    public let correct_comments: String
    public let incorrect_comments: String
    public let neutral_comments: String
    // public let answers: [APIQuizAnswer]?
}

// https://canvas.instructure.com/doc/api/quiz_submissions.html#QuizSubmission
public struct APIQuizSubmission: Codable {
    let id: String
    let quiz_id: String
    let user_id: String
    let submission_id: String
    let started_at: Date
    let finished_at: Date?
    let end_at: Date?
    let attempt: UInt
    // let extra_attempts: UInt?
    // let extra_time: Int? // minutes
    // let manually_unlocked: Bool?
    // let time_spent: TimeInterval
    // let score: Double?
    // let score_before_regrade: Double?
    // let kept_score: Double?
    // let fudge_points: Double?
    // let has_seen_results: Bool
    // workflow_state: QuizSubmissionWorkflowState // untaken, pending_review, complete, settings_only, preview
    // let overdue_and_needs_submission: Bool?
    let validation_token: String
}

// https://canvas.instructure.com/doc/api/quiz_submission_questions.html#QuizSubmissionQuestion
public struct APIQuizSubmissionQuestion: Codable {
    public let id: String
    public let flagged: Bool
    public let answer: APIQuizAnswerValue?
    // public let answers: [APIQuizAnswer]?
}

// https://canvas.instructure.com/doc/api/quiz_submission_questions.html#Question+Answer+Formats-appendix
public enum APIQuizAnswerValue: Codable {
    case double(Double)
    case string(String)
    case hash([String: String])
    case list([String])
    case matching([[String: String]])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: String].self) {
            self = .hash(value)
        } else if let value = try? container.decode([String].self) {
            self = .list(value)
        } else {
            self = .matching(try container.decode([[String: String]].self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .hash(let value):
            try container.encode(value)
        case .list(let value):
            try container.encode(value)
        case .matching(let value):
            try container.encode(value)
        }
    }
}
