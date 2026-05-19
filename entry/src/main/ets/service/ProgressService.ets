import { VocabDbService } from './VocabDbService'
import { VocabItem } from '../model/VocabItem'
import { MasteryStatus } from '../model/Enums'
import { AppConstants } from '../common/constants/AppConstants'
import { DbConstants } from '../common/constants/DbConstants'
import { ProgressSummary } from '../model/StatsModels'
import { Logger } from '../common/log/Logger'
import { relationalStore } from '@kit.ArkData'

export class ProgressService {
  private static instance: ProgressService | null = null
  private dbService: VocabDbService

  private constructor() {
    this.dbService = VocabDbService.getInstance()
  }

  static getInstance(): ProgressService {
    if (!ProgressService.instance) {
      ProgressService.instance = new ProgressService()
    }
    return ProgressService.instance
  }

  async recordAnswer(word: string, isCorrect: boolean): Promise<void> {
    try {
      const item = await this.dbService.getVocabByWord(word)
      if (!item) {
        Logger.error(`Word not found: ${word}`)
        return
      }
      if (isCorrect) {
        item.correctCount++
        item.consecutiveCorrectCount++
      } else {
        item.wrongCount++
        item.consecutiveCorrectCount = 0
      }
      if (item.consecutiveCorrectCount >= AppConstants.MASTERY_THRESHOLD) {
        item.masteryStatus = MasteryStatus.MASTERED
      } else {
        item.masteryStatus = MasteryStatus.LEARNING
      }
      await this.dbService.updateVocabProgress(item)
    } catch (err) {
      Logger.error(`Failed to recordAnswer: ${JSON.stringify(err)}`)
      throw new Error(`Failed to recordAnswer: ${JSON.stringify(err)}`)
    }
  }

  async getMasteryStatus(word: string): Promise<MasteryStatus> {
    const item = await this.dbService.getVocabByWord(word)
    return item ? item.masteryStatus : MasteryStatus.LEARNING
  }

  async getProgressSummary(): Promise<ProgressSummary> {
    try {
      const allItems = await this.dbService.getAllVocabItems()
      const totalVocabCount = allItems.length
      const masteredCount = allItems.filter(item => item.masteryStatus === MasteryStatus.MASTERED).length
      const learningCount = totalVocabCount - masteredCount
      const totalCorrect = allItems.reduce((sum, item) => sum + item.correctCount, 0)
      const totalWrong = allItems.reduce((sum, item) => sum + item.wrongCount, 0)
      const totalAnswers = totalCorrect + totalWrong
      const overallAccuracy = totalAnswers > 0 ? Math.round((totalCorrect / totalAnswers) * 100) : null
      return { totalVocabCount, masteredCount, learningCount, overallAccuracy }
    } catch (err) {
      Logger.error(`Failed to getProgressSummary: ${JSON.stringify(err)}`)
      return { totalVocabCount: 0, masteredCount: 0, learningCount: 0, overallAccuracy: null }
    }
  }

  async getVocabListByStatus(status: MasteryStatus): Promise<VocabItem[]> {
    return await this.dbService.getVocabByStatus(status)
  }

  async getAllProgress(): Promise<VocabItem[]> {
    return await this.dbService.getAllVocabItems()
  }

  async searchVocab(keyword: string, status: MasteryStatus | 'ALL'): Promise<VocabItem[]> {
    try {
      let items: VocabItem[]
      if (status === 'ALL') {
        items = await this.dbService.getAllVocabItems()
      } else {
        items = await this.dbService.getVocabByStatus(status as MasteryStatus)
      }
      if (keyword.length === 0) {
        return items
      }
      const lowerKeyword = keyword.toLowerCase()
      return items.filter(item => item.word.toLowerCase().startsWith(lowerKeyword))
    } catch (err) {
      Logger.error(`Failed to searchVocab: ${JSON.stringify(err)}`)
      return []
    }
  }

  async resetProgress(): Promise<void> {
    try {
      const allItems = await this.dbService.getAllVocabItems()
      for (const item of allItems) {
        item.correctCount = 0
        item.wrongCount = 0
        item.consecutiveCorrectCount = 0
        item.masteryStatus = MasteryStatus.LEARNING
        await this.dbService.updateVocabProgress(item)
      }
      Logger.info('All progress reset')
    } catch (err) {
      Logger.error(`Failed to resetProgress: ${JSON.stringify(err)}`)
      throw new Error(`Failed to resetProgress: ${JSON.stringify(err)}`)
    }
  }

  async saveAnswerRecord(targetWord: string, selectedOption: number, correctOption: number, isCorrect: boolean): Promise<void> {
    const rdbStore = this.dbService.getRdbStore()
    if (!rdbStore) {
      return
    }
    try {
      const bucket: relationalStore.ValuesBucket = {}
      bucket[DbConstants.ANSWER_COL_TARGET_WORD] = targetWord
      bucket[DbConstants.ANSWER_COL_SELECTED_OPTION] = selectedOption
      bucket[DbConstants.ANSWER_COL_CORRECT_OPTION] = correctOption
      bucket[DbConstants.ANSWER_COL_IS_CORRECT] = isCorrect ? 1 : 0
      bucket[DbConstants.ANSWER_COL_ANSWER_TIME] = Date.now()
      await rdbStore.insert(DbConstants.ANSWER_TABLE, bucket)
    } catch (err) {
      Logger.error(`Failed to saveAnswerRecord: ${JSON.stringify(err)}`)
      throw new Error(`Failed to saveAnswerRecord: ${JSON.stringify(err)}`)
    }
  }

  async getTodayAnsweredCount(): Promise<number> {
    const rdbStore = this.dbService.getRdbStore()
    if (!rdbStore) {
      return 0
    }
    try {
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const startOfDay = today.getTime()
      const predicates = new relationalStore.RdbPredicates(DbConstants.ANSWER_TABLE)
      predicates.greaterThanOrEqualTo(DbConstants.ANSWER_COL_ANSWER_TIME, startOfDay)
      const resultSet = await rdbStore.query(predicates, ['COUNT(*) as cnt'])
      if (resultSet.goToFirstRow()) {
        const count = resultSet.getLong(0)
        resultSet.close()
        return count
      }
      resultSet.close()
      return 0
    } catch (err) {
      Logger.error(`Failed to getTodayAnsweredCount: ${JSON.stringify(err)}`)
      return 0
    }
  }

  async getTodayCorrectCount(): Promise<number> {
    const rdbStore = this.dbService.getRdbStore()
    if (!rdbStore) {
      return 0
    }
    try {
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const startOfDay = today.getTime()
      const predicates = new relationalStore.RdbPredicates(DbConstants.ANSWER_TABLE)
      predicates.greaterThanOrEqualTo(DbConstants.ANSWER_COL_ANSWER_TIME, startOfDay)
      predicates.equalTo(DbConstants.ANSWER_COL_IS_CORRECT, 1)
      const resultSet = await rdbStore.query(predicates, ['COUNT(*) as cnt'])
      if (resultSet.goToFirstRow()) {
        const count = resultSet.getLong(0)
        resultSet.close()
        return count
      }
      resultSet.close()
      return 0
    } catch (err) {
      Logger.error(`Failed to getTodayCorrectCount: ${JSON.stringify(err)}`)
      return 0
    }
  }
}
