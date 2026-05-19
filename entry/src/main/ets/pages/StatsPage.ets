import { StatsViewModel } from '../viewmodel/StatsViewModel'
import { StatCard } from '../components/StatCard'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct StatsPage {
  @State totalVocabCount: string = '0'
  @State masteredCount: string = '0'
  @State learningCount: string = '0'
  @State overallAccuracy: string = '--'
  @State todayAnsweredCount: string = '0'
  @State todayAccuracy: string = '--'
  @State hasNoData: boolean = true

  private viewModel: StatsViewModel = new StatsViewModel()

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    await this.viewModel.loadStats()
    this.totalVocabCount = `${this.viewModel.totalVocabCount}`
    this.masteredCount = `${this.viewModel.masteredCount}`
    this.learningCount = `${this.viewModel.learningCount}`
    this.overallAccuracy = this.viewModel.overallAccuracy !== null ? `${this.viewModel.overallAccuracy}%` : '--'
    this.todayAnsweredCount = `${this.viewModel.todayAnsweredCount}`
    this.todayAccuracy = this.viewModel.todayAccuracy !== null ? `${this.viewModel.todayAccuracy}%` : '--'
    this.hasNoData = this.viewModel.hasNoData
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .onClick(() => { router.back() })
        Text('学习统计')
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

      if (this.hasNoData) {
        Column() {
          Text('暂无学习记录')
            .fontSize(18)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })
          Text('开始答题吧!')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        GridRow({ columns: 2, gutter: 12 }) {
          GridCol() {
            StatCard({ title: '总词汇数', value: this.totalVocabCount, icon: '📚' })
          }
          GridCol() {
            StatCard({ title: '已掌握', value: this.masteredCount, icon: '✅' })
          }
          GridCol() {
            StatCard({ title: '待学习', value: this.learningCount, icon: '📖' })
          }
          GridCol() {
            StatCard({ title: '正确率', value: this.overallAccuracy, icon: '🎯' })
          }
          GridCol() {
            StatCard({ title: '今日答题', value: this.todayAnsweredCount, icon: '📝' })
          }
          GridCol() {
            StatCard({ title: '今日正确率', value: this.todayAccuracy, icon: '⭐' })
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
    .backgroundColor($r('app.color.bg_page'))
  }
}
