import { VocabItem } from '../model/VocabItem'
import { MasteryStatus } from '../model/Enums'

@Component
export struct VocabCard {
  @Prop vocabItem: VocabItem | null = null
  @Prop showMastery: boolean = true
  @Prop showFavorite: boolean = false
  onRemoveFavorite: ((word: string) => void) | null = null

  build() {
    Row() {
      Column() {
        Row() {
          Text(this.vocabItem?.word ?? '')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          if (this.showMastery && this.vocabItem) {
            Text(this.vocabItem.masteryStatus === MasteryStatus.MASTERED ? '✓' : '○')
              .fontSize(18)
              .fontColor(this.vocabItem.masteryStatus === MasteryStatus.MASTERED ?
                $r('app.color.text_correct') : $r('app.color.text_secondary'))
          }

          if (this.showFavorite && this.onRemoveFavorite && this.vocabItem) {
            Text('✕')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 12 })
              .onClick(() => {
                if (this.onRemoveFavorite && this.vocabItem) {
                  this.onRemoveFavorite(this.vocabItem.word)
                }
              })
          }
        }
        .width('100%')
        .margin({ bottom: 4 })

        Row() {
          Text(this.vocabItem?.pos ?? '')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.bg_tag'))
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .margin({ right: 8 })

          Text(this.vocabItem?.meaning ?? '')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(12)
  }
}
