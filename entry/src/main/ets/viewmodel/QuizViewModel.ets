import { QuizService, InsufficientVocabError } from '../service/QuizService'
import { ProgressService } from '../service/ProgressService'
import { FavoriteService } from '../service/FavoriteService'
import { QuizQuestion } from '../model/QuizQuestion'
import { AnswerResult } from '../model/StatsModels'
import { Logger } from '../common/log/Logger'
import { promptAction } from '@kit.ArkUI'

export class QuizViewModel {
  currentQuestion: QuizQuestion | null = null
  selectedOption: number = -1
  answerResult: AnswerResult | null = null
  isAnswered: boolean = false
  sessionAnsweredCount: number = 0
  sessionCorrectCount: number = 0
  allMastered: boolean = false
  isLoading: boolean = false
  errorMessage: string = ''
  isCurrentFavorite: boolean = false

  async loadNextQuestion(): Promise<void> {
    this.isLoading = true
    this.errorMessage = ''
    try {
      const quizService = QuizService.getInstance()
      this.currentQuestion = await quizService.generateQuestion()
      this.selectedOption = -1
      this.answerResult = null
      this.isAnswered = false

      const progressService = ProgressService.getInstance()
      const summary = await progressService.getProgressSummary()
      this.allMastered = summary.learningCount === 0 && summary.masteredCount > 0

      await this.refreshFavoriteStatus()
    } catch (err) {
      if (err instanceof InsufficientVocabError) {
        this.errorMessage = '词库数据不足，无法生成题目'
      } else {
        this.errorMessage = '生成题目失败，请重试'
      }
      Logger.error(`Failed to loadNextQuestion: ${JSON.stringify(err)}`)
    } finally {
      this.isLoading = false
    }
  }

  selectOption(optionIndex: number): void {
    if (!this.isAnswered) {
      this.selectedOption = optionIndex
    }
  }

  async submitAnswer(): Promise<void> {
    if (this.selectedOption < 0 || !this.currentQuestion || this.isAnswered) {
      return
    }
    try {
      const quizService = QuizService.getInstance()
      const progressService = ProgressService.getInstance()

      this.answerResult = quizService.judgeAnswer(this.currentQuestion, this.selectedOption)
      this.isAnswered = true

      await progressService.recordAnswer(this.currentQuestion.targetWord, this.answerResult.isCorrect)
      await progressService.saveAnswerRecord(
        this.currentQuestion.targetWord,
        this.selectedOption + 1,
        this.currentQuestion.correctOptionIndex + 1,
        this.answerResult.isCorrect
      )

      await quizService.updateSessionAfterAnswer(this.answerResult.isCorrect)
      const sessionProgress = quizService.getSessionProgress()
      this.sessionAnsweredCount = sessionProgress.answeredCount
      this.sessionCorrectCount = sessionProgress.correctCount
    } catch (err) {
      Logger.error(`Failed to submitAnswer: ${JSON.stringify(err)}`)
    }
  }

  async continueToNext(): Promise<void> {
    await this.loadNextQuestion()
  }

  async initSession(isResume: boolean): Promise<void> {
    try {
      const quizService = QuizService.getInstance()
      if (isResume) {
        const session = await quizService.resumeSession()
        if (session) {
          this.sessionAnsweredCount = session.answeredCount
          this.sessionCorrectCount = session.correctCount
        }
      } else {
        await quizService.startSession()
        this.sessionAnsweredCount = 0
        this.sessionCorrectCount = 0
      }
      await this.loadNextQuestion()
    } catch (err) {
      Logger.error(`Failed to initSession: ${JSON.stringify(err)}`)
    }
  }

  async finishSession(): Promise<void> {
    try {
      const quizService = QuizService.getInstance()
      await quizService.endSession()
    } catch (err) {
      Logger.error(`Failed to finishSession: ${JSON.stringify(err)}`)
    }
  }

  async toggleFavorite(): Promise<void> {
    if (!this.currentQuestion) {
      return
    }
    const previousStatus = this.isCurrentFavorite
    this.isCurrentFavorite = !this.isCurrentFavorite
    try {
      const favoriteService = FavoriteService.getInstance()
      if (previousStatus) {
        await favoriteService.removeFavorite(this.currentQuestion.targetWord)
        promptAction.showToast({ message: '已从生词本移除', duration: 1500 })
      } else {
        await favoriteService.addFavorite(this.currentQuestion.targetWord)
        promptAction.showToast({ message: '已添加到生词本', duration: 1500 })
      }
    } catch (err) {
      this.isCurrentFavorite = previousStatus
      promptAction.showToast({ message: '收藏操作失败，请稍后重试', duration: 1500 })
      Logger.error(`Failed to toggleFavorite: ${JSON.stringify(err)}`)
    }
  }

  async refreshFavoriteStatus(): Promise<void> {
    if (!this.currentQuestion) {
      this.isCurrentFavorite = false
      return
    }
    try {
      const favoriteService = FavoriteService.getInstance()
      this.isCurrentFavorite = await favoriteService.isFavorite(this.currentQuestion.targetWord)
    } catch (err) {
      this.isCurrentFavorite = false
      Logger.error(`Failed to refreshFavoriteStatus: ${JSON.stringify(err)}`)
    }
  }
}
