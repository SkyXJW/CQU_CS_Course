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

import prompt from '@ohos.promptAction';
import AccountData from '../viewmodel/AccountData';
import AccountItem from '../viewmodel/AccountItem';
import CommonConstants from '../common/constants/CommonConstants';
import { PayList, EarnList } from '../viewmodel/AccountList';


@CustomDialog
export struct DialogComponent {
  controller?: CustomDialogController;
  @Link isInsert: boolean;
  @Link newAccount: AccountData;
  confirm?: (isInsert: boolean, newAccount: AccountData) => void;
  private scroller: Scroller = new Scroller();
  private inputAmount = '';
  private inputRemind = '';
  selected_date: Date;

  @State payList: Array<AccountItem> = PayList;
  @State earnList: Array<AccountItem> = EarnList;
  @State bgColor: string = '';
  @State curIndex: number = 0;
  @State curType: string = '';
  @State curDate: string = '';
  @State curYear: string = '';
  @State curMonth: string = '';
  @State curReminder: string = '';

  @Builder
  TabBuilder(index: number) {
    Row() {
      Text(index === 0 ? $r('app.string.pay_text') : $r('app.string.income_text'))
        .fontSize(25)
        .width('50vp')
        .height('50vp')
        // .fontSize($r('app.float.font_size_M'))
        .fontColor(this.curIndex === index ? '#9013fe' : Color.Gray)

      Image(index === 0 ? (this.curIndex === index ? $rawfile('zhichu.png') : $rawfile('zhichu_1.png')) : (this.curIndex === index ? $rawfile('shouru.png') : $rawfile('shouru_1.png')))
        .backgroundColor('$color:start_window_background')
        .width('34vp')
        .height('34vp')
    }
    .width($r('app.float.component_size_MP'))
    .padding({ top: $r('app.float.edge_size_S'), bottom: $r('app.float.edge_size_S') })
    .margin({ bottom: $r('app.float.edge_size_S') })
    // .border(this.curIndex === index ? {
    //   width: { bottom: '2vp' },
    //   color: $r('app.color.main_color')
    // } : { color: Color.White })
  }

  aboutToAppear() {
    this.inputAmount = this.newAccount.amount.toString();
    this.inputRemind = this.newAccount.reminder;
    this.curIndex = this.newAccount.accountType;
    this.curType = this.newAccount.typeText;
    this.curDate = this.newAccount.date;
    this.curYear = this.newAccount.year;
    this.curMonth = this.newAccount.month;
    this.curReminder = this.newAccount.reminder;
  }

  selectAccount(item: AccountItem) {
    this.newAccount.accountType = item.accountType;
    this.newAccount.typeText = item.typeText;
    this.curType = item.typeText;
  }

  build() {
    Column() {
      Image($rawfile('half.png'))
        .width($r('app.float.component_size_L'))
        .height($r('app.float.component_size_S'))
        .onClick(() => {
          this.controller?.close();
        })

      Tabs({ barPosition: BarPosition.Start, index: this.curIndex }) {
        TabContent() {
          Scroll(this.scroller) {
            Row() {
              ForEach(this.payList, (item: AccountItem) => {
                Column() {
                  Image(this.curType === item.typeText ? item.iconSelected : item.icon)
                    .width($r('app.float.image_size'))
                    .aspectRatio(CommonConstants.FULL_SIZE)

                  Text(item.typeText)
                    .fontSize($r('app.float.font_size_S'))
                    .fontColor(this.curType === item.typeText ? '#EC8AA3' : '#FFFFFF')
                    .margin({ top: $r('app.float.edge_size_S') })
                }
                .width($r('app.float.component_size_LP'))
                .aspectRatio(CommonConstants.FULL_SIZE)
                .padding({ top: $r('app.float.edge_size_M') })
                .margin({ top: $r('app.float.edge_size_MP'), left: $r('app.float.edge_size_M') })
                .align(Alignment.TopStart)
                .backgroundColor(this.curType === item.typeText ? '#50e3c2' : '#EC8AA3')
                .borderRadius($r('app.float.radius_size_S'))
                .onClick(() => {
                  this.selectAccount(item);
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .tabBar(this.TabBuilder(0))
        .margin({ bottom: $r('app.float.edge_size_LP') })

        TabContent() {
          Scroll(this.scroller) {
            Row() {
              ForEach(this.earnList, (item: AccountItem) => {
                Column() {
                  Image(this.curType === item.typeText ? item.iconSelected : item.icon)
                    .width($r('app.float.image_size'))
                    .aspectRatio(CommonConstants.FULL_SIZE)

                  Text(item.typeText)
                    .fontSize($r('app.float.font_size_S'))
                    .fontColor(this.curType === item.typeText ? '#EC8AA3' : '#FFFFFF')
                    .margin({ top: $r('app.float.edge_size_S') })
                }
                .width($r('app.float.component_size_LP'))
                .aspectRatio(CommonConstants.FULL_SIZE)
                .padding({ top: $r('app.float.edge_size_M') })
                .margin({ top: $r('app.float.edge_size_MP'), left: $r('app.float.edge_size_M') })
                .align(Alignment.TopStart)
                .backgroundColor(this.curType === item.typeText ? '#50e3c2': '#EC8AA3')
                .borderRadius($r('app.float.radius_size_S'))
                .onClick(() => {
                  this.selectAccount(item);
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .tabBar(this.TabBuilder(1))
        .margin({ bottom: $r('app.float.edge_size_LP') })
      }
      .width(CommonConstants.FULL_WIDTH)
      .height('30%')
      .vertical(false)
      .barMode(BarMode.Fixed)
      .onChange((index) => {
        this.curIndex = index;
      })

      // Tabs({ barPosition: BarPosition.End}) {
        // TabContent(){
          // Scroll(this.scroller) {
            Column() {
              // Column() {
              //金额输入
                Row() {
                  Text('金额')
                    .fontSize(25)
                    .width('50vp')
                    .height('50vp')
                    .fontColor('#f8e71c')
                    .padding({ left: CommonConstants.MINIMUM_SIZE })
                  Row() {
                    TextInput({
                      placeholder: $r('app.string.input_text'),
                      text: this.inputAmount
                      // text: this.newAccount.amount === 0 ? this.inputAmount : this.newAccount.amount.toString()
                    })
                      .textAlign(TextAlign.Center)
                      // .padding({ left: $r('app.float.edge_size_M') })
                      .width('290vp')
                      .borderRadius(CommonConstants.MINIMUM_SIZE)
                      .backgroundColor('#EC8AA3')
                      .type(InputType.Number)
                      .onChange((value: string) => {
                        this.inputAmount = value;
                      })

                    Image($rawfile('jine.png'))
                      .backgroundColor('$color:start_window_background')
                      .width('38vp')
                      .height('38vp')
                  }
                  .borderWidth({ bottom: CommonConstants.FULL_SIZE })
                  .borderColor($r('app.color.border_color'))
                }
                .width(CommonConstants.FULL_WIDTH)
                .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') , bottom: '24vp'})
              // Column() {
              //   TextInput({
              //     placeholder: $r('app.string.input_text'),
              //     text: this.inputAmount
              //     // text: this.newAccount.amount === 0 ? this.inputAmount : this.newAccount.amount.toString()
              //   })
              //     .padding({ left: $r('app.float.edge_size_M') })
              //     .borderRadius(CommonConstants.MINIMUM_SIZE)
              //     .backgroundColor(Color.White)
              //     .type(InputType.Number)
              //     .onChange((value: string) => {
              //       this.inputAmount = value;
              //     })
              // }
              // .height($r('app.float.component_size_MP'))
              // .padding({ top: $r('app.float.edge_size_MPM'), bottom: $r('app.float.edge_size_MM') })
              // .borderWidth({ bottom: CommonConstants.FULL_SIZE })
              // .borderColor($r('app.color.border_color'))
              // }
              // .width(CommonConstants.FULL_WIDTH)
              // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })

              Row() {
                Text('日期')
                  .fontSize(25)
                  .width('50vp')
                  .height('50vp')
                  .fontColor('#417505')
                  .padding({ left: CommonConstants.MINIMUM_SIZE })
                Row() {
                  Text(this.newAccount.date)
                    .width('290vp')
                    .textAlign(TextAlign.Center)
                    // .padding({ left: $r('app.float.edge_size_M') })
                    .borderRadius(CommonConstants.MINIMUM_SIZE)
                    .backgroundColor('#EC8AA3')
                    .onClick(() => {
                      let cur_date = new Date()
                      this.selected_date = cur_date
                      DatePickerDialog.show({
                        start: new Date("2015-1-1"),
                        end: new Date("2030-12-31"),
                        selected: this.selected_date,
                        onAccept: (value: DatePickerResult) => {
                          //通过Date的setFullYear方法设置按下按钮时的日期
                          this.selected_date.setFullYear(value.year, value.month, value.day)
                          this.newAccount.date = value.year.toString() + '年'
                          + (value.month + 1).toString() + '月'
                          + value.day.toString() + '日'
                          this.newAccount.year = value.year.toString();
                          this.newAccount.month = value.year.toString() + '-' + (value.month + 1).toString();
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

                  Image($rawfile('calendar.png'))
                    .backgroundColor('$color:start_window_background')
                    .width('38vp')
                    .height('38vp')
                }
                .borderWidth({ bottom: CommonConstants.FULL_SIZE })
                .borderColor($r('app.color.border_color'))
              }
              .width(CommonConstants.FULL_WIDTH)
              .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') , bottom: '24vp'})

              // Column() {
              // //日期输入
              // Text("时间")
              //   .width(CommonConstants.FULL_WIDTH)
              //   .fontSize("20vp")
              //   .fontColor(Color.Black)
              //   .padding({ left: CommonConstants.MINIMUM_SIZE ,top: $r('app.float.edge_size_M')})
              // Column() {
              //   Text(this.newAccount.date)
              //     .padding({ left: $r('app.float.edge_size_M') })
              //     .borderRadius(CommonConstants.MINIMUM_SIZE)
              //     .backgroundColor(Color.White)
              //     .onClick(() => {
              //       let cur_date = new Date()
              //       this.selected_date = cur_date
              //       DatePickerDialog.show({
              //         start: new Date("2015-1-1"),
              //         end: new Date("2030-12-31"),
              //         selected: this.selected_date,
              //         onAccept: (value: DatePickerResult) => {
              //           //通过Date的setFullYear方法设置按下按钮时的日期
              //           this.selected_date.setFullYear(value.year, value.month, value.day)
              //           this.newAccount.date = value.year.toString() + '年'
              //                                  + (value.month + 1).toString() + '月'
              //                                  + value.day.toString() + '日'
              //           this.newAccount.year = value.year.toString();
              //           this.newAccount.month = value.year.toString() + '-' + (value.month + 1).toString();
              //           console.info("DatePickerDialog: onAccept()" + JSON.stringify(value))
              //         },
              //         onCancel: () => {
              //           console.info("DatePickerDialog:onCancel()")
              //         },
              //         onChange:(value: DatePickerResult) =>{
              //           console.info("DatePickerDialog:onChange()"+ JSON.stringify(value))
              //         }
              //       })
              //     })
              // }
              // .height($r('app.float.component_size_MP'))
              // .padding({ top: $r('app.float.edge_size_MPM'), bottom: $r('app.float.edge_size_MM') })
              // .borderWidth({ bottom: CommonConstants.FULL_SIZE })
              // .borderColor($r('app.color.border_color'))
              // }
              // .width(CommonConstants.FULL_WIDTH)
              // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })

              Row() {
                Text('备注')
                  .fontSize(25)
                  .width('50vp')
                  .height('50vp')
                  .fontColor('#00FFFF')
                  .padding({ left: CommonConstants.MINIMUM_SIZE })
                Row() {
                  TextInput({
                    placeholder: $r('app.string.input_reminder'),
                    text: this.inputRemind
                  })
                    .textAlign(TextAlign.Center)
                      // .padding({ left: $r('app.float.edge_size_M') })
                    .width('290vp')
                    .borderRadius(CommonConstants.MINIMUM_SIZE)
                    .backgroundColor('#EC8AA3')
                    .type(InputType.Normal)
                    .onChange((value: string) => {
                      this.inputRemind = value;
                    })

                  Image($rawfile('beizhu.png'))
                    .backgroundColor('$color:start_window_background')
                    .width('38vp')
                    .height('38vp')
                }
                .borderWidth({ bottom: CommonConstants.FULL_SIZE })
                .borderColor($r('app.color.border_color'))
              }
              .width(CommonConstants.FULL_WIDTH)
              .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })

            //   Column() {
            //   //备注输入
            //   Text("备注")
            //     .width(CommonConstants.FULL_WIDTH)
            //     .fontSize("20vp")
            //     .fontColor(Color.Black)
            //     .padding({ left: CommonConstants.MINIMUM_SIZE ,top: $r('app.float.edge_size_M')})
            //   Column() {
            //     TextInput({
            //       placeholder: $r('app.string.input_reminder'),
            //       text: this.inputRemind
            //     })
            //       .padding({ left: $r('app.float.edge_size_M') })
            //       .borderRadius(CommonConstants.MINIMUM_SIZE)
            //       .backgroundColor(Color.White)
            //       .type(InputType.Normal)
            //       .onChange((value: string) => {
            //         this.inputRemind = value;
            //       })
            //   }
            //   .height($r('app.float.component_size_MP'))
            //   .padding({ top: $r('app.float.edge_size_MPM'), bottom: $r('app.float.edge_size_MM') })
            //   .borderWidth({ bottom: CommonConstants.FULL_SIZE })
            //   .borderColor($r('app.color.border_color'))
            // }
            //   .width(CommonConstants.FULL_WIDTH)
            //   .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
            }
          // }
          // .scrollable(ScrollDirection.Vertical)
          // .scrollBar(BarState.Off)
          // }
          // .margin({ bottom: $r('app.float.edge_size_LP')})
      // }
      // .width(CommonConstants.FULL_WIDTH)
      // .height('58%')
      // .vertical(false)
      // .barMode(BarMode.Fixed)

      // //金额输入
      // // Column() {
      //   Text($r('app.string.count_text'))
      //     .width(CommonConstants.FULL_WIDTH)
      //     .fontSize($r('app.float.font_size_MP'))
      //     .fontColor(Color.Black)
      //     .padding({ left: CommonConstants.MINIMUM_SIZE })
      //   Column() {
      //     TextInput({
      //       placeholder: $r('app.string.input_text'),
      //       text: this.newAccount.amount === 0 ? this.inputAmount : this.newAccount.amount.toString()
      //     })
      //       .padding({ left: CommonConstants.MINIMUM_SIZE })
      //       .borderRadius(CommonConstants.MINIMUM_SIZE)
      //       .backgroundColor(Color.White)
      //       .type(InputType.Number)
      //       .onChange((value: string) => {
      //         this.inputAmount = value;
      //       })
      //   }
      //   .height($r('app.float.component_size_MP'))
      //   .padding({ top: $r('app.float.edge_size_MPM'), bottom: $r('app.float.edge_size_MM') })
      //   .borderWidth({ bottom: CommonConstants.FULL_SIZE })
      //   .borderColor($r('app.color.border_color'))
      // // }
      // // .width(CommonConstants.FULL_WIDTH)
      // // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
      // //日期输入
      // Text("时间")
      //   .width(CommonConstants.FULL_WIDTH)
      //   .fontSize("20vp")
      //   .fontColor(Color.Black)
      //   .padding({ left: CommonConstants.MINIMUM_SIZE })
      // // Column() {
      // //   Text(this.newAccount.date)
      // //     .width(CommonConstants.FULL_WIDTH)
      // //     .fontSize($r('app.float.font_size_MP'))
      // //     .fontColor(Color.Black)
      //   Column() {
      //     Text(this.newAccount.date)
      //       .padding({ left: CommonConstants.MINIMUM_SIZE })
      //       .borderRadius(CommonConstants.MINIMUM_SIZE)
      //       .backgroundColor(Color.White)
      //       .onClick(() => {
      //         let cur_date = new Date()
      //         this.selected_date = cur_date
      //         DatePickerDialog.show({
      //           start: new Date("2015-1-1"),
      //           end: new Date("2030-12-31"),
      //           selected: this.selected_date,
      //           onAccept: (value: DatePickerResult) => {
      //             //通过Date的setFullYear方法设置按下按钮时的日期
      //             this.selected_date.setFullYear(value.year, value.month, value.day)
      //             this.newAccount.date = value.year.toString() + '年' +
      //             (value.month + 1).toString() + '月' +
      //             value.day.toString() + '日'
      //             this.newAccount.year = value.year.toString();
      //             this.newAccount.month = value.year.toString() + ' - ' + (value.month + 1).toString();
      //             console.info("DatePickerDialog: onAccept()" + JSON.stringify(value))
      //           },
      //           onCancel: () => {
      //             console.info("DatePickerDialog:onCancel()")
      //           },
      //           onChange:(value: DatePickerResult) =>{
      //             console.info("DatePickerDialog:onChange()"+ JSON.stringify(value))
      //           }
      //         })
      //       })
      //   }
      //   .height($r('app.float.component_size_MP'))
      //   .padding({ top: $r('app.float.edge_size_MPM'), bottom: $r('app.float.edge_size_MM') })
      //   .borderWidth({ bottom: CommonConstants.FULL_SIZE })
      //   .borderColor($r('app.color.border_color'))
      // // }
      // // .width(CommonConstants.FULL_WIDTH)
      // // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })
      // //备注输入
      // Text("备注")
      //   .width(CommonConstants.FULL_WIDTH)
      //   .fontSize("20vp")
      //   .fontColor(Color.Black)
      //   .padding({ left: CommonConstants.MINIMUM_SIZE })



      // Column() {
      //   Text($r('app.string.reminder_text'))
      //     .width(CommonConstants.FULL_WIDTH)
      //     .fontSize($r('app.float.font_size_MP'))
      //     .fontColor(Color.Black)
      //
      //   Column() {
      //     TextInput({
      //       placeholder: $r('app.string.input_reminder'),
      //       text: this.newAccount.amount === 0 ? this.inputAmount : this.newAccount.amount.toString()
      //     })
      //       .padding({ left: CommonConstants.MINIMUM_SIZE })
      //       .borderRadius(CommonConstants.MINIMUM_SIZE)
      //       .backgroundColor(Color.White)
      //       .type(InputType.Normal)
      //       .onChange((value: string) => {
      //         this.inputRemind = value;
      //       })
      //   }
      //   .height($r('app.float.component_size_MP'))
      //   .padding({ top: $r('app.float.edge_size_MPM'), bottom: $r('app.float.edge_size_MM') })
      //   .borderWidth({ bottom: CommonConstants.FULL_SIZE })
      //   .borderColor($r('app.color.border_color'))
      // }
      // .width(CommonConstants.FULL_WIDTH)
      // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })

      Column() {
        Button() {
          Text($r('app.string.confirm_text'))
            .fontSize($r('app.float.font_size_M'))
            .fontColor(Color.White)
        }
        .backgroundColor('#f5a623')
        .width(CommonConstants.FULL_WIDTH)
        .height($r('app.float.component_size_M'))
        .onClick(() => {
          if (this.newAccount.typeText === '' || this.curIndex !== this.newAccount.accountType) {
            prompt.showToast({ message: CommonConstants.TOAST_TEXT_1, bottom: CommonConstants.PROMPT_BOTTOM });
          } else {
            let regex: RegExp = new RegExp('[1-9][0-9]*');
            let matchValue: Array<string> | null = this.inputAmount.match(regex);
            if (matchValue !== null && matchValue[0] === this.inputAmount) {
              this.newAccount.amount = Number(this.inputAmount);
              this.newAccount.reminder = String(this.inputRemind);
              this.confirm && this.confirm(this.isInsert, this.newAccount);
              this.controller?.close();
            } else {
              prompt.showToast({ message: CommonConstants.TOAST_TEXT_2, bottom: CommonConstants.PROMPT_BOTTOM });
            }
          }
        })
      }
      .layoutWeight(CommonConstants.FULL_SIZE)
      .padding({
        bottom: $r('app.float.font_size_L'),
        left: $r('app.float.font_size_L'),
        right: $r('app.float.font_size_L')
      })
      .justifyContent(FlexAlign.End)
    }
    .width(CommonConstants.FULL_WIDTH)
    .height('80%')
    .borderRadius({ topLeft: $r('app.float.font_size_L'), topRight: $r('app.float.font_size_L') })
    .backgroundColor('#EC8AA3')
    .align(Alignment.BottomEnd)
  }
}