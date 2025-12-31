import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import { BusinessError } from '@kit.BasicServicesKit'
@Entry
@Component
struct Index {
  format:string = 'ss';
  @State intervalN:number = 0;
  private timer: number = 0;
  private total:number = 60;
  private delayInfo?:backgroundTaskManager.DelaySuspendInfo
  private textTimerController = new TextTimerController()

  handleStart(){
    let reason = 'test';
    try {
      if(this.delayInfo){
        backgroundTaskManager.cancelSuspendDelay(this.delayInfo.requestId)
      }
      this.delayInfo = backgroundTaskManager.requestSuspendDelay(reason,()=>{
        console.info('Request suspension delay will time out')
      })
      let id = this.delayInfo.requestId;
      let time = this.delayInfo.actualDelayTime;
      console.info(`The requestId is ${id}`)
      console.info(`The actualDelayTime is ${time}`)
      clearInterval(this.timer)
      this.timer = setInterval(()=>{
        if(this.intervalN === this.total){
          clearInterval(this.timer)
          this.intervalN = 0
        }else {
          this.intervalN++
        }
      },1000)
    }catch (error) {
      console.error(`requestSuspendDelay failed,code is ${(error as BusinessError).code},message is ${(error as BusinessError).message}`)
    }
  }
  handlePause(){
    clearInterval(this.timer)
  }
  handleReset(){
    clearInterval(this.timer)
    this.intervalN = 0
  }

  build() {
    Column() {
      TextTimer({isCountDown: true, count: this.total*1000,controller: this.textTimerController})
        .format(this.format)
        .fontColor(Color.Black)
        .fontSize(50)
        .onTimer((utc:number,elapsedTime:number)=>{
          //
        })
      Row(){
        Button('start').onClick(()=>{
          this.textTimerController.start()
        })
        Button('stop').onClick(()=>{
          this.textTimerController.pause()
        })
        Button('reset').onClick(()=>{
          this.textTimerController.reset()
        })
      }

      Text(`${this.intervalN===0?'00':(this.total - this.intervalN)}`.padStart(2,'0'))
        .fontColor(Color.Black)
        .fontSize(50)
      Row(){
        Button('start').onClick(()=>{
          this.handleStart()
        })
        Button('stop').onClick(()=>{
          this.handlePause()
        })
        Button('reset').onClick(()=>{
          this.handleReset()
        })
      }
    }
    .height('100%')
    .width('100%')
  }
}