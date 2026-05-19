@Component
export struct QuizOption {
  @Prop optionIndex: number = 0
  @Prop optionText: string = ''
  @Prop isSelected: boolean = false
  @Prop isCorrect: boolean = false
  @Prop isAnswered: boolean = false
  onSelected: (index: number) => void = () => {}

  build() {
    Row() {
      Text(this.getOptionLabel())
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getLabelColor())
        .width(28)
        .textAlign(TextAlign.Center)

      Text(this.optionText)
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .borderRadius(12)
    .backgroundColor(this.getBackgroundColor())
    .border(this.getBorderStyle())
    .onClick(() => {
      if (!this.isAnswered) {
        this.onSelected(this.optionIndex)
      }
    })
  }

  private getOptionLabel(): string {
    const labels = ['A', 'B', 'C', 'D']
    return labels[this.optionIndex] || ''
  }

  private getBackgroundColor(): ResourceColor {
    if (this.isAnswered) {
      if (this.isCorrect) {
        return $r('app.color.bg_correct')
      }
      if (this.isSelected && !this.isCorrect) {
        return $r('app.color.bg_wrong')
      }
      return $r('app.color.bg_option_default')
    }
    if (this.isSelected) {
      return $r('app.color.bg_selected')
    }
    return $r('app.color.bg_option_default')
  }

  private getBorderStyle(): BorderOptions {
    if (this.isAnswered) {
      return { width: 0 }
    }
    if (this.isSelected) {
      return { width: 2, color: $r('app.color.border_selected') }
    }
    return { width: 1, color: $r('app.color.border_default') }
  }

  private getLabelColor(): ResourceColor {
    if (this.isAnswered) {
      if (this.isCorrect) {
        return $r('app.color.text_correct')
      }
      if (this.isSelected && !this.isCorrect) {
        return $r('app.color.text_wrong')
      }
    }
    if (this.isSelected) {
      return $r('app.color.text_selected')
    }
    return $r('app.color.text_secondary')
  }
}
