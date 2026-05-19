import { QuizService } from '../service/QuizService'
import { ProgressService } from '../service/ProgressService'
import { FavoriteService } from '../service/FavoriteService'
import { VocabDbService } from '../service/VocabDbService'
import { Logger } from '../common/log/Logger'

export class HomeViewModel {
  hasUnfinishedSession: boolean = false
  totalVocabCount: number = 0
  masteredCount: number = 0
  learningCount: number = 0
  favoriteCount: number = 0

  async loadHomePageData(): Promise<void> {
    try {
      const quizService = QuizService.getInstance()
      const progressService = ProgressService.getInstance()
      const favoriteService = FavoriteService.getInstance()
      this.hasUnfinishedSession = await quizService.hasUnfinishedSession()
      const summary = await progressService.getProgressSummary()
      this.totalVocabCount = summary.totalVocabCount
      this.masteredCount = summary.masteredCount
      this.learningCount = summary.learningCount
      this.favoriteCount = await favoriteService.getFavoriteCount()
    } catch (err) {
      Logger.error(`Failed to loadHomePageData: ${JSON.stringify(err)}`)
      this.favoriteCount = 0
    }
  }
}
