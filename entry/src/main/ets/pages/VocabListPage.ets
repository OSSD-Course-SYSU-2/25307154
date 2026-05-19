import { VocabListViewModel } from '../viewmodel/VocabListViewModel'
import { VocabCard } from '../components/VocabCard'
import { VocabItem } from '../model/VocabItem'
import { MasteryStatus } from '../model/Enums'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct VocabListPage {
  @State vocabList: VocabItem[] = []
  @State searchKeyword: string = ''
  @State currentTab: number = 0
  @State isLoading: boolean = false
  @State noResult: boolean = false

  private viewModel: VocabListViewModel = new VocabListViewModel()
  private searchTimer: number = -1

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    await this.viewModel.loadVocabList()
    this.syncFromViewModel()
  }

  private syncFromViewModel(): void {
    this.vocabList = this.viewModel.vocabList
    this.isLoading = this.viewModel.isLoading
    this.noResult = this.viewModel.noResult
  }

  private async handleSearch(keyword: string): Promise<void> {
    this.searchKeyword = keyword
    await this.viewModel.setSearch(keyword)
    this.syncFromViewModel()
  }

  private async handleTabChange(index: number): Promise<void> {
    this.currentTab = index
    const statusMap: (MasteryStatus | 'ALL')[] = ['ALL', MasteryStatus.MASTERED, MasteryStatus.LEARNING]
    await this.viewModel.setFilter(statusMap[index])
    this.syncFromViewModel()
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .onClick(() => { router.back() })
        Text('词汇浏览')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('').width(48)
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 8 })

      TextInput({ placeholder: '搜索单词...', text: this.searchKeyword })
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor($r('app.color.bg_card'))
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 12 })
        .onChange((value: string) => {
          this.handleSearch(value)
        })

      Tabs({ index: this.currentTab }) {
        TabContent() {
        }.tabBar('全部')

        TabContent() {
        }.tabBar('已掌握')

        TabContent() {
        }.tabBar('待学习')
      }
      .width('100%')
      .height(44)
      .onChange((index: number) => {
        this.handleTabChange(index)
      })
      .margin({ bottom: 12 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.noResult) {
        Column() {
          Text('未找到匹配的词汇')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.vocabList, (item: VocabItem) => {
            ListItem() {
              VocabCard({ vocabItem: item, showMastery: true })
            }
          }, (item: VocabItem) => item.word)
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
}
