import { VocabDbService } from './VocabDbService'
import { VocabItem } from '../model/VocabItem'
import { Logger } from '../common/log/Logger'

export class FavoriteOperationError extends Error {
  constructor(msg: string) {
    super(msg)
    this.name = 'FavoriteOperationError'
  }
}

export class FavoriteService {
  private static instance: FavoriteService | null = null
  private dbService: VocabDbService

  private constructor() {
    this.dbService = VocabDbService.getInstance()
  }

  static getInstance(): FavoriteService {
    if (!FavoriteService.instance) {
      FavoriteService.instance = new FavoriteService()
    }
    return FavoriteService.instance
  }

  async addFavorite(word: string): Promise<void> {
    try {
      await this.dbService.updateFavoriteStatus(word, true, Date.now())
    } catch (err) {
      Logger.error(`Failed to addFavorite: ${JSON.stringify(err)}`)
      throw new FavoriteOperationError('添加收藏失败')
    }
  }

  async removeFavorite(word: string): Promise<void> {
    try {
      await this.dbService.updateFavoriteStatus(word, false, 0)
    } catch (err) {
      Logger.error(`Failed to removeFavorite: ${JSON.stringify(err)}`)
      throw new FavoriteOperationError('取消收藏失败')
    }
  }

  async toggleFavorite(word: string, currentStatus: boolean): Promise<void> {
    if (currentStatus) {
      await this.removeFavorite(word)
    } else {
      await this.addFavorite(word)
    }
  }

  async isFavorite(word: string): Promise<boolean> {
    try {
      const item = await this.dbService.getVocabByWord(word)
      return item?.isFavorite ?? false
    } catch (err) {
      Logger.error(`Failed to isFavorite: ${JSON.stringify(err)}`)
      return false
    }
  }

  async getFavoriteList(): Promise<VocabItem[]> {
    try {
      return await this.dbService.getFavoriteList()
    } catch (err) {
      Logger.error(`Failed to getFavoriteList: ${JSON.stringify(err)}`)
      return []
    }
  }

  async getFavoriteCount(): Promise<number> {
    try {
      return await this.dbService.getFavoriteCount()
    } catch (err) {
      Logger.error(`Failed to getFavoriteCount: ${JSON.stringify(err)}`)
      return 0
    }
  }
}
