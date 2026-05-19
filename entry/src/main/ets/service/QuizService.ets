import { VocabDbService } from './VocabDbService'
import { ProgressService } from './ProgressService'
import { QuizQuestion, QuizOption } from '../model/QuizQuestion'
import { AnswerResult, TodayStats, SessionProgress } from '../model/StatsModels'
import { QuizSession } from '../model/QuizSession'
import { SessionStatus } from '../model/Enums'
import { AppConstants } from '../common/constants/AppConstants'
import { RandomUtil } from '../common/utils/RandomUtil'
import { Logger } from '../common/log/Logger'
import { preferences } from '@kit.ArkData'
import { MasteryStatus } from '../model/Enums'

export class InsufficientVocabError extends Error {
  constructor() {
    super('Insufficient vocabulary data, cannot generate question')
    this.name = 'InsufficientVocabError'
  }
}

export class QuizService {
  private static instance: QuizService | null = null
  private dbService: VocabDbService
  private progressService: ProgressService
  private currentSession: QuizSession | null = null
  private prefs: preferences.Preferences | null = null

  private constructor() {
    this.dbService = VocabDbService.getInstance()
    this.progressService = ProgressService.getInstance()
  }

  static getInstance(): QuizService {
    if (!QuizService.instance) {
      QuizService.instance = new QuizService()
    }
    return QuizService.instance
  }

  async initPreferences(context: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, 'quiz_prefs')
    } catch (err) {
      Logger.error(`Failed to init preferences: ${JSON.stringify(err)}`)
    }
  }

  async generateQuestion(): Promise<QuizQuestion> {
    try {
      const learningPool = await this.dbService.getVocabByStatus(MasteryStatus.LEARNING)
      let targetWord: string
      let correctMeaning: string
      let allMastered = false

      if (learningPool.length > 0) {
        const picked = RandomUtil.randomPick(learningPool, 1)
        targetWord = picked[0].word
        correctMeaning = picked[0].meaning
      } else {
        const masteredPool = await this.dbService.getVocabByStatus(MasteryStatus.MASTERED)
        if (masteredPool.length > 0) {
          const picked = RandomUtil.randomPick(masteredPool, 1)
          targetWord = picked[0].word
          correctMeaning = picked[0].meaning
          allMastered = true
        } else {
          throw new InsufficientVocabError()
        }
      }

      const allVocab = await this.dbService.getAllVocabItems()
      const distractors = allVocab.filter(v => v.word !== targetWord)
      if (distractors.length < AppConstants.OPTION_COUNT - 1) {
        throw new InsufficientVocabError()
      }

      const pickedDistractors = RandomUtil.randomPick(distractors, AppConstants.OPTION_COUNT - 1)
      const distractorMeanings = pickedDistractors.map(v => v.meaning)

      const allMeanings: string[] = [correctMeaning]
      for (const dm of distractorMeanings) {
        if (!allMeanings.includes(dm)) {
          allMeanings.push(dm)
        }
      }

      const shuffledMeanings = RandomUtil.shuffle(allMeanings)
      const correctOptionIndex = shuffledMeanings.indexOf(correctMeaning)
      const options: QuizOption[] = shuffledMeanings.map((meaning, index): QuizOption => ({
        index,
        meaning
      }))

      const question: QuizQuestion = {
        targetWord,
        correctMeaning,
        options,
        correctOptionIndex
      }
      question.options = options
      question.correctOptionIndex = correctOptionIndex
      return question
    } catch (err) {
      if (err instanceof InsufficientVocabError) {
        throw err
      }
      Logger.error(`Failed to generateQuestion: ${JSON.stringify(err)}`)
      throw new Error(`Failed to generateQuestion: ${JSON.stringify(err)}`)
    }
  }

  judgeAnswer(question: QuizQuestion, selectedOption: number): AnswerResult {
    const isCorrect = selectedOption === question.correctOptionIndex
    return {
      isCorrect,
      correctMeaning: question.correctMeaning
    }
  }

  async startSession(): Promise<void> {
    const sessionId = `${Date.now()}_${Math.random().toString(36).substring(2, 9)}`
    this.currentSession = {
      sessionId,
      startTime: Date.now(),
      endTime: null,
      status: SessionStatus.IN_PROGRESS,
      answeredCount: 0,
      correctCount: 0
    }
    await this.saveSessionToPrefs()
    Logger.info(`Session started: ${sessionId}`)
  }

  async endSession(): Promise<void> {
    if (this.currentSession) {
      this.currentSession.endTime = Date.now()
      this.currentSession.status = SessionStatus.COMPLETED
      await this.clearSessionFromPrefs()
      Logger.info(`Session ended: ${this.currentSession.sessionId}`)
      this.currentSession = null
    }
  }

  async resumeSession(): Promise<QuizSession | null> {
    if (!this.prefs) {
      return null
    }
    try {
      const sessionStr = await this.prefs.get(AppConstants.SESSION_KEY, '') as string
      if (sessionStr.length === 0) {
        return null
      }
      const session = JSON.parse(sessionStr) as QuizSession
      this.currentSession = session
      Logger.info(`Session resumed: ${session.sessionId}`)
      return session
    } catch (err) {
      Logger.error(`Failed to resumeSession: ${JSON.stringify(err)}`)
      return null
    }
  }

  async updateSessionAfterAnswer(isCorrect: boolean): Promise<void> {
    if (this.currentSession) {
      this.currentSession.answeredCount++
      if (isCorrect) {
        this.currentSession.correctCount++
      }
      await this.saveSessionToPrefs()
    }
  }

  async hasUnfinishedSession(): Promise<boolean> {
    if (!this.prefs) {
      return false
    }
    try {
      const sessionStr = await this.prefs.get(AppConstants.SESSION_KEY, '') as string
      return sessionStr.length > 0
    } catch (err) {
      return false
    }
  }

  getSessionProgress(): SessionProgress {
    if (this.currentSession) {
      return {
        answeredCount: this.currentSession.answeredCount,
        correctCount: this.currentSession.correctCount
      }
    }
    return { answeredCount: 0, correctCount: 0 }
  }

  async getTodayStats(): Promise<TodayStats> {
    const todayAnsweredCount = await this.progressService.getTodayAnsweredCount()
    const todayCorrectCount = await this.progressService.getTodayCorrectCount()
    const todayAccuracy = todayAnsweredCount > 0 ? Math.round((todayCorrectCount / todayAnsweredCount) * 100) : null
    return { todayAnsweredCount, todayAccuracy }
  }

  private async saveSessionToPrefs(): Promise<void> {
    if (this.prefs && this.currentSession) {
      try {
        await this.prefs.put(AppConstants.SESSION_KEY, JSON.stringify(this.currentSession))
        await this.prefs.flush()
      } catch (err) {
        Logger.error(`Failed to save session to prefs: ${JSON.stringify(err)}`)
      }
    }
  }

  private async clearSessionFromPrefs(): Promise<void> {
    if (this.prefs) {
      try {
        await this.prefs.delete(AppConstants.SESSION_KEY)
        await this.prefs.flush()
      } catch (err) {
        Logger.error(`Failed to clear session from prefs: ${JSON.stringify(err)}`)
      }
    }
  }
}
