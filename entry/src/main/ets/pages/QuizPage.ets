import { QuizViewModel } from '../viewmodel/QuizViewModel'
import { QuizOption } from '../components/QuizOption'
import { FavoriteButton } from '../components/FavoriteButton'
import { AnswerResult } from '../model/StatsModels'
import { QuizOption as QuizOptionType } from '../model/QuizQuestion'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct QuizPage {
  @State currentQuestionTarget: string = ''
  @State options: QuizOptionType[] = []
  @State correctOptionIndex: number = -1
  @State selectedOption: number = -1
  @State answerResult: AnswerResult | null = null
  @State isAnswered: boolean = false
  @State sessionAnsweredCount: number = 0
  @State sessionCorrectCount: number = 0
  @State allMastered: boolean = false
  @State isLoading: boolean = false
  @State errorMessage: string = ''
  @State isCurrentFavorite: boolean = false

  private viewModel: QuizViewModel = new QuizViewModel()

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    const isResume = (params?.['resume'] as boolean) ?? false
    this.viewModel.initSession(isResume).then(() => {
      this.syncFromViewModel()
    })
  }

  aboutToDisappear(): void {
    this.viewModel.finishSession()
  }

  private syncFromViewModel(): void {
    if (this.viewModel.currentQuestion) {
      this.currentQuestionTarget = this.viewModel.currentQuestion.targetWord
      this.options = this.viewModel.currentQuestion.options
      this.correctOptionIndex = this.viewModel.currentQuestion.correctOptionIndex
    }
    this.selectedOption = this.viewModel.selectedOption
    this.answerResult = this.viewModel.answerResult
    this.isAnswered = this.viewModel.isAnswered
    this.sessionAnsweredCount = this.viewModel.sessionAnsweredCount
    this.sessionCorrectCount = this.viewModel.sessionCorrectCount
    this.allMastered = this.viewModel.allMastered
    this.isLoading = this.viewModel.isLoading
    this.errorMessage = this.viewModel.errorMessage
    this.isCurrentFavorite = this.viewModel.isCurrentFavorite
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .onClick(() => {
            router.back()
          })

        Text('答题')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('')
          .width(48)
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      Row() {
        Text(`已答: ${this.sessionAnsweredCount}`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))

        Text(`答对: ${this.sessionCorrectCount}`)
          .fontSize(14)
          .fontColor($r('app.color.text_correct'))

        if (this.allMastered) {
          Text('全部已掌握!')
            .fontSize(12)
            .fontColor($r('app.color.text_correct'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding(16)
      .backgroundColor($r('app.color.bg_card'))
      .borderRadius(12)
      .margin({ bottom: 24 })

      if (this.errorMessage.length > 0) {
        Text(this.errorMessage)
          .fontSize(16)
          .fontColor($r('app.color.text_wrong'))
          .margin({ top: 40 })
      } else if (this.isLoading) {
        LoadingProgress()
          .width(48)
          .height(48)
          .color($r('app.color.text_secondary'))
          .margin({ top: 80 })
      } else {
        Row() {
          Text(this.currentQuestionTarget)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          FavoriteButton({
            isFavorite: this.isCurrentFavorite,
            onToggle: () => {
              this.viewModel.toggleFavorite().then(() => {
                this.isCurrentFavorite = this.viewModel.isCurrentFavorite
              })
            }
          })
        }
        .width('100%')
        .margin({ top: 40, bottom: 40 })

        Column() {
          ForEach(this.options, (option: QuizOptionType) => {
            QuizOption({
              optionIndex: option.index,
              optionText: option.meaning,
              isSelected: this.selectedOption === option.index,
              isCorrect: option.index === this.correctOptionIndex,
              isAnswered: this.isAnswered,
              onSelected: (idx: number) => {
                this.viewModel.selectOption(idx)
                this.selectedOption = idx
              }
            })
              .margin({ bottom: 12 })
          }, (option: QuizOptionType) => `${this.currentQuestionTarget}_${option.index}`)
        }
        .width('100%')

        if (this.isAnswered && this.answerResult) {
          Column() {
            Row() {
              Text(this.answerResult.isCorrect ? '✓ 回答正确!' : '✗ 回答错误')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.answerResult.isCorrect ?
                  $r('app.color.text_correct') : $r('app.color.text_wrong'))
            }
            .margin({ top: 24, bottom: 8 })

            if (!this.answerResult.isCorrect) {
              Text(`正确释义: ${this.answerResult.correctMeaning}`)
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .margin({ bottom: 16 })
            }

            Button('继续')
              .width('60%')
              .height(48)
              .fontSize(16)
              .backgroundColor($r('app.color.bg_accent'))
              .fontColor(Color.White)
              .borderRadius(12)
              .margin({ top: 8 })
              .onClick(() => {
                this.viewModel.continueToNext().then(() => {
                  this.syncFromViewModel()
                })
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        } else if (this.selectedOption >= 0 && !this.isAnswered) {
          Button('提交答案')
            .width('60%')
            .height(48)
            .fontSize(16)
            .backgroundColor($r('app.color.bg_accent'))
            .fontColor(Color.White)
            .borderRadius(12)
            .margin({ top: 24 })
            .onClick(() => {
              this.viewModel.submitAnswer().then(() => {
                this.syncFromViewModel()
              })
            })
        }
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 8, bottom: 20 })
    .backgroundColor($r('app.color.bg_page'))
  }
}
