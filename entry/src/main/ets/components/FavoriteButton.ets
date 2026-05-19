@Component
export struct FavoriteButton {
  @Prop isFavorite: boolean = false
  onToggle: () => void = () => {}
  @State scaleValue: number = 1.0

  build() {
    Text(this.isFavorite ? '★' : '☆')
      .fontSize(28)
      .fontColor(this.isFavorite ? '#FFD700' : $r('app.color.text_secondary'))
      .scale({ x: this.scaleValue, y: this.scaleValue })
      .onClick(() => {
        animateTo({ duration: 150 }, () => {
          this.scaleValue = 0.8
        })
        setTimeout(() => {
          animateTo({ duration: 150 }, () => {
            this.scaleValue = 1.0
          })
        }, 150)
        this.onToggle()
      })
      .margin({ left: 8, right: 8 })
      .hitTestBehavior(HitTestMode.Default)
  }
}
