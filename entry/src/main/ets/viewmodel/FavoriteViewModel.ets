import { FavoriteService } from '../service/FavoriteService'
import { VocabItem } from '../model/VocabItem'
import { Logger } from '../common/log/Logger'
import { promptAction } from '@kit.ArkUI'

export class FavoriteViewModel {
  favoriteList: VocabItem[] = []
  favoriteCount: number = 0
  isEmpty: boolean = true
  isLoading: boolean = false

  async loadFavoriteList(): Promise<void> {
    this.isLoading = true
    try {
      const favoriteService = FavoriteService.getInstance()
      this.favoriteList = await favoriteService.getFavoriteList()
      this.favoriteCount = this.favoriteList.length
      this.isEmpty = this.favoriteCount === 0
    } catch (err) {
      Logger.error(`Failed to loadFavoriteList: ${JSON.stringify(err)}`)
      this.favoriteList = []
      this.favoriteCount = 0
      this.isEmpty = true
    } finally {
      this.isLoading = false
    }
  }

  async removeFavorite(word: string): Promise<void> {
    try {
      const favoriteService = FavoriteService.getInstance()
      await favoriteService.removeFavorite(word)
      promptAction.showToast({ message: '已从生词本移除', duration: 1500 })
      this.favoriteList = this.favoriteList.filter(item => item.word !== word)
      this.favoriteCount = this.favoriteList.length
      this.isEmpty = this.favoriteCount === 0
    } catch (err) {
      promptAction.showToast({ message: '取消收藏失败，请稍后重试', duration: 1500 })
      Logger.error(`Failed to removeFavorite in ViewModel: ${JSON.stringify(err)}`)
    }
  }

  async refreshList(): Promise<void> {
    await this.loadFavoriteList()
  }
}
