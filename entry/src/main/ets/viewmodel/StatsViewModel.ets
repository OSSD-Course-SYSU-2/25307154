import { ProgressService } from '../service/ProgressService'
import { QuizService } from '../service/QuizService'
import { Logger } from '../common/log/Logger'

export class StatsViewModel {
  totalVocabCount: number = 0
  masteredCount: number = 0
  learningCount: number = 0
  overallAccuracy: number | null = null
  todayAnsweredCount: number = 0
  todayAccuracy: number | null = null
  hasNoData: boolean = true

  async loadStats(): Promise<void> {
    try {
      const progressService = ProgressService.getInstance()
      const quizService = QuizService.getInstance()

      const summary = await progressService.getProgressSummary()
      this.totalVocabCount = summary.totalVocabCount
      this.masteredCount = summary.masteredCount
      this.learningCount = summary.learningCount
      this.overallAccuracy = summary.overallAccuracy

      const todayStats = await quizService.getTodayStats()
      this.todayAnsweredCount = todayStats.todayAnsweredCount
      this.todayAccuracy = todayStats.todayAccuracy

      this.hasNoData = this.overallAccuracy === null
    } catch (err) {
      Logger.error(`Failed to loadStats: ${JSON.stringify(err)}`)
      this.hasNoData = true
    }
  }
}
