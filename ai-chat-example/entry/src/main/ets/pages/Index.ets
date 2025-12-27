import { KeyboardAvoidMode } from '@kit.ArkUI';
interface Item {
  isRight?:boolean;
  content: string;
  onFinish?:()=>void
  onUpdate?:()=>void
}

@Entry
@Component
struct Index {
  @State list: Item[] = []
  @State message?:string = ''
  private scroller: Scroller = new Scroller()
  @State autoScroll:boolean = true
  addListItem(data:Item){
    return new Promise<void>(resolve => {
      data.onFinish = ()=>{
        resolve()
      }
      data.onUpdate=()=>{
        this.handleScrollToBottom()
      }
      this.list.push(data)
    });
  };

  addDefaultMsg(){
    (async ()=>{
      try {
        this.addListItem({
          content: '你好，请问有什么可以帮助你的吗',
        })

      }catch (e) {
        //
      }
    })()

  }
  handleScrollToBottom(){
    if(!this.scroller.isAtEnd()&&this.autoScroll){
      this.scroller.scrollEdge(Edge.Bottom)
    }



  }
  handleSend(){
    if(!this.message) return
    let msg = this.message
    this.message = undefined
    this.addListItem({
      content: msg,
      isRight: true
    })


    // 模拟后台回复
    setTimeout(()=>{
      (async ()=>{
        await this.addListItem({
          content: '时区问题：上面的方法使用本地时间，如果需要处理不同时区，建议使用 UTC 时间'
        })
        await this.addListItem({
          content: '性能：对于大量计算，方法一和方法二性能最好'
        })
        await this.addListItem({
          content: '闰秒：JavaScript 的 Date 对象不考虑闰秒'
        })
        await this.addListItem({
          content: '日期格式：建议使用 ISO 8601 格式（YYYY-MM-DD）以获得最佳兼容性'
        })
        await this.addListItem({
          content: '我们之前的方法已经考虑到了闰年，因为Date对象在内部处理了闰年。但是，我们需要注意，我们计算的是两个日期之间相差的天数，而不是两个日期之间相隔的日历天数（即，如果计算2024-01-01到2024-01-02，我们通常认为是1天，而不是2天）。'
        })
        await this.addListItem({
          content: '另外，我们还需要注意，当我们使用Math.ceil或Math.floor时，可能会因为时间的小数部分导致计算错误。因此，我们先将时间设置为午夜（0点），然后计算毫秒差，再除以一天的毫秒数，最后取整。'
        })
        await this.addListItem({
          content: '但是，有一个边界情况：如果两个日期一个在夏令时开始前，一个在开始后，那么由于夏令时的影响，一天可能不是24小时，而是23或25小时。不过，由于我们将时间都设为了午夜，所以通常不会受此影响。'
        })
        await this.addListItem({
          content: '我们来看一个例子：假设夏令时在3月某天开始，当天凌晨2点直接变为3点，那么这一天只有23小时。但是，我们将时间设置为午夜（0点），所以从3月1日午夜到3月2日午夜，在时钟上是24小时，但实际上可能只有23小时（如果夏令时在中间开始）。不过，在JavaScript中，Date对象会自动处理夏令时，所以我们计算两个午夜时间之间的差值，仍然是24小时的整数倍。'
        })

      })()


    },1000)

  }
  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
    this.addDefaultMsg()
  }
  build(){
    Column() {
      Column(){
        Scroll(this.scroller){
          List({space: 20}) {
            ForEach(this.list, (item: Item, index:number) => {
              ListItem() {
                CardItem({ item: item, index: index });
              }
              .align(item.isRight?Alignment.End:Alignment.Start)
              .width('100%')
            }, (item: Item,index:number) => index.toString())
          }
          .padding(20)

          .width('100%')
        }
        .parallelGesture(
          PanGesture(new PanGestureOptions({ direction: PanDirection.Vertical }))
            .onActionEnd((event: GestureEvent) => {
              // 手动向上滑动，意味着用户想要查看上面，那么停止自动往下滚的逻辑
              if (event.offsetY > 20) {
                this.autoScroll = false
              }
              if(event.offsetY<0 && this.scroller.isAtEnd()){
                this.autoScroll = true
              }

            }), GestureMask.Normal);


      }
      .width('100%')
      .layoutWeight(1)

      Row({space: 10}){
        TextInput({placeholder: '请输入...',text: $$this.message}).layoutWeight(1).onFocus(()=>{
          this.autoScroll = true
          this.handleScrollToBottom()
        })
        Button('发送').fontColor(Color.White).backgroundColor(Color.Blue).onClick(()=>{
          this.handleSend()
        })
      }
      .padding({ left: 10,right: 10})
      .width('100%')
      .height(50)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }


}


export class CommodityText implements AttributeModifier<TextAttribute> {
  textType: string = 'TYPE_ONE';

  constructor(textType: string) {
    this.textType = textType;
  }

  applyNormalAttribute(instance: TextAttribute): void {
    if (this.textType === 'TYPE_ONE') {
      instance
        .fontColor(Color.White)
        .fontSize(14)
        .textAlign(TextAlign.End)
    } else if (this.textType === 'TYPE_TWO') {
      instance.fontColor('#7B7E83').fontSize(14).lineHeight(18)
    }
  }
}

@Component
struct TypingText {
  @Prop type:'TYPE_ONE'|'TYPE_TWO' = 'TYPE_ONE'
  @Prop text:string ='';
  onFinish?:()=>void = ()=>{}
  onUpdate?:()=>void = ()=>{}
  @State private str:string = ''
  @State private textModifier: CommodityText = new CommodityText(this.type);
  private intervalId:number = 0
  aboutToAppear(){
    clearInterval(this.intervalId)
    let index = 0;
    this.intervalId = setInterval(()=>{
      this.str+= this.text[index++]
      if(index===this.text.length){
        clearInterval(this.intervalId)
        this.onFinish?.()
      }
    },75)
  }
  aboutToDisappear(): void {
    clearInterval(this.intervalId)
  }
  build() {
    Text(this.str).attributeModifier(this.textModifier)
      .onAreaChange((oldValue,newValue)=>{
        if(oldValue.height!==newValue.height){
          this.onUpdate?.()
        }
      })
    }
}


@Component
struct CardItem {
  // 创建List的每个子组件CardItem
  @Prop item: Item;
  @Prop index: number;
  @State isAppear: boolean = false;
  build() {
    Column({space: 10}) {
      if(!this.item.isRight){

        TypingText({text: this.item.content,type:'TYPE_TWO',onFinish: this.item.onFinish,onUpdate:this.item.onUpdate})
      }
      else {
        Text(this.item.content)
          .fontColor('7B7E83')
          .lineHeight(20)
          .fontSize(14)
          .onAppear(()=>{
            this.item.onFinish?.()
          })
      }

    }
    .constraintSize({maxWidth: '80%'})
    .alignItems(this.item.isRight?HorizontalAlign.End: HorizontalAlign.Start)
    .backgroundColor('#F9FAFB')
    .padding(10)
    .borderRadius(10)
  }
}