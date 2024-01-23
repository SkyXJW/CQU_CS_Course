import CommonConstants from '../common/constants/CommonConstants';
import AccountData from '../viewmodel/AccountData';

@CustomDialog
export struct CustomDateRangePickerDialog {
  // @Link lowValue: string
  // @Link highValue: string

  @Link newAccount1: AccountData;
  @Link newAccount2: AccountData;
  selected_date1: Date;
  selected_date2: Date;
  // @Link searchValue: string[]
  controller: CustomDialogController
  cancel: () => void
  confirm?: (newAccount1: AccountData, newAccount2: AccountData) => void

  build(){
    Column(){

      Text('请选择查询日期范围').fontSize(20).fontColor('#FF00FF').margin({ top: 10, bottom: 10})
      Row() {
        Text(this.newAccount1.date)
          // .width('100%')
          .textAlign(TextAlign.Center)
            // .padding({ left: $r('app.float.edge_size_M') })
          .borderRadius(CommonConstants.MINIMUM_SIZE)
          .backgroundColor('#EC8AA3')
          .onClick(() => {
            let cur_date = new Date()
            this.selected_date1 = cur_date
            DatePickerDialog.show({
              start: new Date("2015-1-1"),
              end: new Date("2030-12-31"),
              selected: this.selected_date1,
              onAccept: (value: DatePickerResult) => {
                //通过Date的setFullYear方法设置按下按钮时的日期
                this.selected_date1.setFullYear(value.year, value.month, value.day)
                this.newAccount1.date = value.year.toString() + '年'
                + (value.month + 1).toString() + '月'
                + value.day.toString() + '日'
                this.newAccount1.year = value.year.toString();
                this.newAccount1.month = value.year.toString() + '-' + (value.month + 1).toString();
                console.info("DatePickerDialog: onAccept()" + JSON.stringify(value))
              },
              onCancel: () => {
                console.info("DatePickerDialog:onCancel()")
              },
              onChange:(value: DatePickerResult) =>{
                console.info("DatePickerDialog:onChange()"+ JSON.stringify(value))
              }
            })
          })

        // Image($rawfile('calendar.png'))
        //   .backgroundColor('$color:start_window_background')
        //   .width('38vp')
        //   .height('38vp')
      }
      .borderWidth({ bottom: CommonConstants.FULL_SIZE })
      .borderColor($r('app.color.border_color'))

      Text('至').fontSize(20).fontColor('#FF00FF').margin({ top: 10, bottom: 10})

      Row() {
        Text(this.newAccount2.date)
          // .width('100%')
          .textAlign(TextAlign.Center)
            // .padding({ left: $r('app.float.edge_size_M') })
          .borderRadius(CommonConstants.MINIMUM_SIZE)
          .backgroundColor('#EC8AA3')
          .onClick(() => {
            let cur_date = new Date()
            this.selected_date2 = cur_date
            DatePickerDialog.show({
              start: new Date("2015-1-1"),
              end: new Date("2030-12-31"),
              selected: this.selected_date2,
              onAccept: (value: DatePickerResult) => {
                //通过Date的setFullYear方法设置按下按钮时的日期
                this.selected_date2.setFullYear(value.year, value.month, value.day)
                this.newAccount2.date = value.year.toString() + '年'
                + (value.month + 1).toString() + '月'
                + value.day.toString() + '日'
                this.newAccount2.year = value.year.toString();
                this.newAccount2.month = value.year.toString() + '-' + (value.month + 1).toString();
                console.info("DatePickerDialog: onAccept()" + JSON.stringify(value))
              },
              onCancel: () => {
                console.info("DatePickerDialog:onCancel()")
              },
              onChange:(value: DatePickerResult) =>{
                console.info("DatePickerDialog:onChange()"+ JSON.stringify(value))
              }
            })
          })

        // Image($rawfile('calendar.png'))
        //   .backgroundColor('$color:start_window_background')
        //   .width('38vp')
        //   .height('38vp')
      }
      .borderWidth({ bottom: CommonConstants.FULL_SIZE })
      .borderColor($r('app.color.border_color'))

      // Text('请选择查询日期范围').fontSize(20).fontColor('#FF00FF').margin({ top: 10, bottom: 10})
      // Row(){
      //   Text('下限').fontSize(20).fontWeight(500).fontColor('#f5a623').margin({ top :10, bottom: 10})
      //   TextInput({ placeholder: '', text: this.lowValue}).height(40).width(105)
      //     .onChange((value: string) => {
      //       this.lowValue = value
      //     }).margin({right: 40})
      //
      //
      //
      //   Text('上限').fontSize(20).fontWeight(500).fontColor('#3333FF').margin({ top:10, bottom: 10})
      //   TextInput({ placeholder: '', text: this.highValue}).height(40).width(105)
      //     .onChange((value: string) => {
      //       this.highValue = value
      //     })
      //
      // }
      //
      Flex({ justifyContent: FlexAlign.SpaceAround}) {
        Button('取消')
          .onClick(() => {
            this.controller.close()
            this.cancel()
          }).backgroundColor('#808080').fontColor(Color.Black).width('50%')
        // Divider().vertical(true).height(22).color('#ff647a91').opacity(0.6).margin({ left: 8, right: 8})
        Button('确定')
          .onClick(() =>{
            // this.searchValue[0] = this.lowValue
            // this.searchValue[1] = this.highValue
            this.controller.close()
            this.confirm(this.newAccount1, this.newAccount2)
          }).backgroundColor('#00CCCC').fontColor(Color.White).width('50%')
      }.margin({ top: 10, bottom: 10 })
    }.backgroundColor('#EC8AA3')
  }
}