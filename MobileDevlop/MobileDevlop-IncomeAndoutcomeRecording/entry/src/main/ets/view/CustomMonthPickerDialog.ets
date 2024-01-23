@CustomDialog
export struct CustomMonthPickerDialog {
  @Link yearValue: string
  @Link monthValue: string
  @Link searchValue: string
  controller: CustomDialogController
  cancel: () => void
  confirm?: (yearValue: string, monthValue: string, searchValue: string) => void

  build(){
    Column(){
      Text('请输入待查询年月').fontSize(20).fontColor('#FF00FF').margin({ top: 10, bottom: 10})
      Row(){
            Text('年份').fontSize(20).fontWeight(500).fontColor('#f5a623').margin({ top: 10, bottom: 10 })
            TextInput({ placeholder: '', text: this.yearValue }).height(40).width(100)
              .onChange((value: string) => {
                this.yearValue = value
              }).margin({right: 40})


           Text('月份').fontSize(20).fontWeight(500).fontColor('#3333FF').margin({ top: 10, bottom: 10 })
           TextInput({ placeholder: '', text: this.monthValue }).height(40).width(100)
             .onChange((value: string) => {
               this.monthValue = value
             })
      }

      Flex({ justifyContent: FlexAlign.SpaceAround}) {
        Button('取消')
          .onClick(() => {
            this.controller.close()
            this.cancel()
          }).backgroundColor('#808080').fontColor(Color.Black).width('50%')
        // Divider().vertical(true).height(22).color('#ff647a91').opacity(0.6).margin({ left: 8, right: 8})
        Button('确定')
          .onClick(() => {
            this.searchValue = this.yearValue + '-' + this.monthValue
            this.controller.close()
            this.confirm(this.yearValue, this.monthValue, this.searchValue)
          }).backgroundColor('#00CCCC').fontColor(Color.White).width('50%')
      }.margin({ bottom: 10 })
    }.backgroundColor('#EC8AA3')
  }
}