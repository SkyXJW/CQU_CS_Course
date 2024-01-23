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

import AccountItem from './AccountItem';

export const PayList: Array<AccountItem> = [
  {
    icon: $rawfile('canyin.png'),
    iconSelected: $rawfile('canyin.png'),
    accountType: 0,
    typeText: '餐饮'
  },
  {
    icon: $rawfile('yuehui.png'),
    iconSelected: $rawfile('yuehui.png'),
    accountType: 0,
    typeText: '约会'
  },
  {
    icon: $rawfile('lingshi.png'),
    iconSelected: $rawfile('lingshi.png'),
    accountType: 0,
    typeText: '零食'
  },
  {
    icon: $rawfile('shuifei.png'),
    iconSelected: $rawfile('shuifei.png'),
    accountType: 0,
    typeText: '水费'
  },
  {
    icon: $rawfile('dianfei.png'),
    iconSelected: $rawfile('dianfei.png'),
    accountType: 0,
    typeText: '电费'
  },
  {
    icon: $rawfile('qifei.png'),
    iconSelected: $rawfile('qifei.png'),
    accountType: 0,
    typeText: '气费'
  },
  {
    icon: $rawfile('lvyou.png'),
    iconSelected: $rawfile('lvyou.png'),
    accountType: 0,
    typeText: '旅游'
  },
  {
    icon: $rawfile('youfei.png'),
    iconSelected: $rawfile('youfei.png'),
    accountType: 0,
    typeText: '油费'
  },
  {
    icon: $rawfile('yaowu.png'),
    iconSelected: $rawfile('yaowu.png'),
    accountType: 0,
    typeText: '医药'
  },
  {
    icon: $rawfile('yifu.png'),
    iconSelected: $rawfile('yifu.png'),
    accountType: 0,
    typeText: '服饰'
  },
  {
    icon: $rawfile('qita.png'),
    iconSelected: $rawfile('qita.png'),
    accountType: 0,
    typeText: '其他'
  }
]

export const EarnList: Array<AccountItem> = [
  {
    icon: $rawfile('jiangxuejin.png'),
    iconSelected: $rawfile('jiangxuejin.png'),
    accountType: 1,
    typeText: '奖学金'
  },
  {
    icon: $rawfile('gongzi.png'),
    iconSelected: $rawfile('gongzi.png'),
    accountType: 1,
    typeText: '工资'
  },
  {
    icon: $rawfile('touzi.png'),
    iconSelected: $rawfile('touzi.png'),
    accountType: 1,
    typeText: '投资'
  },
  {
    icon: $rawfile('licai.png'),
    iconSelected: $rawfile('licai.png'),
    accountType: 1,
    typeText: '理财'
  },
  {
    icon: $rawfile('jijin.png'),
    iconSelected: $rawfile('jijin.png'),
    accountType: 1,
    typeText: '基金'
  },
  {
    icon: $rawfile('hongbao.png'),
    iconSelected: $rawfile('hongbao.png'),
    accountType: 1,
    typeText: '红包'
  },{
    icon: $rawfile('qita.png'),
    iconSelected: $rawfile('qita.png'),
    accountType: 1,
    typeText: '其他'
 }
]

export const ImageList: Record<string,Resource> = {
  '餐饮': $rawfile('canyin.png'),
  '约会': $rawfile('yuehui.png'),
  '零食': $rawfile('lingshi.png'),
  '水费': $rawfile('shuifei.png'),
  '电费': $rawfile('dianfei.png'),
  '气费': $rawfile('qifei.png'),
  '旅行': $rawfile('lvyou.png'),
  '油费': $rawfile('youfei.png'),
  '医药': $rawfile('yaowu.png'),
  '服饰': $rawfile('yifu.png'),
  '其他': $rawfile('qita.png'),
  '奖学金': $rawfile('jiangxuejin.png'),
  '工资': $rawfile('gongzi.png'),
  '投资': $rawfile('touzi.png'),
  '理财': $rawfile('licai.png'),
  '基金': $rawfile('jijin.png'),
  '红包': $rawfile('hongbao.png')
}