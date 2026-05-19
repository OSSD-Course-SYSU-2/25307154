import { FavoriteViewModel } from '../viewmodel/FavoriteViewModel'
import { VocabCard } from '../components/VocabCard'
import { VocabItem } from '../model/VocabItem'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct FavoritePage {
  @State favoriteList: VocabItem[] = []
  @State favoriteCount: number = 0
  @State isEmpty: boolean = true
  @State isLoading: boolean = false

  private viewModel: FavoriteViewModel = new FavoriteViewModel()

  aboutToAppear(): void {
    this.loadData()
  }

  onPageShow(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    await this.viewModel.loadFavoriteList()
    this.syncFromViewModel()
  }

  private syncFromViewModel(): void {
    this.favoriteList = this.viewModel.favoriteList
    this.favoriteCount = this.viewModel.favoriteCount
    this.isEmpty = this.viewModel.isEmpty
    this.isLoading = this.viewModel.isLoading
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .onClick(() => { router.back() })

        Text('生词本')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(`${this.favoriteCount}`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width(48)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 16 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.isEmpty) {
        Column() {
          Text('☆')
            .fontSize(48)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 16 })
          Text('暂无收藏词汇')
            .fontSize(18)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })
          Text('答题时点击收藏按钮可添加')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.favoriteList, (item: VocabItem) => {
            ListItem() {
              VocabCard({
                vocabItem: item,
                showMastery: true,
                showFavorite: true,
                onRemoveFavorite: (word: string) => {
                  this.handleRemoveFavorite(word)
                }
              })
            }
          }, (item: VocabItem) => `fav_${item.word}`)
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, bottom: 20 })
    .backgroundColor($r('app.color.bg_page'))
  }

  private async handleRemoveFavorite(word: string): Promise<void> {
    await this.viewModel.removeFavorite(word)
    this.syncFromViewModel()
  }
}
