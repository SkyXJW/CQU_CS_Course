@CustomDialog
export struct CustomAmountRangePickerDialog {
  @Link lowValue: string
  @Link highValue: string
  // @Link searchValue: string[]
  controller: CustomDialogController
  cancel: () => void
  confirm?: (lowValue: string, highValue: string) => void

  build(){
    Column(){
      Text('请输入查询金额范围').fontSize(20).fontColor('#FF00FF').margin({ top: 10, bottom: 10})
      Row(){
        Text('下限').fontSize(20).fontWeight(500).fontColor('#f5a623').margin({ top :10, bottom: 10})
        TextInput({ placeholder: '', text: this.lowValue}).height(40).width(105)
          .onChange((value: string) => {
            this.lowValue = value
          }).margin({right: 40})



        Text('上限').fontSize(20).fontWeight(500).fontColor('#3333FF').margin({ top:10, bottom: 10})
        TextInput({ placeholder: '', text: this.highValue}).height(40).width(105)
          .onChange((value: string) => {
            this.highValue = value
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
          .onClick(() =>{
            // this.searchValue[0] = this.lowValue
            // this.searchValue[1] = this.highValue
            this.controller.close()
            this.confirm(this.lowValue, this.highValue)
          }).backgroundColor('#00CCCC').fontColor(Color.White).width('50%')
      }.margin({ bottom: 10 })
    }.backgroundColor('#EC8AA3')
  }
}