import { HomeViewModel } from '../viewmodel/HomeViewModel'
import { AppConstants } from '../common/constants/AppConstants'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct Index {
  @State hasUnfinishedSession: boolean = false
  @State totalVocabCount: number = 0
  @State masteredCount: number = 0
  @State learningCount: number = 0
  @State isInitializing: boolean = true
  @State favoriteCount: number = 0

  private viewModel: HomeViewModel = new HomeViewModel()

  aboutToAppear(): void {
    this.loadData()
  }

  onPageShow(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    try {
      await this.viewModel.loadHomePageData()
      this.hasUnfinishedSession = this.viewModel.hasUnfinishedSession
      this.totalVocabCount = this.viewModel.totalVocabCount
      this.masteredCount = this.viewModel.masteredCount
      this.learningCount = this.viewModel.learningCount
      this.favoriteCount = this.viewModel.favoriteCount
      this.isInitializing = false
    } catch (err) {
      this.isInitializing = false
    }
  }

  build() {
    Column() {
      Text(AppConstants.APP_NAME)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 60, bottom: 40 })

      Row() {
        this.ProgressItem('已掌握', this.masteredCount, $r('app.color.text_correct'))
        Divider().vertical(true).height(40).color($r('app.color.border_default'))
        this.ProgressItem('待学习', this.learningCount, $r('app.color.text_wrong'))
        Divider().vertical(true).height(40).color($r('app.color.border_default'))
        this.ProgressItem('总计', this.totalVocabCount, $r('app.color.text_primary'))
      }
      .width('90%')
      .height(80)
      .backgroundColor($r('app.color.bg_card'))
      .borderRadius(16)
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 40 })

      if (this.hasUnfinishedSession) {
        Button('继续上次学习')
          .width('80%')
          .height(56)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .backgroundColor($r('app.color.bg_accent_secondary'))
          .fontColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 16 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/QuizPage', params: { resume: true } })
          })
      }

      Button('开始答题')
        .width('80%')
        .height(56)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor($r('app.color.bg_accent'))
        .fontColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 16 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/QuizPage', params: { resume: false } })
        })

      Row() {
        Button('学习进度')
          .width('22%')
          .height(56)
          .fontSize(13)
          .backgroundColor($r('app.color.bg_card'))
          .fontColor($r('app.color.text_primary'))
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({ url: 'pages/ProgressPage' })
          })

        Button('学习统计')
          .width('22%')
          .height(56)
          .fontSize(13)
          .backgroundColor($r('app.color.bg_card'))
          .fontColor($r('app.color.text_primary'))
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({ url: 'pages/StatsPage' })
          })

        Button('词汇浏览')
          .width('22%')
          .height(56)
          .fontSize(13)
          .backgroundColor($r('app.color.bg_card'))
          .fontColor($r('app.color.text_primary'))
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({ url: 'pages/VocabListPage' })
          })

        Button(`生词本(${this.favoriteCount})`)
          .width('22%')
          .height(56)
          .fontSize(13)
          .backgroundColor($r('app.color.bg_card'))
          .fontColor($r('app.color.text_primary'))
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({ url: 'pages/FavoritePage' })
          })
      }
      .width('92%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_page'))
  }

  @Builder
  ProgressItem(label: string, count: number, color: ResourceColor) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 4 })
      Text(`${count}`)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .alignItems(HorizontalAlign.Center)
  }
}
