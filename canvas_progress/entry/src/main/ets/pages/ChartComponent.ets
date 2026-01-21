import { AnimatorOptions, AnimatorResult } from "@kit.ArkUI";

const defaultChartInfo: ChartInfo = {
  width: 200,
  height: 120,
  radius: 90,
  innerSectorRadius: 75,
  ringLineWidth: 10,
  pointerRadius: 4,
  showPointer: true,
  pointerColor: 'F95843',
  outRingColor: ['#F2F4F6','#F2F4F6'],
  innerRingColor: ['#F95843','#F95843'],
  innerSectorColor: ['#FFF1F0','#FFFFFF']
}
const defaultStartInfo:Info = {
  value: '0',
  textStyle: {
    fontColor: '#909499',
    fontSize: 12,
    align: 'left',
  },
  position: [-78,0]
}
const defaultEndInfo:Info = {
  value: '100',
  textStyle: {
    fontColor: '#909499',
    fontSize: 12,
    align: 'right',
  },
  position: [78,0]
}
const defaultDetailInfo:Info = {
  value: '0',
  textStyle: {
    fontColor: '#333',
    fontSize: 20,
    align: 'center',
  },
  position: [0,-30]
}

export interface FillTextStyle {
  fontColor:string,
  fontSize:number,
  align?:'left'|'center'|'right'

}

export interface Info {
  show?: boolean;
  value: string;
  textStyle: FillTextStyle;
  position: [number,number]
}
export interface ChartInfo {
  width: number;
  height: number;
  radius: number;
  innerSectorRadius: number;
  innerSectorColor: [string,string];
  ringLineWidth: number;
  pointerRadius?: number;
  showPointer?:boolean;
  pointerColor?: string;
  outRingColor: [string,string];
  innerRingColor: [string,string]
}
export interface ChartOptions {
  startInfo:Info,
  endInfo:Info,
  detailInfo:Info,
  chartInfo:ChartInfo,
}
export class ChartController {
  update:()=>void= ()=>{}
}

@Component
export struct GaugeChart {
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D()
  private animator?: AnimatorResult
  private animatorOptions: AnimatorOptions = {
    easing: 'ease-in-out',
    delay: 0,
    duration: 1000,
    fill: 'forwards',
    direction: 'normal',
    iterations: 1,
    begin: 0,
    end: 0
  }
  controller: ChartController = new ChartController()
  @Prop @Watch('progressChange') targetValue: number = 0
  @ObjectLink chartOptions: ChartOptions
  @State progress: number = 0  // 进度比例


  private drawRing(start: number, end: number, colors:[string,string]) {
    const context = this.context
    const chartInfo = this.chartOptions.chartInfo
    context.beginPath()
    context.lineCap = 'round'
    context.arc(0, 0, chartInfo?.radius||defaultChartInfo.radius, start, end)
    // // 添加渐变效果
    const gradient = this.context.createConicGradient(
      0,0,0
    )
    gradient.addColorStop(0, colors[0])
    gradient.addColorStop(1,colors[1])
    context.strokeStyle = gradient
    context.lineWidth = chartInfo?.ringLineWidth||0
    context.stroke()
  }
  private drawInnerSector(start: number, end: number, colors:[string,string]){
    let radius = this.chartOptions?.chartInfo?.innerSectorRadius||defaultChartInfo.innerSectorRadius
    // 开始绘制扇形
    this.context.beginPath()
    this.context.lineCap = 'round';
    this.context.arc(0, 0, radius,start,end) // 绘制圆弧
    // // 添加渐变效果
    const gradient = this.context.createLinearGradient(
      0,0+radius,0,0-radius
    )

    gradient.addColorStop(0.0, colors[1]);
    gradient.addColorStop(0.5, colors[1]);
    gradient.addColorStop(1.0, colors[0]);
    this.context.fillStyle  = gradient
    this.context.fill() // 闭合路径回到圆心
    this.context.closePath()

  }
  private update(){
    this.reDraw()
  }
  private progressChange() {
    if(this.animator){
      this.animator.finish()
    }
    this.startAnimation(this.targetValue)
  }
  private refreshProgress(){
    this.drawInnerRing()
  }
  private drawInnerRing(){
    // 计算当前进度对应的角度
    const chartInfo = this.chartOptions.chartInfo
    const progressAngle = -Math.PI + (this.progress * Math.PI)
    const innerRingColor = chartInfo?.innerRingColor || defaultChartInfo.innerRingColor;
    const pointerRadius = chartInfo?.pointerRadius || defaultChartInfo.pointerRadius!;
    const pointerColor = chartInfo?.pointerColor || defaultChartInfo.pointerColor!;
    // 绘制内圆环
    this.drawRing(-Math.PI, progressAngle,innerRingColor)
    // 在内环终点绘制小圆点
    if(chartInfo.showPointer!==false){
      this.drawEndPoint(progressAngle, pointerColor, pointerRadius) // 圆点
    }

  }
  private drawOutRing(){
    // 绘制外圆环
    let outRingColor = this.chartOptions?.chartInfo?.outRingColor||defaultChartInfo.outRingColor;
    this.drawRing(-Math.PI, 0, outRingColor)
  }
  private draw(){

    let chartInfo = this.chartOptions.chartInfo
    let innerSectorColor = chartInfo.innerSectorColor;



    this.drawOutRing()
    this.drawInnerRing()

    // 背景扇形
    this.drawInnerSector(-Math.PI, 0,innerSectorColor)

    let detailInfo = this.chartOptions.detailInfo
    console.log('chartInfo',JSON.stringify(detailInfo))
    let startInfo = this.chartOptions.startInfo
    let endInfo = this.chartOptions.endInfo
    // 圆环中间添加文字
    if(detailInfo.show!==false) {
      this.drawEndText(
        detailInfo.position[0]??defaultDetailInfo.position[0],
        detailInfo.position[1]??defaultDetailInfo.position[1],
        detailInfo.value||defaultDetailInfo.value,
        detailInfo.textStyle||defaultDetailInfo.textStyle
      )
    }
    // 在圆环两端添加文字
    if(startInfo.show!==false) {
      this.drawEndText(
        startInfo.position[0]??defaultStartInfo.position[0],
        startInfo.position[1]??defaultStartInfo.position[1],
        startInfo.value||defaultStartInfo.value,
        startInfo.textStyle||defaultStartInfo.textStyle
      )
    }
    if(endInfo.show!==false) {
      this.drawEndText(
        endInfo.position[0]??defaultEndInfo.position[0],
        endInfo.position[1]??defaultEndInfo.position[1],
        endInfo.value||defaultEndInfo.value,
        endInfo.textStyle||defaultEndInfo.textStyle
      )
    }
  }
  // 在圆弧终点绘制圆点的方法
  private drawEndPoint( endAngle: number, color: string, pointSize: number) {
    let radius = this.chartOptions.chartInfo.radius
    // 计算终点坐标
    const endX = radius * Math.cos(endAngle)
    const endY = radius * Math.sin(endAngle)

    // 绘制圆点
    this.context.beginPath()
    this.context.arc(endX, endY, pointSize, 0, Math.PI * 2)

    this.context.fillStyle = color
    this.context.fill()

  }
  private drawEndText(start:number,end:number,text:string,style:FillTextStyle) {
    // 保存当前绘图状态
    this.context.save()
    // 设置文字样式
    this.context.font = `${this.getUIContext().vp2px(style.fontSize)}px Arial`
    this.context.fillStyle = style.fontColor
    this.context.textAlign = style.align?style.align:'center'
    this.context.textBaseline = 'middle'
    this.context.fillText(text, start, end)
    // 恢复绘图状态
    this.context.restore()
  }
  private initAnimation(){
    this.animator = this.getUIContext().createAnimator(this.animatorOptions)
  }
  startAnimation(target:number){
    this.animatorOptions.begin = 0;
    this.animatorOptions.end = target;
    if(this.animator) {
      this.animator.reset(this.animatorOptions);
      this.animator.onFrame = (tmp)=> {
        this.progress = tmp
        this.refreshProgress()
      }
      this.animator.play()
    }
  }
  reDraw(){
    let width = this.chartOptions.chartInfo.width;
    let height = this.chartOptions.chartInfo.height;
    this.context.clearRect(-width/2, -height, width, height*2)
    this.draw()
  }
  aboutToAppear(): void {
    this.controller.update = () => {
      this.update()
    }
    this.initAnimation()
    this.startAnimation(this.targetValue)


  }

  build() {
    Column() {
      Canvas(this.context)
        .width(this.chartOptions.chartInfo.width)
        .height(this.chartOptions.chartInfo.height)
        .backgroundColor(Color.White)
        .rotate({
          x: 0,
          y: 0,
          z: 1,
          centerX: '50%',
          centerY: '50%',
          angle: 0
        })
        .onReady(() => {
          let chartWidth = this.chartOptions.chartInfo.width;
          let chartHeight = this.chartOptions.chartInfo.height;
          // 坐标系平移至画布底部中心
          this.context.translate(chartWidth/2, chartHeight-10)
          this.draw()

        })
    }
  }
}
