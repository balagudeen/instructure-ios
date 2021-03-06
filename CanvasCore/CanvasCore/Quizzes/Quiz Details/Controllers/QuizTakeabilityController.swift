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
    
    

import Foundation

import Result

class QuizTakeabilityController {
    
    let quiz: Quiz
    let service: QuizService
    lazy var quizController: QuizController = {
        return QuizController(service: self.service, quiz: self.quiz)
    }()
    
    fileprivate (set) var attempts: Int = 0 // NOTE: right now this is broken due to an api bug that is being worked on, so don't rely on this
    
    /// This is the list of question types that is supported natively. 
    /// This will change as we add support for more question types.
    fileprivate var nativelySupportedQuestionTypes: [Question.Kind] {
        return [ .TrueFalse, .MultipleChoice, .MultipleAnswers, .Matching, .Essay, .ShortAnswer, .TextOnly, .Numerical, .FileUpload, .MultipleDropdowns ]
    }
    
    init(quiz: Quiz, service: QuizService) {
        self.quiz = quiz
        self.service = service
        
        refreshTakeability()
    }
    
    var takeabilityUpdated: (QuizTakeabilityController)->() = {_ in } {
        didSet {
            takeabilityUpdated(self)
        }
    }
    
    fileprivate (set) var takeability: Takeability = .notTakeable(reason: .undecided) {
        didSet {
            takeabilityUpdated(self)
        }
    }
    
    fileprivate func updateTakeability(_ submissions: [QuizSubmission]) {
        let sortedSubmissions = submissions.sorted(by: { $0.attempt < $1.attempt })
        if quiz.lockedForUser {
            if let url = sortedSubmissions.last.flatMap({ self.quizController.urlForViewingResultsForAttempt($0.attempt) }) {
                takeability = .viewResults(url)
                return
            }
            takeability = .notTakeable(reason: .locked)
            return
        }
        // TODO: passcode
        
        attempts = submissions.count
        if submissions.count == 0 && !quiz.lockedForUser {
            takeability = .take
            return
        } else {
            let sortedSubmissions = submissions.sorted(by: { $0.attempt < $1.attempt })
            if let lastSubmission = sortedSubmissions.last {
                switch quiz.attemptLimit {
                case .count(let limit):
                    if lastSubmission.attempt >= limit && lastSubmission.workflowState != .Untaken && lastSubmission.attemptsLeft == 0 {
                        if let url = quizController.urlForViewingResultsForAttempt(lastSubmission.attempt) {
                            takeability = .viewResults(url)
                            return
                        }
                        takeability = .notTakeable(reason: .attemptLimitReached)
                        return
                    }
                default:
                    break
                }
                
                if lastSubmission.workflowState == .Untaken && !quiz.lockedForUser {
                    if(quiz.timed) {
                        let timedQuizSubmissionService = self.service.serviceForTimedQuizSubmission(lastSubmission)
                        timedQuizSubmissionService.getTimeRemaining { [weak self] result in
                            if let secondsLeft = result.value {
                                if (secondsLeft > 0 && lastSubmission.dateFinished == nil) {
                                    self?.takeability = .resume
                                    self?.unfinishedSubmission = lastSubmission
                                    return
                                } else {
                                    // This is the horrible hack where because the API never updated the workflow state, we have to manually complete the quiz before
                                    // we can start another one
                                    self?.takeability = .notTakeable(reason: .undecided)
                                    self?.service.completeSubmission(lastSubmission) { [weak self] result in
                                        if result.error != nil {
                                            self?.takeability = .retake
                                        }
                                    }
                                    return
                                }
                            }
                        }
                    } else if (lastSubmission.endAt.flatMap { $0 > Date() } ?? true)  {
                        takeability = .resume
                        unfinishedSubmission = lastSubmission
                        return
                    }
                }
            }
            
            if quiz.lockedForUser {
                takeability = .notTakeable(reason: .locked)
            } else {
                takeability = .retake
            }
        }
    }
    
    func refreshTakeability() {
        service.getSubmissions() { [weak self] result in
            switch result {
            case .success(let submissionPage):
                self?.updateTakeability(submissionPage.content)
            case .failure(let error):
                print("error getting the submissions \(error)")
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
                    self?.takeability = .notTakeable(reason: .offline)
                }
            }
        }
    }
    
    func takeableNatively() -> Bool {
        return takeability.takeable && quizQuestionsSupportedNatively(quiz) && !quiz.oneQuestionAtATime && !quiz.hasAccessCode && (quiz.ipFilter == nil) && !quiz.requiresLockdownBrowser
    }
    
    func takeableInWebView() -> Bool {
        return takeability.takeable && !takeableNatively()
    }
    
    fileprivate func quizQuestionsSupportedNatively(_ quiz: Quiz) -> Bool {
        if quiz.questionTypes.count == 0 {
            return false
        }
        
        for questionType in quiz.questionTypes {
            if !nativelySupportedQuestionTypes.contains(questionType) {
                return false
            }
        }
        
        return true
    }
    
    
    
    // MARK: taking a quiz
    fileprivate var unfinishedSubmission: QuizSubmission? = nil

    func submissionControllerForTakingQuiz(_ quiz: Quiz) -> SubmissionController {
        return SubmissionController(service: service, submission: unfinishedSubmission, quiz: quiz)
    }
}
