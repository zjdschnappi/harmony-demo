
@Component
export struct Robot {
  @State angle: number = 0;
  @State eyeScale: number = 1;
  timer: number = 0;
  aboutToAppear(): void {
    this.startAnimate()
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer)
  }
  startAnimate() {
    this.timer = setTimeout(() => {
      this.angle = -360
      this.getUIContext()?.keyframeAnimateTo({
        iterations: -1
      }, [
        {
          duration: 200,
          event: () => {
            this.eyeScale = 0.6;
          }
        },
        {
          duration: 200,
          event: () => {
            this.eyeScale = 1;
          }
        }
      ]);
    }, 20)
  }
  @Builder
  eye(){
    Image($r('app.media.ai_loading_eyes_left')).objectFit(ImageFit.Cover).draggable(false)
      .width(18)
      .height(18)
      .scale({ y: this.eyeScale })
  }

  build() {
    RelativeContainer() {
      Column() {
        Stack() {
          Image($r('app.media.ai_loading_body'))
            .draggable(false)
            .objectFit(ImageFit.Contain)
            .size({ width: 120, height: 120 })
          Row() {
            this.eye()
            this.eye()
          }
          .margin({top: 10})
          .width(64)
          .justifyContent(FlexAlign.SpaceAround)

        }

      }
      .alignRules({
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
        center: { anchor: '__container__', align: VerticalAlign.Center },
      })

      Row() {
        Image($r('app.media.ai_loading_head'))
          .size({ width: 24, height: 24 })
          .margin({ top: -5 })
          .rotate({ angle: -15 })
          .draggable(false)
        Image($r('app.media.ai_loading_tail'))
          .size({ width: 64, height: 30 })
          .rotate({ angle: -15 })
          .draggable(false)
      }
      .width(160)
      .justifyContent(FlexAlign.Center)
      .rotate({
        z: 1, // 绕Z轴旋转
        angle: this.angle, // 绑定角度
        centerX: 80, // 中心点X坐标（组件宽度50%位置）
        centerY: 80         // 中心点Y坐标（组件高度50%位置）
      })
      .animation({
        playMode: PlayMode.Normal,
        duration: 1500, // 动画时长1.5秒
        iterations: -1, // 无限循环
        curve: Curve.Linear   // 线性匀速
      })
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
      })
    }
    .height(160)
    .width(160)
  }
}