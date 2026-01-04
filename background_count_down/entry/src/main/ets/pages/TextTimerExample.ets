@Entry
@Component
struct TextTimerExample {
  private format:string = 'ss';
  private total:number = 60;
  private textTimerController = new TextTimerController()

  build() {
    RelativeContainer(){
      Column() {
        TextTimer({isCountDown: true, count: this.total*1000,controller: this.textTimerController})
          .format(this.format)
          .fontColor(Color.Black)
          .fontSize(50)
          .onTimer((utc:number,elapsedTime:number)=>{
            //
          })
        Column({ space: 16 }){
          Button('start')
            .width('100%')
            .onClick(()=>{
              this.textTimerController.start()
            })
          Button('stop')
            .width('100%')
            .onClick(()=>{
              this.textTimerController.pause()
            })
          Button('reset')
            .width('100%')
            .onClick(()=>{
              this.textTimerController.reset()
            })
        }
      }
      .alignRules({
        middle: {
          anchor: '__container__',
          align: HorizontalAlign.Center
        },
        center: {
          anchor: '__container__',
          align: VerticalAlign.Center
        }
      })
      .padding({
        left: 16,
        right: 16
      })
    }
    .height('100%')
    .width('100%')
  }
}