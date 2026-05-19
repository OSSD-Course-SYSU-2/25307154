import { ProgressViewModel } from '../viewmodel/ProgressViewModel'
import { VocabCard } from '../components/VocabCard'
import { VocabItem } from '../model/VocabItem'
import { MasteryStatus } from '../model/Enums'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct ProgressPage {
  @State totalVocabCount: number = 0
  @State masteredCount: number = 0
  @State learningCount: number = 0
  @State overallAccuracy: string = '--'
  @State masteredVocabList: VocabItem[] = []
  @State learningVocabList: VocabItem[] = []
  @State isMasteredExpanded: boolean = false
  @State isLearningExpanded: boolean = true

  private viewModel: ProgressViewModel = new ProgressViewModel()

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    await this.viewModel.loadProgressData()
    this.totalVocabCount = this.viewModel.summary.totalVocabCount
    this.masteredCount = this.viewModel.summary.masteredCount
    this.learningCount = this.viewModel.summary.learningCount
    this.overallAccuracy = this.viewModel.summary.overallAccuracy !== null ?
      `${this.viewModel.summary.overallAccuracy}%` : '--'
    this.masteredVocabList = this.viewModel.masteredVocabList
    this.learningVocabList = this.viewModel.learningVocabList
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .onClick(() => { router.back() })
        Text('学习进度')
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
      .margin({ bottom: 16 })

      Row() {
        Column() {
          Text(`${this.masteredCount}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_correct'))
          Text('已掌握')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)

        Column() {
          Text(`${this.learningCount}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_wrong'))
          Text('待学习')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)

        Column() {
          Text(this.overallAccuracy)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('正确率')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(90)
      .backgroundColor($r('app.color.bg_card'))
      .borderRadius(16)
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 20 })

      Scroll() {
        Column() {
          this.VocabGroup('已掌握词汇', this.masteredCount, this.masteredVocabList, this.isMasteredExpanded, () => {
            this.isMasteredExpanded = !this.isMasteredExpanded
          })

          this.VocabGroup('待学习词汇', this.learningCount, this.learningVocabList, this.isLearningExpanded, () => {
            this.isLearningExpanded = !this.isLearningExpanded
          })
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
    .backgroundColor($r('app.color.bg_page'))
  }

  @Builder
  VocabGroup(title: string, count: number, vocabList: VocabItem[], isExpanded: boolean, onToggle: () => void) {
    Column() {
      Row() {
        Text(`${title} (${count})`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)

        Text(isExpanded ? '收起' : '展开')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .padding(12)
      .onClick(() => {
        onToggle()
      })

      if (isExpanded) {
        ForEach(vocabList, (item: VocabItem) => {
          VocabCard({ vocabItem: item, showMastery: true })
            .margin({ top: 8 })
        }, (item: VocabItem) => item.word)
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(12)
    .margin({ bottom: 16 })
  }
}
