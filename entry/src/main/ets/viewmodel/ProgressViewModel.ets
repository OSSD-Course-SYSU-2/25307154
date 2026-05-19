import { ProgressService } from '../service/ProgressService'
import { VocabItem } from '../model/VocabItem'
import { ProgressSummary } from '../model/StatsModels'
import { MasteryStatus } from '../model/Enums'
import { Logger } from '../common/log/Logger'

export class ProgressViewModel {
  summary: ProgressSummary = { totalVocabCount: 0, masteredCount: 0, learningCount: 0, overallAccuracy: null }
  masteredVocabList: VocabItem[] = []
  learningVocabList: VocabItem[] = []

  async loadProgressData(): Promise<void> {
    try {
      const progressService = ProgressService.getInstance()
      this.summary = await progressService.getProgressSummary()
      this.masteredVocabList = await progressService.getVocabListByStatus(MasteryStatus.MASTERED)
      this.learningVocabList = await progressService.getVocabListByStatus(MasteryStatus.LEARNING)
    } catch (err) {
      Logger.error(`Failed to loadProgressData: ${JSON.stringify(err)}`)
    }
  }
}
