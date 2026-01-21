import { ChartController, ChartOptions, GaugeChart } from './ChartComponent'

@Entry
@Component
struct Index {
  @State targetValue:number = 0
  controller: ChartController = new ChartController()
  @State chartOptions:ChartOptions = {
    chartInfo: {
      width: 200,
      height: 120,
      radius: 90,
      innerSectorRadius: 75,
      ringLineWidth: 10,
      pointerRadius: 4,
      outRingColor: ['#F2F4F6','#F2F4F6'],
      innerRingColor: ['#F95843','#F95843'],
      innerSectorColor: ['#FFF1F0','#FFFFFF']
    },
    startInfo: {
      value: '0',
      textStyle: {
        fontColor: '#909499',
        fontSize: 12,
        align: 'left',
      },
      position: [-78,0]
    },
    endInfo: {
      value: '1000',
      textStyle: {
        fontColor: '#909499',
        fontSize: 12,
        align: 'right',
      },
      position: [78,0]
    },
    detailInfo: {
      value: '0',
      textStyle: {
        fontColor: '#333',
        fontSize: 20,
        align: 'center',
      },
      position: [0,-30]
    }
  }

  build() {
    Column(){
      GaugeChart({
        targetValue: this.targetValue,
        chartOptions: this.chartOptions,
        controller: this.controller
      })
      Button('点击').onClick(()=>{
        this.targetValue = 0.8
        this.chartOptions.detailInfo.value = '150'
        this.controller.update()
      })
    }
  }
}