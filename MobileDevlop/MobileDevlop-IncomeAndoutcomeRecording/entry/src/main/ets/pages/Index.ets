// @ts-nocheck
/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import AccountTable from '../common/database/tables/AccountTable';
import AccountData from '../viewmodel/AccountData';
import CommonConstants from '../common/constants/CommonConstants';
import { DialogComponent } from '../view/DialogComponent';
import { ImageList } from '../viewmodel/AccountList';
import Logger from '../common/utils/Logger';
import DateText from '../view/DateTextComponent';
import CacheText from '../view/CachTextComponent';
import { DateFormat } from '../common/utils/Utils';
import { ScrollData } from '../viewmodel/ScrollItem';
import prompt from '@ohos.promptAction';
import { CustomMonthPickerDialog } from '../view/CustomMonthPickerDialog';
import { CustomAmountRangePickerDialog } from '../view/CustomAmountRangePickerDialog';
import { CustomDateRangePickerDialog } from '../view/CustomDateRangePickerDialog';
import { CustomSearchDialog } from '../view/CustomSearchDialog';
import { CustomPieChart, PicChartElement } from '../viewmodel/CustomPieChart';
// const THEME_NAMES: string[] = ['所有账单','年度账单','月度账单','日用账单','调试数据']

@Entry
@Component
export struct MainPage {
  @State editFlag: boolean = false
  @State accounts: Array<AccountData> = [];//存储用于界面展示的查询记录
  @State high_accounts: Array<AccountData> = [];//备份查询记录，在分类查询时使用
  @State scroll_accounts: Array<ScrollData> = [];//存储用于界面展示的查询记录（只不过是对accounts的一个封装，因为新增了scroller）
  @State equal_accounts: Array<AccountData> = [];
  @State searchText: string = '';
  @State isEdit: boolean = false;
  @State isInsert: boolean = false;
  @State yearValue: string = '';
  @State monthValue: string = '';
  @State lowValue: string = '';
  @State highValue: string = '';
  @State searchValue: string = '';
  @State newAccount1: AccountData = { id: 0, accountType: 0, typeText: '', amount: 0 ,date: '', year: '', month: '', reminder: ''};;
  @State newAccount2: AccountData = { id: 0, accountType: 0, typeText: '', amount: 0 ,date: '', year: '', month: '', reminder: ''};;
  @State submitValue: string = '';
  @State cur_search_text: string = '';
  @State index: number = -1;
  @State today_income: number = 0;
  @State today_outcome: number = 0;
  @State today_earning: number = 0;
  @State newAccount: AccountData = { id: 0, accountType: 0, typeText: '', amount: 0 ,date: '', year: '', month: '', reminder: ''};
  @State text_1: string ='全部类型';
  @State text_2: string ='默认排列';
  //饼图数据
  @State picChartElements: Array<PicChartElement> = [new PicChartElement('收入', 0,'#EC8AA3'),
                                                     new PicChartElement('支出', 0,'#50e3c2')];
  @State unit: string = "元";

  //删除按钮的宽度
  private deleteWidth = 100
  //按下的x轴坐标
  private downX = 0
  private scroll2DeleteData: ScrollData = null
  selected_date: Date;
  selected_date1: Date;
  selected_date2: Date;
  private select: number =0;
  private years: string[] = ['2015','2016','2017','2018','2019','2020',
                            '2021','2022','2023','2024','2025','2026',
                             '2027','2027','2028','2029','2030']
  controller: TextInputController = new TextInputController()

  private AccountTable = new AccountTable(() => {});
  private deleteList: Array<AccountData> = [];
  searchController: SearchController = new SearchController();

  // 获取上下文
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  dialogController: CustomDialogController = new CustomDialogController({
    builder: DialogComponent({
      isInsert: $isInsert,
      newAccount: $newAccount,
      confirm: (isInsert: boolean, newAccount: AccountData) => this.accept(isInsert, newAccount)
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  });

  accept(isInsert: boolean, newAccount: AccountData): void {
    if (isInsert) {
      Logger.info(`${CommonConstants.INDEX_TAG}`, `The account inserted is:  ${JSON.stringify(newAccount)}`);
      this.AccountTable.insertData(newAccount, (id: number) => {
        newAccount.id = id;
        this.accounts.push(newAccount);
        this.scroll_accounts.push({accountData: newAccount, scroller: new Scroller()})

        if(newAccount!=null){
          if(newAccount.accountType===0) this.today_outcome+=this.newAccount.amount;
          else this.today_income+=this.newAccount.amount;
          this.today_earning=this.today_income - this.today_outcome;
        }
        this.calculate(this.accounts)
      });
    } else {
      let list = this.accounts;
      let list_scroll = this.scroll_accounts;
      this.accounts = [];
      this.scroll_accounts = [];
      list[this.index] = newAccount;
      list_scroll[this.index] = { accountData: newAccount, scroller: new Scroller()};
      this.accounts = list;
      this.scroll_accounts = list_scroll;
      this.index = -1;
      this.calculate(this.accounts);
      this.AccountTable.updateData(newAccount, () => {
      });

    }
  }

  aboutToAppear() {
    this.AccountTable.getRdbStore(() => {
      this.AccountTable.query('', (result: AccountData[]) => {
        this.accounts = result
        this.high_accounts = result
        this.cur_search_text = '所有账单'
        // this.insertSearchDate()
        this.accountData2ScrollData(this.accounts)
        this.calculate(this.accounts)
      }, true);
    });

  }
  insertSearchDate(){
    let cur_date = new Date()
    this.cur_search_text = DateFormat(cur_date.getTime());
  }

  accountData2ScrollData(accounts: AccountData[]){
    this.scroll_accounts = [];
    for(let i=0;i<accounts.length;i++){
      this.scroll_accounts.push({accountData: accounts[i], scroller: new Scroller()});
    }
  }
  calculate(account: AccountData[]){
    this.today_income =0;
    this.today_outcome =0;
    this.today_earning =0;

    for(let i=0;i<account.length;i++){
      if(account[i].accountType==0){
        this.today_outcome += account[i].amount;
      }
      else {
        this.today_income += account[i].amount;
      }
    }
    this.today_earning = this.today_income - this.today_outcome;
    //更新图表数据
    this.picChartElements[0].quantity = this.today_income;
    this.picChartElements[1].quantity = this.today_outcome;
    let total = 0
    // 统计总数量
    this.picChartElements.forEach((value) => {
      total += value.quantity
    })
    // 初始化 弧线的终止弧度
    let lastEndAngle = -0.5 * Math.PI
    // 封装饼图数据
    this.picChartElements.forEach((value) => {
      // 占用百分比
      let percent = value.quantity / total
      // 四舍五入，获取整数
      value.percent = Math.round(percent * 100)
      // 初始化终止弧度为 弧线的起始弧度
      value.beginAngle = lastEndAngle
      // 计算弧线的终止弧度
      value.endAngle = (percent * 2 * Math.PI) + lastEndAngle
      // 赋值终止弧度为变量，作为下次的起始弧度
      lastEndAngle = value.endAngle
      // 返回封装好的对象
      return value
    })
    //开始绘图
    this.picChartElements.forEach((item) => {
      // 创建一个新的控制路径
      this.context.beginPath()
      // 路径从当前点移动到指定点
      this.context.moveTo(60, 60)
      // 绘制弧线路径(弧线圆心的x坐标值,弧线圆心的y坐标值,弧线的圆半径,弧线的起始弧度,弧线的终止弧度)
      this.context.arc(60, 60, 60, item.beginAngle, item.endAngle)
      // 指定绘制的填充色
      this.context.fillStyle = item.color
      // 对封闭路径进行填充
      this.context.fill()
    })
  }
  selectListItem(item: AccountData) {
    this.isInsert = false;
    this.index = this.accounts.indexOf(item);
    this.newAccount = {
      id: item.id,
      accountType: item.accountType,
      typeText: item.typeText,
      amount: item.amount,
      date: item.date,
      year: item.year,
      month: item.month,
      reminder: item.reminder
    }
  }
  deleteListItem() {
    for (let i = 0; i < this.deleteList.length-1; i++) {
      let index = this.accounts.indexOf(this.deleteList[i]);
      this.accounts.splice(index, 1);
      this.scroll_accounts.splice(index,1);
      this.calculate(this.accounts);
      this.AccountTable.deleteData(this.deleteList[i], () => {
      });
    }
    //这里因为数据库操作的异步性，可能会出现在删除操作完成前，程序会把本来即将被删除的数据记录也显示到界面上，最终我们看到的“就好像”没有成功删除一样
    //因此，这里将最后一条删除操作单独拿出来，利用它的回调函数来保证是数据库的删除操作完成后，再把这时数据库的信息进行显示
    let index = this.accounts.indexOf(this.deleteList[this.deleteList.length-1]);
    this.accounts.splice(index, 1);
    this.scroll_accounts.splice(index,1);
    this.calculate(this.accounts);
    this.AccountTable.deleteData(this.deleteList[this.deleteList.length-1], () => {
      this.accounts = [];
      this.high_accounts = [];
      this.AccountTable.query('', (result: AccountData[]) => {
        this.accounts = result
        this.high_accounts = result
        this.accountData2ScrollData(this.accounts)
        this.calculate(this.accounts)
      }, true)
      this.index = -1;
      this.searchText = '';
      this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
      this.text_1 = '全部类型';
    });
    this.deleteList = [];
    this.isEdit = false;

    // //这里删除后，立即查询最新数据库的所有信息并展示
    // this.accounts = [];
    // this.high_accounts = [];
    // this.AccountTable.query('', (result: AccountData[]) => {
    //   this.accounts = result
    //   this.high_accounts = result
    //   this.accountData2ScrollData(this.accounts)
    //   this.calculate(this.accounts)
    // }, true)
    // this.index = -1;
    // this.searchText = '';
    // this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
    // this.text_1 = '全部类型';
  }

  //金额范围查询的输入框
  CustomAmountRangePickerController: CustomDialogController = new CustomDialogController({
    builder: CustomAmountRangePickerDialog({
      cancel: this.onCancel,
      lowValue: $lowValue,
      highValue: $highValue,
      // searchValue: $searchValue,
      confirm: (lowValue:string, highValue:string) => this.customAccept1(lowValue,highValue),
    }),
    cancel:this.existApp,
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20},
    gridCount: 4,
    customStyle: false
  })

  aboutToDisappear() {
    delete this.dialogController,
    this.dialogController = undefined
  }
  onCancel() {
    console.info('Callback when the first button is clicked')
  }
  onAccept() {
    console.info('Callback when the second button is clicked')
  }
  existApp() {
    console.info('Click the callback in the blank area')
  }

  customAccept1(lowValue:string, highValue:string) {
    if(lowValue=='' || highValue == ''){
      prompt.showToast({ message: '请输入完整金额范围', bottom: CommonConstants.PROMPT_BOTTOM});
    }else{
      this.cur_search_text = '金额范围:'+lowValue + '-' + highValue
      // this.searchValue = searchValue
      // if(this.searchValue!=''){
      this.accounts = [];
      this.AccountTable.queryAmountRange(Number(this.lowValue),Number(this.highValue),(result: AccountData[]) => {
        this.accounts = result
        this.high_accounts = result
        this.calculate(this.accounts)
        this.accountData2ScrollData(this.accounts)
        this.searchText = '';
        this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
        this.text_1 = '全部类型';
        this.text_2 = '默认排序';
      },false);
      // }
    }
  }

  //月度查询的输入框
  CustomMonthPickerController: CustomDialogController = new CustomDialogController({
    builder: CustomMonthPickerDialog({
      cancel: this.onCancel,
      yearValue: $yearValue,
      monthValue: $monthValue,
      searchValue: $searchValue,
      confirm: (yearValue:string, monthValue:string, searchValue:string) => this.customAccept(yearValue,monthValue,searchValue),
    }),
    cancel:this.existApp,
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20},
    gridCount: 4,
    customStyle: false
  })

  customAccept(yearValue:string, monthValue:string, searchValue:string) {
    if(yearValue == '' || monthValue == ''){
    prompt.showToast({ message: CommonConstants.TOAST_TEXT_1, bottom: CommonConstants.PROMPT_BOTTOM});
    }else{
      this.cur_search_text = yearValue + '-' + monthValue
      this.searchValue = searchValue
      this.accounts = [];
      this.equal_accounts = [];
      this.high_accounts = [];
    if(this.searchValue!=''){
      this.AccountTable.queryMonth(this.searchValue,(result: AccountData[]) => {
         this.accounts = result
         this.equal_accounts = result
         this.high_accounts = result
         this.calculate(this.accounts)
         this.accountData2ScrollData(this.accounts)
      },false);
     }
    }
  }

  //日期范围查询的输入框
  CustomDateRangePickerController: CustomDialogController = new CustomDialogController({
    builder: CustomDateRangePickerDialog({
      cancel: this.onCancel,
      newAccount1: $newAccount1,
      newAccount2: $newAccount2,
      confirm: (newAccount1: AccountData, newAccount2: AccountData) => this.customAccept2(newAccount1,newAccount2),
    }),
    cancel:this.existApp,
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20},
    gridCount: 4,
    customStyle: false
  })

  customAccept2(newAccount1: AccountData, newAccount2: AccountData) {
      // this.cur_search_text = newAccount1.date + '-' + newAccount2.date;
      this.cur_search_text = '查询结果';
      // this.searchValue = searchValue
      this.accounts = [];
      this.high_accounts = [];
      // if(this.searchValue!=''){
        this.AccountTable.queryDateRange(newAccount1,newAccount2,(result: AccountData[]) => {
          this.accounts = result
          this.high_accounts = result
          this.calculate(this.accounts)
          this.accountData2ScrollData(this.accounts)
          this.searchText = '';
          this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
          this.text_1 = '全部类型';
        },false);

      // }
  }


  searchDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomSearchDialog({
      cancel: this.onCancel,
      confirm: (submitValue:string)=>this.customSearchAccept(submitValue),
      submitValue: $submitValue,
    }),
    cancel: this.existApp,
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    gridCount: 4,
    customStyle: false
  })

  customSearchAccept(submitValue:string){
    if(this.submitValue!=''){
      this.accounts = []
      this.high_accounts = []
      this.AccountTable.queryType(submitValue, (result: AccountData[]) => {
        this.accounts = result
        this.high_accounts = result
        this.calculate(this.accounts)
        this.accountData2ScrollData(this.accounts)
      },false);
      this.cur_search_text = '搜索结果'
    }
  }

  sortedbyamount(type: number){
    if(this.accounts.length>0){
      const amounts: number[] =[];
      for(let i=0; i<this.accounts.length;i++){
        amounts.push(this.accounts[i].amount)
      }
      for(let i=0;i<amounts.length;i++)
        for(let j=0;j<amounts.length;j++)
          if(amounts[i]<amounts[j]){
            let t = amounts[i];
            amounts[i] = amounts[j];
            amounts[j] = t;
          }
      const tmp_accounts: AccountData[] = [];
      for(let i=0;i<amounts.length;i++)
        for(let j=0;j<this.accounts.length;j++)
          if(this.accounts[j].amount == amounts[i]){
            tmp_accounts.push(this.accounts[j]);
            this.accounts.splice(j,1);
            break;
          }
      this.accounts = [];
      if(type==1){ //按照金额的升序进行排序
        this.accounts = tmp_accounts;
        this.text_2 = "金额升序";
      }
      else{ //按照金额的降序进行排序
        let k=0;
        for(let i=tmp_accounts.length-1;i>=0;i--)
          this.accounts[k++] = tmp_accounts[i]
        this.text_2 = "金额降序";
      }
      this.accountData2ScrollData(this.accounts)
    }
  }

  sortedbydate(type: number){
    if(this.accounts.length>0){
      const amounts: string[] =[];
      for(let i=0; i<this.accounts.length;i++){
        amounts.push(this.accounts[i].date)
      }
      for(let i=0;i<amounts.length;i++)
        for(let j=0;j<amounts.length;j++)
          if(amounts[i]<amounts[j]){
            let t = amounts[i];
            amounts[i] = amounts[j];
            amounts[j] = t;
          }
      const tmp_accounts: AccountData[] = [];
      for(let i=0;i<amounts.length;i++)
        for(let j=0;j<this.accounts.length;j++)
          if(this.accounts[j].date == amounts[i]){
            tmp_accounts.push(this.accounts[j]);
            this.accounts.splice(j,1);
            break;
          }
      this.accounts = [];
      if(type==1){ //按照日期的升序进行排序
        this.accounts = tmp_accounts;
        this.text_2 = "日期升序";
      }
      else{ //按照日期的降序进行排序
        let k=0;
        for(let i=tmp_accounts.length-1;i>=0;i--)
          this.accounts[k++] = tmp_accounts[i]
        this.text_2 = "日期降序";
      }
      this.accountData2ScrollData(this.accounts)
    }
  }

  @Builder MenuBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Row() {
        Text('全部账单')
          .fontSize(20)
          .fontWeight(500)
          .fontColor('#EC8AA3')
          .width(100)
          .height(50)
          .textAlign(TextAlign.Center)
        Image($rawfile('quanbu.png'))
          .backgroundColor('$color:start_window_background')
          .width($r('app.float.component_size_MP'))
          .height($r('app.float.component_size_MP'))
      }
      .onClick(() => {
              this.cur_search_text = '所有账单'
              this.accounts = [];
              this.equal_accounts = [];
              this.high_accounts = [];
              this.AccountTable.query('', (result: AccountData[]) => {
                this.accounts = result
                this.equal_accounts = result
                this.high_accounts = result
                this.accountData2ScrollData(this.accounts)
                this.calculate(this.accounts)
              }, true)
              this.index = -1;
              this.searchText = '';
              this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
              this.text_1 = '全部类型';
              this.text_2 = "这里",
              this.text_2 = "默认排列"
            })

      Divider().height(10)

      Row() {
        Text('年度账单')
          .fontSize(20)
          .fontWeight(500)
          .fontColor('#EC8AA3')
          .width(100)
          .height(50)
          .textAlign(TextAlign.Center)
        Image($rawfile('nian.png'))
          .backgroundColor('$color:start_window_background')
          .width($r('app.float.component_size_MP'))
          .height($r('app.float.component_size_MP'))
      }
      .onClick(() => {
              TextPickerDialog.show({
                range:this.years,
                selected:this.select,
                onAccept: (year_text: TextPickerResult) => {
                  this.select = year_text.index
                  this.accounts = [];
                  this.equal_accounts = [];
                  this.high_accounts = [];
                  this.cur_search_text = year_text.value + '年'
                  this.AccountTable.queryYear(String(year_text.value),(result: AccountData[]) => {
                        this.accounts = result
                        this.equal_accounts = result
                        this.high_accounts = result
                        this.accountData2ScrollData(this.accounts)
                        this.calculate(this.accounts)
                  },false);
                  console.info("TextPickerDialog:OnAccept()"+JSON.stringify(year_text))
                },
                onCancel: () =>{
                  console.info("TextPickerDialog:OnCancel()")
                },
                onChange: (year_text:TextPickerResult) => {
                  console.info("TextPickerDialog:OnChange()"+JSON.stringify(year_text))
                }
              })
              this.searchText = '';
              this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
              this.text_1 = '全部类型';
              this.text_2 = "这里",
              this.text_2 = "默认排列"
            })

      Divider().height(10)

      Row() {
        Text('月度账单')
          .fontSize(20)
          .fontWeight(500)
          .fontColor('#EC8AA3')
          .width(100)
          .height(50)
          .textAlign(TextAlign.Center)
        Image($rawfile('yue.png'))
          .backgroundColor('$color:start_window_background')
          .width($r('app.float.component_size_MP'))
          .height($r('app.float.component_size_MP'))
      }
      .onClick(() => {
              if(this.CustomMonthPickerController!=undefined){
                this.CustomMonthPickerController.open();
              }
              this.searchText = '';
              this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
              this.text_1 = '全部类型';
              this.text_2 = "这里",
              this.text_2 = "默认排列"
            })

      Divider().height(10)

      Row() {
        Text('日用账单')
          .fontSize(20)
          .fontWeight(500)
          .fontColor('#EC8AA3')
          .width(100)
          .height(50)
          .textAlign(TextAlign.Center)
        Image($rawfile('ri.png'))
          .backgroundColor('$color:start_window_background')
          .width($r('app.float.component_size_MP'))
          .height($r('app.float.component_size_MP'))
      }
      .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2015-1-1"),
                end: new Date("2030-12-31"),
                selected: this.selected_date,
                onAccept: (value: DatePickerResult) => {
                  this.newAccount.date = value.year.toString() + '年'
                  + (value.month + 1).toString() + '月'
                  + value.day.toString() + '日'
                  this.newAccount.year = value.year.toString();
                  this.newAccount.month = value.year.toString() + ' - ' + (value.month + 1).toString();
                  this.accounts = [];
                  this.equal_accounts = [];
                  this.high_accounts = [];
                  this.cur_search_text = value.year.toString() + '-' + (value.month + 1).toString() + '-' + value.day.toString()
                  this.AccountTable.query(this.newAccount.date,(result: AccountData[]) => {
                              this.accounts = result
                              this.equal_accounts = result
                              this.high_accounts = result
                              this.accountData2ScrollData(this.accounts)
                              this.calculate(this.accounts)
                        },false);
                  console.info("DatePickerDialog: onAccept()" + JSON.stringify(value))
                },
                onCancel: () => {
                  console.info("DatePickerDialog:onCancel()")
                },
                onChange:(value: DatePickerResult) =>{
                  console.info("DatePickerDialog:onChange()"+ JSON.stringify(value))
                }
              })
              this.searchText = '';
              this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
              this.text_1 = '全部类型';
              this.text_2 = "这里",
              this.text_2 = "默认排列"
            })

    }.width(100)
  }

  @Builder CustomItem(item:ScrollData){
    Scroll(item.scroller){
      Row(){
        Row() {
          Image(ImageList[item.accountData.typeText])
            .width($r('app.float.component_size_M'))
            .aspectRatio(CommonConstants.FULL_SIZE)
            .margin({ right: $r('app.float.edge_size_MP') })
            .onClick(() => {//为已有记录绑定点击编辑事件，即可通过点击记录，对已有记录进行编辑
              this.isInsert = false;
              this.selectListItem(item.accountData)
              this.dialogController.open()
            })

          /*          Text(item.accountData.typeText)
                      .height($r('app.float.component_size_SM'))
                      .fontSize($r('app.float.font_size_M'))

                    Blank()
                      .layoutWeight(1)*/
          if (!this.isEdit) {
            Column() {
              Text(item.accountData.typeText)
                .height('22vp')
                .fontSize('16vp')
              Text(item.accountData.date + "  ")
                .fontSize('12vp')
                .fontColor('#FFFFFF')
                .align(Alignment.Start)
                .flexGrow(CommonConstants.FULL_SIZE)
            }
            .alignItems(HorizontalAlign.Start)
            .width('25%')

            Divider()
              .vertical(true)
              .height(22)
              .color('#FFFFFF')
              .opacity(1.8)
              .margin({ left: 8, right: 8 })

            Text("备注: " + item.accountData.reminder.toString())
              .fontSize('14vp')
              .fontColor('#808080')
              .align(Alignment.BottomEnd)
              .flexGrow(CommonConstants.FULL_SIZE)

            Blank()
              .layoutWeight(1)

            Text(item.accountData.accountType === 0 ? '-' + item.accountData.amount.toString() :
              '+' + item.accountData.amount.toString())
              .fontSize('16vp')
              .fontWeight(500)
              .fontColor(item.accountData.accountType === 0 ? '#FF0000' : '#FFFF00')
              .align(Alignment.End)
              .flexGrow(CommonConstants.FULL_SIZE)
          }
          else {
            Row() {
              Column() {
                Text(item.accountData.typeText)
                  .height('22vp')
                  .fontSize('16vp')
                Text(item.accountData.date + "  ")
                  .fontSize('12vp')
                  .fontColor('#FF13A6D0')
                  .align(Alignment.Start)
                  .flexGrow(CommonConstants.FULL_SIZE)
              }
              .alignItems(HorizontalAlign.Start)

              Divider()
                .vertical(true)
                .height(22)
                .color('#FF0000')
                .opacity(0.6)
                .margin({ left: 8, right: 8 })

              Text("备注: " + item.accountData.reminder.toString())
                .fontSize('12vp')
                .fontColor('#FFA6A08B')
                .align(Alignment.BottomEnd)
                .flexGrow(CommonConstants.FULL_SIZE)

              Blank()
                .layoutWeight(0.9)

              Text(item.accountData.accountType === 0 ? '-' + item.accountData.amount.toString() :
                '+' + item.accountData.amount.toString())
                .fontSize('16vp')
                .fontColor(item.accountData.accountType === 0 ? '#ff6a9f40' : 'fff54d38')
                .align(Alignment.End)
                .flexGrow(CommonConstants.FULL_SIZE)

              Toggle({ type: ToggleType.Checkbox })
                .onChange((isOn) => {
                  if (isOn) {
                    this.deleteList.push(item.accountData);
                  } else {
                    let index = this.deleteList.indexOf(item.accountData);
                    this.deleteList.splice(index, 1);
                  }
                })
            }
            .align(Alignment.End)
            .flexGrow(CommonConstants.FULL_SIZE)
            .justifyContent(FlexAlign.End)
          }

        }
        .width(CommonConstants.FULL_WIDTH)
        .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })

        Button(){
          Text('删除')
            .fontSize(25)
            .fontWeight(500)
            .fontColor(Color.White)
        }
        .type(ButtonType.Normal)
        .width(this.deleteWidth)
        .height(65)
        .backgroundColor('#FF0000')
        .onClick(() => {//当用户左滑并点击删除按钮后的点击事件
          //更新当前数据
          if(item.accountData.accountType===0) this.today_outcome-=item.accountData.amount;
          else this.today_income-=item.accountData.amount;
          this.today_earning = this.today_income - this.today_outcome;
          this.scroll_accounts.splice(this.scroll_accounts.indexOf(item),1)
          this.accounts.splice(this.accounts.indexOf(item.accountData),1)
          //将当前需要删除的记录添加到deleteList[]中
          this.deleteList.push(item.accountData);
          this.deleteListItem()
          //关闭删除按钮
          if(this.scroll2DeleteData != null){
            this.scroll2DeleteData.scroller.scrollTo({ xOffset: 0, yOffset: 0,
             animation: {duration: 100, curve: Curve.Linear } })
          }
        })
      }
      .backgroundColor('#00CCCC')
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .onTouch((event: TouchEvent) => {//触摸事件
      if(this.scroll2DeleteData != null && this.scroll2DeleteData != item){
        this.scroll2DeleteData.scroller.scrollTo({ xOffset: 0, yOffset: 0,
        animation: { duration: 100, curve: Curve.Linear } })
      }
      //根据触摸类型判断
      switch(event.type){
        case TouchType.Down: //触摸按下
          //记录按下的X轴坐标
          this.downX = event.touches[0].x
          break
        case TouchType.Up://触摸抬起
          //触摸抬起，根据X轴总偏移量，判断是否删除
          let xOffset = event.touches[0].x - this.downX
          //防止消费点击事件
        if(xOffset==0){
          return
        }
         //滑到X轴的位置
          var toxOffset = 0
         //开启删除的对象设置为null
          this.scroll2DeleteData = null;
         //偏移量超过删除按钮一半且左滑，设置打开
          if(Math.abs(xOffset) > vp2px(this.deleteWidth) / 2 && xOffset < 0){
            //删除布局宽度
            toxOffset = vp2px(this.deleteWidth)
            this.scroll2DeleteData = item
          }
         //滑动指定位置，设置动画
          item.scroller.scrollTo({ xOffset: toxOffset, yOffset: 0,
            animation: {duration: 300, curve: Curve.Linear } })
         //重置按下的x轴坐标
           this.downX = 0
           break
      }
    })
  }
  build() {
    Stack() {
      Column() {
        //顶部信息
        Row() {
          // Text($r('app.string.MainAbility_label'))
          //   .height($r('app.float.component_size_SP'))
          //   .fontSize('30vp')
          //   .fontColor('#004C99')
          //   .fontWeight('500')
          //   .margin({ left: $r('app.float.font_size_L') })

          Image($rawfile('edit.png'))
            .width('30vp')
            .aspectRatio(CommonConstants.FULL_SIZE)
            .margin({ left: $r('app.float.font_size_L') })
            .onClick(() => {
              this.isEdit = true;
            })

          Select([{ value: '默认排列', icon: $rawfile('all.png') },
            { value: '金额升序', icon: $rawfile('shouru_0.png') },
            { value: '金额降序', icon: $rawfile('zhichu_0.png') },
            { value: '日期升序', icon: $rawfile('shouru_0.png') },
            { value: '日期降序', icon: $rawfile('zhichu_0.png') }])
            .margin({right: 10})
            .value(this.text_2)
            .font({ size: 30, weight: 500 })
            .fontColor('#EC8AA3')
            .selectedOptionFont({ size: 30, weight: 500 })
            .optionFont({ size: 30, weight: 500 })
            .optionFontColor('#4a90e2')
            .optionBgColor('#50e3c2')
            .selectedOptionBgColor('#50e3c2')
            .backgroundColor('#50e3c2')
            .onSelect((index: number) => {
              console.info('Select:' + index)
              // this.accounts = []
              if (index == 0) { //默认顺序显示
                this.text_2 = "默认排列"
                this.accounts = this.equal_accounts
                this.accountData2ScrollData(this.accounts)
                // this.calculate(this.accounts)
              }
              else if (index == 1) { //按照金额的升序排列
                this.sortedbyamount(1);
              }
              else if(index == 2){ //按照金额的降序排列
                this.sortedbyamount(0);
              }
              else if (index == 3) { //按照日期的升序排列
                this.sortedbydate(1)
              }
              else { //按照日期的降序排列
                this.sortedbydate(0)
              }
              this.index = -1;
            })
        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: $r('app.float.edge_size_M'), bottom: $r('app.float.edge_size_MM') })
        //搜索栏
        Row() {
          Search({
            value: this.searchText,
            placeholder: CommonConstants.SEARCH_TEXT,
            controller: this.searchController,
          })
            .searchButton('SEARCH')
            .width(CommonConstants.FULL_WIDTH)
            .borderRadius($r('app.float.radius_size_M'))
            .borderWidth($r('app.float.border_size_S'))
            .borderColor($r('app.color.border_color'))
            .placeholderFont({ size: $r('app.float.font_size_M') })
            .textFont({ size: $r('app.float.font_size_M') })
            .backgroundColor('#00CCCC')
            .onChange((searchValue: string) => {
              this.searchText = searchValue;
            })
            .onSubmit((searchValue: string) => {
              if (searchValue != '') {
                this.accounts = [];
                this.high_accounts = [];
                this.AccountTable.queryType(String(searchValue), (result: AccountData[]) => {
                  this.accounts = result
                  this.high_accounts = result
                  this.calculate(this.accounts)
                  this.accountData2ScrollData(this.accounts)
                }, false);
                this.cur_search_text = '搜索结果'
                this.text_1 = '这里'; //这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
                this.text_1 = '全部类型';
              }
            })
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
        .margin({ top: $r('app.float.edge_size_S'), bottom: $r('app.float.edge_size_S') })
        //日期显示
        Row() {
          DateText({
            title: this.cur_search_text,
            fontSize: '30vp',
            fontColor: '#50e3c2',
            fontFamily: 'HarmonyHeiTi_Bold',
            fontWeight: 500
          }).width('58%').padding({ left: $r('app.float.edge_size_M')})
          Select([{ value: '全部类型', icon: $rawfile('all.png') },
            { value: '收入类型', icon: $rawfile('shouru_0.png') },
            { value: '支出类型', icon: $rawfile('zhichu_0.png') }])
            // .margin({right: 10})
            .value(this.text_1)
            .font({ size: 30, weight: 500 })
            .fontColor('#EC8AA3')
            .selectedOptionFont({ size: 30, weight: 500 })
            .optionFont({ size: 30, weight: 500 })
            .optionFontColor('#4a90e2')
            .optionBgColor('#50e3c2')
            .selectedOptionBgColor('#50e3c2')
            .backgroundColor('#50e3c2')
            .onSelect((index: number) => {
              console.info('Select:' + index)
              this.accounts = []
              if (index == 0) { //全部账单（包括收入与支出）
                this.AccountTable.query('', (result: AccountData[]) => {
                  const tmp_result: AccountData[] = [];
                  let k = 0;
                  for (let i = 0;i < result.length; i++) {
                    for (let j = 0;j < this.high_accounts.length; j++)
                      if (result[i].accountType == this.high_accounts[j].accountType
                      && result[i].typeText == this.high_accounts[j].typeText
                      && result[i].amount == this.high_accounts[j].amount
                      && result[i].date == this.high_accounts[j].date
                      && result[i].year == this.high_accounts[j].year
                      && result[i].month == this.high_accounts[j].month
                      && result[i].reminder == this.high_accounts[j].reminder) {
                        tmp_result[k++] = result[i];
                        break;
                      }
                  }
                  this.accounts = tmp_result
                  this.equal_accounts = tmp_result
                  this.accountData2ScrollData(this.accounts)
                  this.calculate(this.accounts)
                }, true)
              }
              else if (index == 1) { //仅收入账单
                this.AccountTable.queryaccountType(1, (result: AccountData[]) => {
                  const tmp_result: AccountData[] = [];
                  let k = 0;
                  for (let i = 0;i < result.length; i++) {
                    for (let j = 0;j < this.high_accounts.length; j++)
                      if (result[i].accountType == this.high_accounts[j].accountType
                      && result[i].typeText == this.high_accounts[j].typeText
                      && result[i].amount == this.high_accounts[j].amount
                      && result[i].date == this.high_accounts[j].date
                      && result[i].year == this.high_accounts[j].year
                      && result[i].month == this.high_accounts[j].month
                      && result[i].reminder == this.high_accounts[j].reminder) {
                        tmp_result[k++] = result[i];
                        break;
                      }
                  }
                  this.accounts = tmp_result
                  this.equal_accounts = tmp_result
                  this.accountData2ScrollData(this.accounts)
                  this.calculate(this.accounts)
                }, false)
              }
              else { //仅支出账单
                this.AccountTable.queryaccountType(0, (result: AccountData[]) => {
                  const tmp_result: AccountData[] = [];
                  let k = 0;
                  for (let i = 0;i < result.length; i++) {
                    for (let j = 0;j < this.high_accounts.length; j++)
                      if (result[i].accountType == this.high_accounts[j].accountType
                      && result[i].typeText == this.high_accounts[j].typeText
                      && result[i].amount == this.high_accounts[j].amount
                      && result[i].date == this.high_accounts[j].date
                      && result[i].year == this.high_accounts[j].year
                      && result[i].month == this.high_accounts[j].month
                      && result[i].reminder == this.high_accounts[j].reminder) {
                        tmp_result[k++] = result[i];
                        break;
                      }
                  }
                  this.accounts = tmp_result
                  this.equal_accounts = tmp_result
                  this.accountData2ScrollData(this.accounts)
                  this.calculate(this.accounts)
                }, false)
              }
              this.index = -1;
              this.text_2 = "这里",
              this.text_2 = "默认排列"
            })
        }
        .width(CommonConstants.FULL_WIDTH)
        // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
        .margin({ top: $r('app.float.edge_size_S'), bottom: $r('app.float.radius_size_S') })
        //结余与收支
        Row() {
          Column() {
            CacheText({
              amount: '结余: ' + this.today_earning.toString(),
              fontSize: '30vp',
              fontColor: '#EC8AA3',
              fontFamily: 'HarmonyHeiTi_Bold',
              fontWeight: 500
            }).padding({ left: '10vp', top: '35vp' })
            // Row() {
              CacheText({
                amount: '收入: ' + this.today_income.toString() ,
                fontSize: '20vp',
                fontColor: '#00CCCC',
                fontFamily: 'HarmonyHeiTi_Bold',
                fontWeight: 500
              }).padding({ left: '15vp', top: '20vp' })
              CacheText({
                amount: '支出: ' + this.today_outcome.toString(),
                fontSize: '20vp',
                fontColor: '#bd10e0',
                fontFamily: 'HarmonyHeiTi_Bold',
                fontWeight: 500
              }).padding({ left: '15vp', top: '20vp' })
            // }
            // .padding({ left: '20vp', top: '20vp' })
          }.width('55%').alignItems(HorizontalAlign.Start)

          Column({space: 5}) {
            Canvas(this.context)
              // 高度为半径2倍
              .height(120)
                // 纵横比，宽度和高度一样
              .aspectRatio(1)
                // 画布组件的事件回调，可以在此时进行绘制
              // .onReady(() => {
              //   this.picChartElements.forEach((item) => {
              //     // 创建一个新的控制路径
              //     this.context.beginPath()
              //     // 路径从当前点移动到指定点
              //     this.context.moveTo(60, 60)
              //     // 绘制弧线路径(弧线圆心的x坐标值,弧线圆心的y坐标值,弧线的圆半径,弧线的起始弧度,弧线的终止弧度)
              //     this.context.arc(60, 60, 60, item.beginAngle, item.endAngle)
              //     // 指定绘制的填充色
              //     this.context.fillStyle = item.color
              //     // 对封闭路径进行填充
              //     this.context.fill()
              //   })
              // })
            // ForEach(this.picChartElements, (item: PicChartElement) => {
              Row({ space: 4 }) {
                // 标注圆点颜色
                Circle({ width: 10, height: 10}).fill('#EC8AA3')
                // 标注文本
                Text('收入').fontSize(16).fontColor('#EC8AA3')
                // 标注数量
                Text(this.today_income.toString() + ' ' + this.unit).fontSize(16).fontColor('#EC8AA3')
              }
              Row({ space: 4 }) {
                // 标注圆点颜色
                Circle({ width: 10, height: 10}).fill('#50e3c2')
                // 标注文本
                Text('支出').fontSize(16).fontColor('#50e3c2')
                // 标注数量
                Text(this.today_outcome.toString() + ' ' + this.unit).fontSize(16).fontColor('#50e3c2')
              }
            // })
          }.width('100%').padding({  right: '240vp', top: '25vp' })

        }.width('100%')
        .height('25%')
        .backgroundImage($rawfile('R.png'), ImageRepeat.NoRepeat)
        .backgroundImageSize(ImageSize.Cover)
        .alignItems(HorizontalAlign.Start)
        // }

        // ForEach(this.scroll_accounts, (item: ScrollData) => {
        //   ListItem() {
        //     this.CustomItem(item)
        //   }
        //   .width(CommonConstants.FULL_WIDTH)
        //   .height('56vp')
        // })
        // }
        // .borderRadius('24vp')
        // .backgroundColor(Color.White)
        // .width(CommonConstants.FULL_WIDTH)

        //这里
        if(this.isEdit) {
          Column() {
            List({ space: CommonConstants.FULL_SIZE }) {
              ForEach(this.scroll_accounts, (item: ScrollData) => {
                ListItem() {
                  this.CustomItem(item)
                  // Row() {
                  //   Image(ImageList[item.typeText])
                  //     .width($r('app.float.component_size_M'))
                  //     .aspectRatio(CommonConstants.FULL_SIZE)
                  //     .margin({ right: $r('app.float.edge_size_MP') })
                  //
                  //   Column(){
                  //     Text(item.typeText)
                  //       .height('22vp')
                  //       .fontSize('16vp')
                  //     Text('item.date')
                  //       .fontSize('12vp')
                  //       .fontColor('#00CC00')
                  //       .align(Alignment.Start)
                  //       .flexGrow(CommonConstants.FULL_SIZE)
                  //   }
                  //   .alignItems(HorizontalAlign.Start)
                  //   Divider()
                  //     .vertical(true)
                  //     .height(22)
                  //     .color('#FF0000')
                  //     .opacity(0.6)
                  //     .margin({left: 8,right: 8})
                  //
                  //   Text("备注: " + item.reminder.toString())
                  //     .fontSize('12vp')
                  //     .fontColor('#FFA6A08B')
                  //     .align(Alignment.BottomEnd)
                  //     .flexGrow(CommonConstants.FULL_SIZE)
                  //
                  //   Blank()
                  //     .layoutWeight(1)
                  //
                  //   if (!this.isEdit) {
                  //     Text(item.accountType === 0 ? '-' + item.amount.toString() : '+' + item.amount.toString())
                  //       .fontSize($r('app.float.font_size_M'))
                  //       .fontColor(item.accountType === 0 ? $r('app.color.pay_color') : $r('app.color.main_color'))
                  //       .align(Alignment.End)
                  //       .flexGrow(CommonConstants.FULL_SIZE)
                  //   }
                  //   else {
                  //     Row() {
                  //       Toggle({ type: ToggleType.Checkbox })
                  //         .onChange((isOn) => {
                  //           if (isOn) {
                  //             this.deleteList.push(item);
                  //           } else {
                  //             let index = this.deleteList.indexOf(item);
                  //             this.deleteList.splice(index, 1);
                  //           }
                  //         })
                  //     }
                  //     .align(Alignment.End)
                  //     .flexGrow(CommonConstants.FULL_SIZE)
                  //     .justifyContent(FlexAlign.End)
                  //   }
                  //
                  // }
                  // .width(CommonConstants.FULL_WIDTH)
                  // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
                }
                .width(CommonConstants.FULL_WIDTH)
                .height($r('app.float.component_size_LM'))
                .onClick(() => { //为已有记录绑定点击选中事件，即可通过点击记录，将需要删除的数据添加到deleteList[]中
                  this.selectListItem(item.accountData);
                  this.isInsert = false;
                  this.dialogController.open();
                })
              })
            }
            .height('100%')
            .scrollBar(BarState.On)
            .cachedCount(4)
            .listDirection(Axis.Vertical) // 排列方向
            .width(CommonConstants.FULL_WIDTH)
            .borderRadius($r('app.float.radius_size_L'))
            .backgroundColor('#EC8AA3')
            // }
            // .width(CommonConstants.FULL_WIDTH)
            // // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
            // .margin({ top: $r('app.float.radius_size_S') })
          }.height('56%')
        }

      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)

      if (!this.isEdit) {
        SideBarContainer(SideBarContainerType.Overlay) { // 设置侧边栏样式为悬浮态
          Column() {                                     // 第一个子组件为侧边栏视图
            List({ space: 20 }) {
              ListItem() {
                Button() {
                  Image($rawfile('add.png'))
                }
                .backgroundColor('$color:start_window_background')
                .width($r('app.float.component_size_MP'))
                .height($r('app.float.component_size_MP'))
                // .position({ x: '85%', y: '92%' })
                .onClick(() => {
                  let cur_date = new Date()
                  this.isInsert = true;
                  this.newAccount = {
                    id: 0,
                    accountType: 0,
                    typeText: '',
                    amount: 0,
                    date: DateFormat(cur_date.getTime()),
                    year: cur_date.getFullYear().toString(),
                    month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
                    reminder: ''
                  };
                  this.dialogController.open();
                })
              }

              ListItem() {
                Button() {
                  Image($rawfile('quanbu.png'))
                }
                .backgroundColor('$color:start_window_background')
                .width($r('app.float.component_size_MP'))
                .height($r('app.float.component_size_MP'))
                .onClick(() => {
                  this.cur_search_text = '所有账单'
                  this.accounts = [];
                  this.equal_accounts = [];
                  this.high_accounts = [];
                  this.AccountTable.query('', (result: AccountData[]) => {
                    this.accounts = result
                    this.equal_accounts = result
                    this.high_accounts = result
                    this.accountData2ScrollData(this.accounts)
                    this.calculate(this.accounts)
                  }, true)
                  this.index = -1;
                  this.searchText = '';
                  this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
                  this.text_1 = '全部类型';
                  this.text_2 = "这里",
                  this.text_2 = "默认排列"
                })
              }

              ListItem() {
                Button() {
                  Image($rawfile('nian.png'))
                }
                .backgroundColor('$color:start_window_background')
                .width($r('app.float.component_size_MP'))
                .height($r('app.float.component_size_MP'))
                .onClick(() => {
                  TextPickerDialog.show({
                    range:this.years,
                    selected:this.select,
                    onAccept: (year_text: TextPickerResult) => {
                      this.select = year_text.index
                      this.accounts = [];
                      this.equal_accounts = [];
                      this.high_accounts = [];
                      this.cur_search_text = year_text.value + '年'
                      this.AccountTable.queryYear(String(year_text.value),(result: AccountData[]) => {
                        this.accounts = result
                        this.equal_accounts = result
                        this.high_accounts = result
                        this.accountData2ScrollData(this.accounts)
                        this.calculate(this.accounts)
                      },false);
                      console.info("TextPickerDialog:OnAccept()"+JSON.stringify(year_text))
                    },
                    onCancel: () =>{
                      console.info("TextPickerDialog:OnCancel()")
                    },
                    onChange: (year_text:TextPickerResult) => {
                      console.info("TextPickerDialog:OnChange()"+JSON.stringify(year_text))
                    }
                  })
                  this.searchText = '';
                  this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
                  this.text_1 = '全部类型';
                  this.text_2 = "这里",
                  this.text_2 = "默认排列"
                })
              }

              ListItem() {
                Button() {
                  Image($rawfile('yue.png'))
                }
                .backgroundColor('$color:start_window_background')
                .width($r('app.float.component_size_MP'))
                .height($r('app.float.component_size_MP'))
                .onClick(() => {
                  if(this.CustomMonthPickerController!=undefined){
                    this.CustomMonthPickerController.open();
                  }
                  this.searchText = '';
                  this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
                  this.text_1 = '全部类型';
                  this.text_2 = "这里",
                  this.text_2 = "默认排列"
                })
              }

              ListItem() {
                Button() {
                  Image($rawfile('ri.png'))
                }
                .backgroundColor('$color:start_window_background')
                .width($r('app.float.component_size_MP'))
                .height($r('app.float.component_size_MP'))
                .onClick(() => {
                  DatePickerDialog.show({
                    start: new Date("2015-1-1"),
                    end: new Date("2030-12-31"),
                    selected: this.selected_date,
                    onAccept: (value: DatePickerResult) => {
                      this.newAccount.date = value.year.toString() + '年'
                      + (value.month + 1).toString() + '月'
                      + value.day.toString() + '日'
                      this.newAccount.year = value.year.toString();
                      this.newAccount.month = value.year.toString() + ' - ' + (value.month + 1).toString();
                      this.accounts = [];
                      this.equal_accounts = [];
                      this.high_accounts = [];
                      this.cur_search_text = value.year.toString() + '-' + (value.month + 1).toString() + '-' + value.day.toString()
                      this.AccountTable.query(this.newAccount.date,(result: AccountData[]) => {
                        this.accounts = result
                        this.equal_accounts = result
                        this.high_accounts = result
                        this.accountData2ScrollData(this.accounts)
                        this.calculate(this.accounts)
                      },false);
                      console.info("DatePickerDialog: onAccept()" + JSON.stringify(value))
                    },
                    onCancel: () => {
                      console.info("DatePickerDialog:onCancel()")
                    },
                    onChange:(value: DatePickerResult) =>{
                      console.info("DatePickerDialog:onChange()"+ JSON.stringify(value))
                    }
                  })
                  this.searchText = '';
                  this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
                  this.text_1 = '全部类型';
                  this.text_2 = "这里",
                  this.text_2 = "默认排列"
                })
              }

              ListItem() {
                Button() {
                  Image($rawfile('jintian.png'))
                }
                .backgroundColor('$color:start_window_background')
                .width($r('app.float.component_size_MP'))
                .height($r('app.float.component_size_MP'))
                // .position({ x: '3%', y: '85%' })
                .onClick(() => {
                  let cur_date = new Date()
                  this.cur_search_text = '今天'
                  this.accounts = []
                  this.high_accounts = []
                  this.AccountTable.query(DateFormat(cur_date.getTime()), (result: AccountData[]) => {
                    this.accounts = result
                    this.high_accounts = result
                    this.accountData2ScrollData(this.accounts)
                    this.calculate(this.accounts)
                  }, false);
                  this.searchText = '';
                  this.text_1 = '这里'; //这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
                  this.text_1 = '全部类型';
                })
              }

              // ListItem() {
              //   Button() {
              //     Image($rawfile('sear.png'))
              //   }
              //   .backgroundColor('$color:start_window_background')
              //   .width($r('app.float.component_size_MP'))
              //   .height($r('app.float.component_size_MP'))
              //   // .position({ x: '85%', y: '85%' })
              //   .bindMenu(this.MenuBuilder)
              //   // .bindMenu([
              //   //   {
              //   //     value:THEME_NAMES[0],
              //   //     action: () => {
              //   //       this.cur_search_text = '所有账单'
              //   //       this.accounts = [];
              //   //       this.high_accounts = [];
              //   //       this.AccountTable.query('', (result: AccountData[]) => {
              //   //         this.accounts = result
              //   //         this.high_accounts = result
              //   //         this.accountData2ScrollData(this.accounts)
              //   //         this.calculate(this.accounts)
              //   //       }, true)
              //   //       this.index = -1;
              //   //       this.searchText = '';
              //   //       this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
              //   //       this.text_1 = '全部';
              //   //     }
              //   //   },
              //   //   {
              //   //     value: THEME_NAMES[1],
              //   //     action: () => {
              //   //       TextPickerDialog.show({
              //   //         range:this.years,
              //   //         selected:this.select,
              //   //         onAccept: (year_text: TextPickerResult) => {
              //   //           this.select = year_text.index
              //   //           this.accounts = [];
              //   //           this.high_accounts = [];
              //   //           this.cur_search_text = year_text.value + '年'
              //   //           this.AccountTable.queryYear(String(year_text.value),(result: AccountData[]) => {
              //   //                 this.accounts = result
              //   //                 this.high_accounts = result
              //   //                 this.accountData2ScrollData(this.accounts)
              //   //                 this.calculate(this.accounts)
              //   //           },false);
              //   //           console.info("TextPickerDialog:OnAccept()"+JSON.stringify(year_text))
              //   //         },
              //   //         onCancel: () =>{
              //   //           console.info("TextPickerDialog:OnCancel()")
              //   //         },
              //   //         onChange: (year_text:TextPickerResult) => {
              //   //           console.info("TextPickerDialog:OnChange()"+JSON.stringify(year_text))
              //   //         }
              //   //       })
              //   //       this.searchText = '';
              //   //       this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
              //   //       this.text_1 = '全部';
              //   //     }
              //   //   },
              //   //   {
              //   //     value: THEME_NAMES[2],
              //   //     action: () => {
              //   //       if(this.CustomMonthPickerController!=undefined){
              //   //         this.CustomMonthPickerController.open();
              //   //       }
              //   //       this.searchText = '';
              //   //       this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
              //   //       this.text_1 = '全部';
              //   //     }
              //   //   },
              //   //   {
              //   //     value: THEME_NAMES[3],
              //   //     action: () => {
              //   //       DatePickerDialog.show({
              //   //         start: new Date("2015-1-1"),
              //   //         end: new Date("2030-12-31"),
              //   //         selected: this.selected_date,
              //   //         onAccept: (value: DatePickerResult) => {
              //   //           this.newAccount.date = value.year.toString() + '年'
              //   //           + (value.month + 1).toString() + '月'
              //   //           + value.day.toString() + '日'
              //   //           this.newAccount.year = value.year.toString();
              //   //           this.newAccount.month = value.year.toString() + ' - ' + (value.month + 1).toString();
              //   //           this.accounts = [];
              //   //           this.high_accounts = [];
              //   //           this.cur_search_text = value.year.toString() + '年' + (value.month + 1).toString() + '月' + value.day.toString() + '日'
              //   //           this.AccountTable.query(this.newAccount.date,(result: AccountData[]) => {
              //   //                       this.accounts = result
              //   //                       this.high_accounts = result
              //   //                       this.accountData2ScrollData(this.accounts)
              //   //                       this.calculate(this.accounts)
              //   //                 },false);
              //   //           console.info("DatePickerDialog: onAccept()" + JSON.stringify(value))
              //   //         },
              //   //         onCancel: () => {
              //   //           console.info("DatePickerDialog:onCancel()")
              //   //         },
              //   //         onChange:(value: DatePickerResult) =>{
              //   //           console.info("DatePickerDialog:onChange()"+ JSON.stringify(value))
              //   //         }
              //   //       })
              //   //       this.searchText = '';
              //   //       this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
              //   //       this.text_1 = '全部';
              //   //     }
              //   //   },
              //   //   // {
              //   //   //   value:THEME_NAMES[4],
              //   //   //   action: () => {
              //   //   //   //   if(this.isTested==false){
              //   //   //   //     for(let i = 0;,i<test_accounts.length,i++){
              //   //   //   //     this.AccountTable.insertData(test_accounts[i],(i:number) => {
              //   //   //   //     this.accounts.push(test_accounts[i]);
              //   //   //   //     });
              //   //   //   //     this.scroll_accounts.push({accountData: test_accounts[i], scroller: new Scroller()});
              //   //   //   //
              //   //   //   //     if(test_accounts[i].accountType===0) this.today_outcome+=item.accountData.amount;
              //   //   //   //     else this.today_income+=item.accountData.amount;
              //   //   //   //     this.today_earning = this.today_income - this.today_outcome;
              //   //   //   //     }
              //   //   //   //   this.isTested = true;
              //   //   //   //   this.cur_search_text = "所有账单"
              //   //   //   //   }
              //   //   //   // else{
              //   //   //   //     prompt.showToast({message: CommonConstants.TOAST_TEXT_3, bottom: CommonConstants.PROMPT_BOTTOM});
              //   //   //   //  }
              //   //   //   }
              //   //   // },
              //   // ])
              // }

              ListItem() {
                Button() {
                  Image($rawfile('amount.png'))
                }
                .backgroundColor('$color:start_window_background')
                .width($r('app.float.component_size_MP'))
                .height($r('app.float.component_size_MP'))
                // .position({ x: '85%', y: '78%' })
                .onClick(() => {
                  // this.searchDialogController.open()
                  if (this.CustomAmountRangePickerController != undefined) {
                    this.CustomAmountRangePickerController.open();
                  }
                  // this.searchText = '';
                  // this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
                  // this.text_1 = '全部类型';
                })
              }

              ListItem() {
                  Button() {
                    Image($rawfile('riqi.png'))
                  }
                  .backgroundColor('$color:start_window_background')
                  .width($r('app.float.component_size_MP'))
                  .height($r('app.float.component_size_MP'))
                  // .position({ x: '3%', y: '78%' })
                  .onClick(() => {
                    let cur_date = new Date()
                    this.newAccount1 = {
                      id: 0,
                      accountType: 0,
                      typeText: '',
                      amount: 0,
                      date: DateFormat(cur_date.getTime()),
                      year: cur_date.getFullYear().toString(),
                      month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
                      reminder: ''
                    };
                    this.newAccount2 = {
                      id: 0,
                      accountType: 0,
                      typeText: '',
                      amount: 0,
                      date: DateFormat(cur_date.getTime()),
                      year: cur_date.getFullYear().toString(),
                      month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
                      reminder: ''
                    };
                    if (this.CustomDateRangePickerController != undefined) {
                      this.CustomDateRangePickerController.open();
                    }
                    // this.searchText = '';
                    // this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
                    // this.text_1 = '全部类型';
                  })
                }

              ListItem() {
                Button() {
                  Image($rawfile('set.png'))
                }
                .backgroundColor('$color:start_window_background')
                .width($r('app.float.component_size_MP'))
                .height($r('app.float.component_size_MP'))
                // .position({ x: '3%', y: '92%' })
                .onClick(() => {
                  let cur_date = new Date()
                  const tmp_new_accounts: AccountData[] = [
                    {
                      id: 0,
                      accountType: 0,
                      typeText: '餐饮',
                      amount: 87,
                      date: DateFormat(cur_date.getTime()),
                      year: cur_date.getFullYear().toString(),
                      month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
                      reminder: 'ss'
                    },
                    {
                      id: 0,
                      accountType: 1,
                      typeText: '奖学金',
                      amount: 5000,
                      date: '2023年10月10日',
                      year: cur_date.getFullYear().toString(),
                      month: '2023-10',
                      reminder: 'g'
                    },
                    {
                      id: 0,
                      accountType: 0,
                      typeText: '水费',
                      amount: 37,
                      date: '2022年11月21日',
                      year: '2022',
                      month: '2022-11',
                      reminder: 'gg'
                    },
                    {
                      id: 0,
                      accountType: 1,
                      typeText: '工资',
                      amount: 6540,
                      date: DateFormat(cur_date.getTime()),
                      year: cur_date.getFullYear().toString(),
                      month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
                      reminder: 'cqu'
                    },
                    {
                      id: 0,
                      accountType: 0,
                      typeText: '旅行',
                      amount: 8000,
                      date: '2024年12月23日',
                      year: '2024',
                      month: '2024-12',
                      reminder: 'cq'
                    },
                    {
                      id: 0,
                      accountType: 1,
                      typeText: '投资',
                      amount: 678,
                      date: '2023年11月11日',
                      year: cur_date.getFullYear().toString(),
                      month: '2023-11',
                      reminder: 'hhh'
                    },
                    {
                      id: 0,
                      accountType: 0,
                      typeText: '约会',
                      amount: 999,
                      date: '2022年12月22日',
                      year: '2022',
                      month: '2022-12',
                      reminder: 'ee'
                    },
                    {
                      id: 0,
                      accountType: 1,
                      typeText: '理财',
                      amount: 666,
                      date: '2023年10月18日',
                      year: cur_date.getFullYear().toString(),
                      month: '2023-10',
                      reminder: 's'
                    },
                    {
                      id: 0,
                      accountType: 1,
                      typeText: '红包',
                      amount: 888,
                      date: '2023年12月12日',
                      year: cur_date.getFullYear().toString(),
                      month: '2023-12',
                      reminder: 'sss'
                    }
                  ];
                  for (let i = 0;i < tmp_new_accounts.length; i++) {
                    this.accept(true, tmp_new_accounts[i]);
                  }
                  this.cur_search_text = '所有账单'
                  this.accounts = [];
                  this.high_accounts = [];
                  this.AccountTable.query('', (result: AccountData[]) => {
                    this.accounts = result
                    this.high_accounts = result
                    this.accountData2ScrollData(this.accounts)
                    this.calculate(this.accounts)
                  }, true)
                  this.index = -1;
                  this.searchText = '';
                  this.text_1 = '这里'; //这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
                  this.text_1 = '全部类型';

                })
              }

            }
            .height('100%')
            .scrollBar(BarState.On)
            .cachedCount(5)
            .listDirection(Axis.Vertical) // 排列方向
            .width(CommonConstants.FULL_WIDTH)
            .borderRadius($r('app.float.radius_size_L'))
            .backgroundColor('#EC8AA3')
            // .position({ x: '0%', y: '93%' })
          }
          .padding({top: 70})
          .width(50)
          // .height("40%")
          .backgroundColor('#EC8AA3')


          Column() { //内容区域
            List({ space: CommonConstants.FULL_SIZE }) {
              ForEach(this.scroll_accounts, (item: ScrollData) => {
                ListItem() {
                  this.CustomItem(item)
                  // Row() {
                  //   Image(ImageList[item.typeText])
                  //     .width($r('app.float.component_size_M'))
                  //     .aspectRatio(CommonConstants.FULL_SIZE)
                  //     .margin({ right: $r('app.float.edge_size_MP') })
                  //
                  //   Column(){
                  //     Text(item.typeText)
                  //       .height('22vp')
                  //       .fontSize('16vp')
                  //     Text('item.date')
                  //       .fontSize('12vp')
                  //       .fontColor('#00CC00')
                  //       .align(Alignment.Start)
                  //       .flexGrow(CommonConstants.FULL_SIZE)
                  //   }
                  //   .alignItems(HorizontalAlign.Start)
                  //   Divider()
                  //     .vertical(true)
                  //     .height(22)
                  //     .color('#FF0000')
                  //     .opacity(0.6)
                  //     .margin({left: 8,right: 8})
                  //
                  //   Text("备注: " + item.reminder.toString())
                  //     .fontSize('12vp')
                  //     .fontColor('#FFA6A08B')
                  //     .align(Alignment.BottomEnd)
                  //     .flexGrow(CommonConstants.FULL_SIZE)
                  //
                  //   Blank()
                  //     .layoutWeight(1)
                  //
                  //   if (!this.isEdit) {
                  //     Text(item.accountType === 0 ? '-' + item.amount.toString() : '+' + item.amount.toString())
                  //       .fontSize($r('app.float.font_size_M'))
                  //       .fontColor(item.accountType === 0 ? $r('app.color.pay_color') : $r('app.color.main_color'))
                  //       .align(Alignment.End)
                  //       .flexGrow(CommonConstants.FULL_SIZE)
                  //   }
                  //   else {
                  //     Row() {
                  //       Toggle({ type: ToggleType.Checkbox })
                  //         .onChange((isOn) => {
                  //           if (isOn) {
                  //             this.deleteList.push(item);
                  //           } else {
                  //             let index = this.deleteList.indexOf(item);
                  //             this.deleteList.splice(index, 1);
                  //           }
                  //         })
                  //     }
                  //     .align(Alignment.End)
                  //     .flexGrow(CommonConstants.FULL_SIZE)
                  //     .justifyContent(FlexAlign.End)
                  //   }
                  //
                  // }
                  // .width(CommonConstants.FULL_WIDTH)
                  // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
                }
                .width(CommonConstants.FULL_WIDTH)
                .height($r('app.float.component_size_LM'))
                .onClick(() => { //为已有记录绑定点击编辑事件，即可通过点击记录，对已有记录进行编辑
                  this.selectListItem(item.accountData);
                  this.isInsert = false;
                  this.dialogController.open();
                })
              })
            }
            .height('100%')
            .scrollBar(BarState.On)
            .cachedCount(4)
            .listDirection(Axis.Vertical) // 排列方向
            .width(CommonConstants.FULL_WIDTH)
            .borderRadius($r('app.float.radius_size_L'))
            .backgroundColor('#EC8AA3')
            // }
            // .width(CommonConstants.FULL_WIDTH)
            // // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
            // .margin({ top: $r('app.float.radius_size_S') })
          }.height('58%')
        }
        .width('100%')
        .height('51%')
        .position({x: 0, y: '49.3%'})
        .sideBarWidth(50)                               // 设置侧边栏宽度为50
        .minSideBarWidth(50)                            // 设置侧边栏最小宽度为100
        .maxSideBarWidth(200)                            // 设置侧边栏最大宽度为200
        .controlButton({                                 // 设置侧边栏控制按钮的样式
          width: 50,      // 设置侧边栏控制按钮宽度为30
          height: 50,     // 设置侧边栏控制按钮高度为30
          top: 10, // 设置侧边栏控制按钮距离容器顶部为15
          left: 0,
          icons: {                                       // 设置侧边栏控制按钮图片
            shown: $rawfile('shouqicaidan.png'),            // 设置侧边栏显示时控制按钮的图标。
            hidden: $rawfile('zhankaicaidan.png'),           // 设置侧边栏隐藏时控制按钮的图标。
            switching: $rawfile('shouqicaidan.png')         // 设置侧边栏显示和隐藏状态切换时控制按钮的图标。
          }
        })


            // List({ space: 20 }) {
            //   ListItem() {
            //     Button() {
            //       Image($rawfile('add.png'))
            //     }
            //     .backgroundColor('$color:start_window_background')
            //     .width($r('app.float.component_size_MP'))
            //     .height($r('app.float.component_size_MP'))
            //     // .position({ x: '85%', y: '92%' })
            //     .onClick(() => {
            //       let cur_date = new Date()
            //       this.isInsert = true;
            //       this.newAccount = {
            //         id: 0,
            //         accountType: 0,
            //         typeText: '',
            //         amount: 0,
            //         date: DateFormat(cur_date.getTime()),
            //         year: cur_date.getFullYear().toString(),
            //         month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
            //         reminder: ''
            //       };
            //       this.dialogController.open();
            //     })
            //   }
            //
            //   ListItem() {
            //     Button() {
            //       Image($rawfile('sear.png'))
            //     }
            //     .backgroundColor('$color:start_window_background')
            //     .width($r('app.float.component_size_MP'))
            //     .height($r('app.float.component_size_MP'))
            //     // .position({ x: '85%', y: '85%' })
            //     .bindMenu(this.MenuBuilder)
            //     // .bindMenu([
            //     //   {
            //     //     value:THEME_NAMES[0],
            //     //     action: () => {
            //     //       this.cur_search_text = '所有账单'
            //     //       this.accounts = [];
            //     //       this.high_accounts = [];
            //     //       this.AccountTable.query('', (result: AccountData[]) => {
            //     //         this.accounts = result
            //     //         this.high_accounts = result
            //     //         this.accountData2ScrollData(this.accounts)
            //     //         this.calculate(this.accounts)
            //     //       }, true)
            //     //       this.index = -1;
            //     //       this.searchText = '';
            //     //       this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
            //     //       this.text_1 = '全部';
            //     //     }
            //     //   },
            //     //   {
            //     //     value: THEME_NAMES[1],
            //     //     action: () => {
            //     //       TextPickerDialog.show({
            //     //         range:this.years,
            //     //         selected:this.select,
            //     //         onAccept: (year_text: TextPickerResult) => {
            //     //           this.select = year_text.index
            //     //           this.accounts = [];
            //     //           this.high_accounts = [];
            //     //           this.cur_search_text = year_text.value + '年'
            //     //           this.AccountTable.queryYear(String(year_text.value),(result: AccountData[]) => {
            //     //                 this.accounts = result
            //     //                 this.high_accounts = result
            //     //                 this.accountData2ScrollData(this.accounts)
            //     //                 this.calculate(this.accounts)
            //     //           },false);
            //     //           console.info("TextPickerDialog:OnAccept()"+JSON.stringify(year_text))
            //     //         },
            //     //         onCancel: () =>{
            //     //           console.info("TextPickerDialog:OnCancel()")
            //     //         },
            //     //         onChange: (year_text:TextPickerResult) => {
            //     //           console.info("TextPickerDialog:OnChange()"+JSON.stringify(year_text))
            //     //         }
            //     //       })
            //     //       this.searchText = '';
            //     //       this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
            //     //       this.text_1 = '全部';
            //     //     }
            //     //   },
            //     //   {
            //     //     value: THEME_NAMES[2],
            //     //     action: () => {
            //     //       if(this.CustomMonthPickerController!=undefined){
            //     //         this.CustomMonthPickerController.open();
            //     //       }
            //     //       this.searchText = '';
            //     //       this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
            //     //       this.text_1 = '全部';
            //     //     }
            //     //   },
            //     //   {
            //     //     value: THEME_NAMES[3],
            //     //     action: () => {
            //     //       DatePickerDialog.show({
            //     //         start: new Date("2015-1-1"),
            //     //         end: new Date("2030-12-31"),
            //     //         selected: this.selected_date,
            //     //         onAccept: (value: DatePickerResult) => {
            //     //           this.newAccount.date = value.year.toString() + '年'
            //     //           + (value.month + 1).toString() + '月'
            //     //           + value.day.toString() + '日'
            //     //           this.newAccount.year = value.year.toString();
            //     //           this.newAccount.month = value.year.toString() + ' - ' + (value.month + 1).toString();
            //     //           this.accounts = [];
            //     //           this.high_accounts = [];
            //     //           this.cur_search_text = value.year.toString() + '年' + (value.month + 1).toString() + '月' + value.day.toString() + '日'
            //     //           this.AccountTable.query(this.newAccount.date,(result: AccountData[]) => {
            //     //                       this.accounts = result
            //     //                       this.high_accounts = result
            //     //                       this.accountData2ScrollData(this.accounts)
            //     //                       this.calculate(this.accounts)
            //     //                 },false);
            //     //           console.info("DatePickerDialog: onAccept()" + JSON.stringify(value))
            //     //         },
            //     //         onCancel: () => {
            //     //           console.info("DatePickerDialog:onCancel()")
            //     //         },
            //     //         onChange:(value: DatePickerResult) =>{
            //     //           console.info("DatePickerDialog:onChange()"+ JSON.stringify(value))
            //     //         }
            //     //       })
            //     //       this.searchText = '';
            //     //       this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
            //     //       this.text_1 = '全部';
            //     //     }
            //     //   },
            //     //   // {
            //     //   //   value:THEME_NAMES[4],
            //     //   //   action: () => {
            //     //   //   //   if(this.isTested==false){
            //     //   //   //     for(let i = 0;,i<test_accounts.length,i++){
            //     //   //   //     this.AccountTable.insertData(test_accounts[i],(i:number) => {
            //     //   //   //     this.accounts.push(test_accounts[i]);
            //     //   //   //     });
            //     //   //   //     this.scroll_accounts.push({accountData: test_accounts[i], scroller: new Scroller()});
            //     //   //   //
            //     //   //   //     if(test_accounts[i].accountType===0) this.today_outcome+=item.accountData.amount;
            //     //   //   //     else this.today_income+=item.accountData.amount;
            //     //   //   //     this.today_earning = this.today_income - this.today_outcome;
            //     //   //   //     }
            //     //   //   //   this.isTested = true;
            //     //   //   //   this.cur_search_text = "所有账单"
            //     //   //   //   }
            //     //   //   // else{
            //     //   //   //     prompt.showToast({message: CommonConstants.TOAST_TEXT_3, bottom: CommonConstants.PROMPT_BOTTOM});
            //     //   //   //  }
            //     //   //   }
            //     //   // },
            //     // ])
            //   }
            //
            //   ListItem() {
            //     Button() {
            //       Image($rawfile('amount.png'))
            //     }
            //     .backgroundColor('$color:start_window_background')
            //     .width($r('app.float.component_size_MP'))
            //     .height($r('app.float.component_size_MP'))
            //     // .position({ x: '85%', y: '78%' })
            //     .onClick(() => {
            //       // this.searchDialogController.open()
            //       if (this.CustomAmountRangePickerController != undefined) {
            //         this.CustomAmountRangePickerController.open();
            //       }
            //       // this.searchText = '';
            //       // this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
            //       // this.text_1 = '全部类型';
            //     })
            //   }
            //
            //
            //   ListItem() {
            //     Button() {
            //       Image($rawfile('set.png'))
            //     }
            //     .backgroundColor('$color:start_window_background')
            //     .width($r('app.float.component_size_MP'))
            //     .height($r('app.float.component_size_MP'))
            //     // .position({ x: '3%', y: '92%' })
            //     .onClick(() => {
            //       let cur_date = new Date()
            //       const tmp_new_accounts: AccountData[] = [
            //         {
            //           id: 0,
            //           accountType: 0,
            //           typeText: '餐饮',
            //           amount: 87,
            //           date: DateFormat(cur_date.getTime()),
            //           year: cur_date.getFullYear().toString(),
            //           month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
            //           reminder: '好吃'
            //         },
            //         {
            //           id: 0,
            //           accountType: 1,
            //           typeText: '奖学金',
            //           amount: 5000,
            //           date: '2023年10月10日',
            //           year: cur_date.getFullYear().toString(),
            //           month: '2023-10',
            //           reminder: '刚刚'
            //         },
            //         {
            //           id: 0,
            //           accountType: 0,
            //           typeText: '水费',
            //           amount: 37,
            //           date: '2022年11月21日',
            //           year: '2022',
            //           month: '2022-11',
            //           reminder: '水水水'
            //         },
            //         {
            //           id: 0,
            //           accountType: 1,
            //           typeText: '工资',
            //           amount: 6540,
            //           date: DateFormat(cur_date.getTime()),
            //           year: cur_date.getFullYear().toString(),
            //           month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
            //           reminder: '好好'
            //         },
            //         {
            //           id: 0,
            //           accountType: 0,
            //           typeText: '旅行',
            //           amount: 8000,
            //           date: '2024年12月23日',
            //           year: '2024',
            //           month: '2024-12',
            //           reminder: '好玩'
            //         },
            //         {
            //           id: 0,
            //           accountType: 1,
            //           typeText: '投资',
            //           amount: 678,
            //           date: '2023年11月11日',
            //           year: cur_date.getFullYear().toString(),
            //           month: '2023-11',
            //           reminder: '小赚'
            //         },
            //         {
            //           id: 0,
            //           accountType: 0,
            //           typeText: '约会',
            //           amount: 999,
            //           date: '2022年12月22日',
            //           year: '2022',
            //           month: '2022-12',
            //           reminder: '嗯嗯'
            //         },
            //         {
            //           id: 0,
            //           accountType: 1,
            //           typeText: '理财',
            //           amount: 666,
            //           date: '2023年10月18日',
            //           year: cur_date.getFullYear().toString(),
            //           month: '2023-10',
            //           reminder: '刚刚'
            //         },
            //         {
            //           id: 0,
            //           accountType: 1,
            //           typeText: '红包',
            //           amount: 888,
            //           date: '2023年12月12日',
            //           year: cur_date.getFullYear().toString(),
            //           month: '2023-12',
            //           reminder: '恭喜发财'
            //         }
            //       ];
            //       for (let i = 0;i < tmp_new_accounts.length; i++) {
            //         this.accept(true, tmp_new_accounts[i]);
            //       }
            //       this.cur_search_text = '所有账单'
            //       this.accounts = [];
            //       this.high_accounts = [];
            //       this.AccountTable.query('', (result: AccountData[]) => {
            //         this.accounts = result
            //         this.high_accounts = result
            //         this.accountData2ScrollData(this.accounts)
            //         this.calculate(this.accounts)
            //       }, true)
            //       this.index = -1;
            //       this.searchText = '';
            //       this.text_1 = '这里'; //这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
            //       this.text_1 = '全部类型';
            //
            //     })
            //   }
            //
            //   ListItem() {
            //     Button() {
            //       Image($rawfile('jintian.png'))
            //     }
            //     .backgroundColor('$color:start_window_background')
            //     .width($r('app.float.component_size_MP'))
            //     .height($r('app.float.component_size_MP'))
            //     // .position({ x: '3%', y: '85%' })
            //     .onClick(() => {
            //       let cur_date = new Date()
            //       this.cur_search_text = '今天'
            //       this.accounts = []
            //       this.high_accounts = []
            //       this.AccountTable.query(DateFormat(cur_date.getTime()), (result: AccountData[]) => {
            //         this.accounts = result
            //         this.high_accounts = result
            //         this.accountData2ScrollData(this.accounts)
            //         this.calculate(this.accounts)
            //       }, false);
            //       this.searchText = '';
            //       this.text_1 = '这里'; //这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
            //       this.text_1 = '全部类型';
            //     })
            //   }
            //
            //   ListItem() {
            //     Button() {
            //       Image($rawfile('riqi.png'))
            //     }
            //     .backgroundColor('$color:start_window_background')
            //     .width($r('app.float.component_size_MP'))
            //     .height($r('app.float.component_size_MP'))
            //     // .position({ x: '3%', y: '78%' })
            //     .onClick(() => {
            //       let cur_date = new Date()
            //       this.newAccount1 = {
            //         id: 0,
            //         accountType: 0,
            //         typeText: '',
            //         amount: 0,
            //         date: DateFormat(cur_date.getTime()),
            //         year: cur_date.getFullYear().toString(),
            //         month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
            //         reminder: ''
            //       };
            //       this.newAccount2 = {
            //         id: 0,
            //         accountType: 0,
            //         typeText: '',
            //         amount: 0,
            //         date: DateFormat(cur_date.getTime()),
            //         year: cur_date.getFullYear().toString(),
            //         month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
            //         reminder: ''
            //       };
            //       if (this.CustomDateRangePickerController != undefined) {
            //         this.CustomDateRangePickerController.open();
            //       }
            //       // this.searchText = '';
            //       // this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
            //       // this.text_1 = '全部类型';
            //     })
            //   }
            //
            //   ListItem() {
            //     Button() {
            //       Image($rawfile('riqi.png'))
            //     }
            //     .backgroundColor('$color:start_window_background')
            //     .width($r('app.float.component_size_MP'))
            //     .height($r('app.float.component_size_MP'))
            //     // .position({ x: '3%', y: '78%' })
            //     .onClick(() => {
            //       let cur_date = new Date()
            //       this.newAccount1 = {
            //         id: 0,
            //         accountType: 0,
            //         typeText: '',
            //         amount: 0,
            //         date: DateFormat(cur_date.getTime()),
            //         year: cur_date.getFullYear().toString(),
            //         month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
            //         reminder: ''
            //       };
            //       this.newAccount2 = {
            //         id: 0,
            //         accountType: 0,
            //         typeText: '',
            //         amount: 0,
            //         date: DateFormat(cur_date.getTime()),
            //         year: cur_date.getFullYear().toString(),
            //         month: cur_date.getFullYear().toString() + '-' + (cur_date.getMonth() + 1).toString(),
            //         reminder: ''
            //       };
            //       if (this.CustomDateRangePickerController != undefined) {
            //         this.CustomDateRangePickerController.open();
            //       }
            //       // this.searchText = '';
            //       // this.text_1 = '这里';//这里是为了引起this.text_1的状态变化而加上的中间过程，主要是为了触发State的相关事件
            //       // this.text_1 = '全部类型';
            //     })
            //   }
            // }
            // .height(50)
            // .scrollBar(BarState.On)
            // .cachedCount(4)
            // .listDirection(Axis.Horizontal) // 排列方向
            // .width(CommonConstants.FULL_WIDTH)
            // .borderRadius($r('app.float.radius_size_L'))
            // .backgroundColor('#EC8AA3')
            // .position({ x: '0%', y: '93%' })
      }
        if (this.isEdit) {
          Button() {
            Image($rawfile('delete.png'))
          }
          .width($r('app.float.component_size_MP'))
          .height($r('app.float.component_size_MP'))
          .backgroundColor($r('app.color.background_color'))
          .markAnchor({ x: $r('app.float.mark_anchor'), y: CommonConstants.MINIMUM_SIZE })
          .position({ x: CommonConstants.DELETE_POSITION_X, y: CommonConstants.DELETE_POSITION_Y })
          .onClick(() => {
            this.deleteListItem();
            // this.accounts = this.accounts
          })
        }

    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor('#EC8AA3')
    // .backgroundColor($r('app.color.background_color'))
  }
}