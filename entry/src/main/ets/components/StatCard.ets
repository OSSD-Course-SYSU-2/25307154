@Component
export struct StatCard {
  @Prop title: string = ''
  @Prop value: string = ''
  @Prop icon: string = ''

  build() {
    Column() {
      Text(this.icon)
        .fontSize(24)
        .margin({ bottom: 8 })

      Text(this.title)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 4 })

      Text(this.value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
    }
    .width('100%')
    .height(120)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(12)
    .padding(12)
  }
}
