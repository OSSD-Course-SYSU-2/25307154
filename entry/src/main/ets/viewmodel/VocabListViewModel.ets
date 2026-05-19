import { ProgressService } from '../service/ProgressService'
import { VocabItem } from '../model/VocabItem'
import { MasteryStatus } from '../model/Enums'
import { Logger } from '../common/log/Logger'

export class VocabListViewModel {
  vocabList: VocabItem[] = []
  filterStatus: MasteryStatus | 'ALL' = 'ALL'
  searchKeyword: string = ''
  isLoading: boolean = false
  noResult: boolean = false

  async loadVocabList(): Promise<void> {
    this.isLoading = true
    try {
      const progressService = ProgressService.getInstance()
      this.vocabList = await progressService.searchVocab(this.searchKeyword, this.filterStatus)
      this.noResult = this.vocabList.length === 0
    } catch (err) {
      Logger.error(`Failed to loadVocabList: ${JSON.stringify(err)}`)
      this.vocabList = []
      this.noResult = true
    } finally {
      this.isLoading = false
    }
  }

  async setFilter(status: MasteryStatus | 'ALL'): Promise<void> {
    this.filterStatus = status
    await this.loadVocabList()
  }

  async setSearch(keyword: string): Promise<void> {
    this.searchKeyword = keyword
    await this.loadVocabList()
  }
}
