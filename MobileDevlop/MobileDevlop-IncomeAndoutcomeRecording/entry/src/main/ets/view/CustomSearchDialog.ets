import CommonConstants from '../common/constants/CommonConstants'
@CustomDialog
export struct CustomSearchDialog {
  @Link submitValue: string
  searchController: SearchController = new SearchController()
  controller: CustomDialogController
  onCancel: () => void
  confirm: (submitValue:string) => void

  build() {
    Column() {
      Search({
        value: '',
        placeholder: '请输入待查询内容...',
        controller: this.searchController })
        .searchButton('SEARCH')
        .width('80%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .placeholderColor(Color.Gray)
        .placeholderFont({ size:14, weight:400})
        .textFont({ size:14, weight:400})
        .onSubmit((value: string) => {
          this.submitValue = value
          this.controller.close()
          this.confirm(this.submitValue)
        })
        .margin(20)
    }.width(CommonConstants.FULL_WIDTH)
  }
}