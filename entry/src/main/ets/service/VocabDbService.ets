import { relationalStore } from '@kit.ArkData'
import { util } from '@kit.ArkTS'
import { DbConstants } from '../common/constants/DbConstants'
import { Logger } from '../common/log/Logger'
import { VocabItem, createVocabItem } from '../model/VocabItem'
import { MasteryStatus } from '../model/Enums'

export class VocabDbService {
  private static instance: VocabDbService | null = null
  private rdbStore: relationalStore.RdbStore | null = null
  private appContext: Context | null = null

  private constructor() {}

  static getInstance(): VocabDbService {
    if (!VocabDbService.instance) {
      VocabDbService.instance = new VocabDbService()
    }
    return VocabDbService.instance
  }

  async initDb(context: Context): Promise<void> {
    this.appContext = context
    const config: relationalStore.StoreConfig = {
      name: DbConstants.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, config)
      await this.rdbStore.executeSql(DbConstants.CREATE_VOCAB_TABLE_BASE_SQL)
      await this.rdbStore.executeSql(DbConstants.CREATE_ANSWER_TABLE_SQL)
      await this.rdbStore.executeSql(DbConstants.CREATE_INDEX_SQL)
      Logger.info('RDB base tables initialized')

      await this.upgradeDb()
      Logger.info('RDB database initialized successfully')
    } catch (err) {
      Logger.error(`Failed to init RDB: ${JSON.stringify(err)}`)
      throw new Error(`Failed to init RDB: ${JSON.stringify(err)}`)
    }
  }

  private async upgradeDb(): Promise<void> {
    if (!this.rdbStore) {
      return
    }
    try {
      await this.rdbStore.executeSql(DbConstants.ALTER_ADD_IS_FAVORITE_SQL)
      Logger.info('Added is_favorite column successfully')
    } catch (err) {
      Logger.info(`is_favorite column may already exist, skip: ${JSON.stringify(err)}`)
    }
    try {
      await this.rdbStore.executeSql(DbConstants.ALTER_ADD_FAVORITE_TIME_SQL)
      Logger.info('Added favorite_time column successfully')
    } catch (err) {
      Logger.info(`favorite_time column may already exist, skip: ${JSON.stringify(err)}`)
    }
    try {
      await this.rdbStore.executeSql(DbConstants.CREATE_FAVORITE_INDEX_SQL)
    } catch (err) {
      Logger.info(`idx_favorite_status may already exist, skip`)
    }
    try {
      await this.rdbStore.executeSql(DbConstants.CREATE_FAVORITE_TIME_INDEX_SQL)
    } catch (err) {
      Logger.info(`idx_favorite_time may already exist, skip`)
    }
  }

  async loadVocabFromRawFile(): Promise<void> {
    if (!this.rdbStore || !this.appContext) {
      Logger.error('RDB store or context not initialized')
      return
    }
    try {
      const count = await this.getVocabCount()
      if (count > 0) {
        Logger.info(`Vocab already loaded, count: ${count}`)
        return
      }
      Logger.info('Loading vocab from rawfile...')
      const rawFile = await this.appContext.resourceManager.getRawFileContent('cet4_words.json')
      const textDecoder = util.TextDecoder.create('utf-8')
      const jsonStr = textDecoder.decodeToString(rawFile)
      const vocabData: Array<Record<string, string>> = JSON.parse(jsonStr) as Array<Record<string, string>>

      const valueBuckets: relationalStore.ValuesBucket[] = []
      for (const item of vocabData) {
        const bucket: relationalStore.ValuesBucket = {}
        bucket[DbConstants.VOCAB_COL_WORD] = item['word'] as string
        bucket[DbConstants.VOCAB_COL_MEANING] = item['meaning'] as string
        bucket[DbConstants.VOCAB_COL_POS] = item['pos'] as string
        bucket[DbConstants.VOCAB_COL_CORRECT_COUNT] = 0
        bucket[DbConstants.VOCAB_COL_WRONG_COUNT] = 0
        bucket[DbConstants.VOCAB_COL_CONSECUTIVE_CORRECT] = 0
        bucket[DbConstants.VOCAB_COL_MASTERY_STATUS] = MasteryStatus.LEARNING
        valueBuckets.push(bucket)
      }
      await this.rdbStore.batchInsert(DbConstants.VOCAB_TABLE, valueBuckets)
      Logger.info(`Vocab loaded, total: ${vocabData.length}`)
    } catch (err) {
      Logger.error(`Failed to load vocab from rawfile: ${JSON.stringify(err)}`)
      throw new Error(`Failed to load vocab from rawfile: ${JSON.stringify(err)}`)
    }
  }

  async getAllVocabItems(): Promise<VocabItem[]> {
    if (!this.rdbStore) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DbConstants.VOCAB_TABLE)
      const resultSet = await this.rdbStore.query(predicates)
      return this.parseVocabResultSet(resultSet)
    } catch (err) {
      Logger.error(`Failed to getAllVocabItems: ${JSON.stringify(err)}`)
      return []
    }
  }

  async getVocabByWord(word: string): Promise<VocabItem | null> {
    if (!this.rdbStore) {
      return null
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DbConstants.VOCAB_TABLE)
      predicates.equalTo(DbConstants.VOCAB_COL_WORD, word)
      const resultSet = await this.rdbStore.query(predicates)
      const items = this.parseVocabResultSet(resultSet)
      return items.length > 0 ? items[0] : null
    } catch (err) {
      Logger.error(`Failed to getVocabByWord: ${JSON.stringify(err)}`)
      return null
    }
  }

  async getVocabByStatus(status: MasteryStatus): Promise<VocabItem[]> {
    if (!this.rdbStore) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DbConstants.VOCAB_TABLE)
      predicates.equalTo(DbConstants.VOCAB_COL_MASTERY_STATUS, status)
      const resultSet = await this.rdbStore.query(predicates)
      return this.parseVocabResultSet(resultSet)
    } catch (err) {
      Logger.error(`Failed to getVocabByStatus: ${JSON.stringify(err)}`)
      return []
    }
  }

  async updateVocabProgress(item: VocabItem): Promise<void> {
    if (!this.rdbStore) {
      return
    }
    try {
      const bucket: relationalStore.ValuesBucket = {}
      bucket[DbConstants.VOCAB_COL_CORRECT_COUNT] = item.correctCount
      bucket[DbConstants.VOCAB_COL_WRONG_COUNT] = item.wrongCount
      bucket[DbConstants.VOCAB_COL_CONSECUTIVE_CORRECT] = item.consecutiveCorrectCount
      bucket[DbConstants.VOCAB_COL_MASTERY_STATUS] = item.masteryStatus
      const predicates = new relationalStore.RdbPredicates(DbConstants.VOCAB_TABLE)
      predicates.equalTo(DbConstants.VOCAB_COL_WORD, item.word)
      const rows = await this.rdbStore.update(bucket, predicates)
      Logger.info(`updateVocabProgress: ${item.word}, rows=${rows}`)
    } catch (err) {
      Logger.error(`Failed to updateVocabProgress: ${JSON.stringify(err)}`)
      throw new Error(`Failed to updateVocabProgress: ${JSON.stringify(err)}`)
    }
  }

  async updateFavoriteStatus(word: string, isFavorite: boolean, favoriteTime: number): Promise<void> {
    if (!this.rdbStore) {
      Logger.error('updateFavoriteStatus: rdbStore is null')
      throw new Error('RDB store not initialized')
    }
    try {
      const bucket: relationalStore.ValuesBucket = {}
      bucket[DbConstants.VOCAB_COL_IS_FAVORITE] = isFavorite ? 1 : 0
      bucket[DbConstants.VOCAB_COL_FAVORITE_TIME] = favoriteTime
      const predicates = new relationalStore.RdbPredicates(DbConstants.VOCAB_TABLE)
      predicates.equalTo(DbConstants.VOCAB_COL_WORD, word)
      const rows = await this.rdbStore.update(bucket, predicates)
      Logger.info(`updateFavoriteStatus: ${word}, favorite=${isFavorite}, rows=${rows}`)
      if (rows === 0) {
        Logger.error(`updateFavoriteStatus: no row updated for word=${word}`)
        throw new Error(`No row found for word: ${word}`)
      }
    } catch (err) {
      Logger.error(`Failed to updateFavoriteStatus: ${JSON.stringify(err)}`)
      throw new Error(`Failed to updateFavoriteStatus: ${JSON.stringify(err)}`)
    }
  }

  async getFavoriteList(): Promise<VocabItem[]> {
    if (!this.rdbStore) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DbConstants.VOCAB_TABLE)
      predicates.equalTo(DbConstants.VOCAB_COL_IS_FAVORITE, 1)
      predicates.orderByDesc(DbConstants.VOCAB_COL_FAVORITE_TIME)
      const resultSet = await this.rdbStore.query(predicates)
      return this.parseVocabResultSet(resultSet)
    } catch (err) {
      Logger.error(`Failed to getFavoriteList: ${JSON.stringify(err)}`)
      return []
    }
  }

  async getFavoriteCount(): Promise<number> {
    if (!this.rdbStore) {
      return 0
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DbConstants.VOCAB_TABLE)
      predicates.equalTo(DbConstants.VOCAB_COL_IS_FAVORITE, 1)
      const resultSet = await this.rdbStore.query(predicates, ['COUNT(*) as cnt'])
      if (resultSet.goToFirstRow()) {
        const count = resultSet.getLong(0)
        resultSet.close()
        return count
      }
      resultSet.close()
      return 0
    } catch (err) {
      Logger.error(`Failed to getFavoriteCount: ${JSON.stringify(err)}`)
      return 0
    }
  }

  async getVocabCount(): Promise<number> {
    if (!this.rdbStore) {
      return 0
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DbConstants.VOCAB_TABLE)
      const resultSet = await this.rdbStore.query(predicates, ['COUNT(*) as cnt'])
      if (resultSet.goToFirstRow()) {
        const count = resultSet.getLong(0)
        resultSet.close()
        return count
      }
      resultSet.close()
      return 0
    } catch (err) {
      Logger.error(`Failed to getVocabCount: ${JSON.stringify(err)}`)
      return 0
    }
  }

  isDbInitialized(): boolean {
    return this.rdbStore !== null
  }

  getRdbStore(): relationalStore.RdbStore | null {
    return this.rdbStore
  }

  private parseVocabResultSet(resultSet: relationalStore.ResultSet): VocabItem[] {
    const items: VocabItem[] = []
    try {
      while (resultSet.goToNextRow()) {
        const word = resultSet.getString(resultSet.getColumnIndex(DbConstants.VOCAB_COL_WORD))
        const meaning = resultSet.getString(resultSet.getColumnIndex(DbConstants.VOCAB_COL_MEANING))
        const pos = resultSet.getString(resultSet.getColumnIndex(DbConstants.VOCAB_COL_POS))
        const correctCount = resultSet.getLong(resultSet.getColumnIndex(DbConstants.VOCAB_COL_CORRECT_COUNT))
        const wrongCount = resultSet.getLong(resultSet.getColumnIndex(DbConstants.VOCAB_COL_WRONG_COUNT))
        const consecutiveCorrect = resultSet.getLong(resultSet.getColumnIndex(DbConstants.VOCAB_COL_CONSECUTIVE_CORRECT))
        const statusStr = resultSet.getString(resultSet.getColumnIndex(DbConstants.VOCAB_COL_MASTERY_STATUS))
        const masteryStatus = statusStr === MasteryStatus.MASTERED ? MasteryStatus.MASTERED : MasteryStatus.LEARNING
        let isFavorite = false
        let favoriteTime: number | null = null
        try {
          const favIdx = resultSet.getColumnIndex(DbConstants.VOCAB_COL_IS_FAVORITE)
          isFavorite = resultSet.getLong(favIdx) === 1
        } catch (e) {
          isFavorite = false
        }
        try {
          const ftIdx = resultSet.getColumnIndex(DbConstants.VOCAB_COL_FAVORITE_TIME)
          const ft = resultSet.getLong(ftIdx)
          favoriteTime = ft > 0 ? ft : null
        } catch (e) {
          favoriteTime = null
        }
        items.push({
          word, meaning, pos, correctCount, wrongCount,
          consecutiveCorrectCount: consecutiveCorrect,
          masteryStatus, isFavorite, favoriteTime
        })
      }
    } finally {
      resultSet.close()
    }
    return items
  }
}
