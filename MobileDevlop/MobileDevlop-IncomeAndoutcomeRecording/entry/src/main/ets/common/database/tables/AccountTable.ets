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

import relationalStore from '@ohos.data.relationalStore';
import AccountData from '../../../viewmodel/AccountData';
import CommonConstants from '../../constants/CommonConstants';
import Rdb from '../rdb';

export default class AccountTable {
  private accountTable = new Rdb(CommonConstants.ACCOUNT_TABLE.tableName, CommonConstants.ACCOUNT_TABLE.sqlCreate,
    CommonConstants.ACCOUNT_TABLE.columns);

  constructor(callback: Function = () => {
  }) {
    this.accountTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function = () => {
  }) {
    this.accountTable.getRdbStore(callback);
  }

  insertData(account: AccountData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
    this.accountTable.insertData(valueBucket, callback);
  }

  deleteData(account: AccountData, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    predicates.equalTo('id', account.id);
    this.accountTable.deleteData(predicates, callback);
  }

  updateData(account: AccountData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    predicates.equalTo('id', account.id);
    this.accountTable.updateData(predicates, valueBucket, callback);
  }
  //查询所有记录/日期查询
  query(date: string, callback: Function, isAll: boolean = true) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    if (!isAll) {
      predicates.equalTo('date', date);
    }
    this.accountTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        console.log(`${CommonConstants.TABLE_TAG}` + 'Query no results!');
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: AccountData[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: AccountData = {
            id: 0, accountType: 0, typeText: '', amount: 0,date: '', year: '', month: '', reminder: ''
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType'));
          tmp.typeText = resultSet.getString(resultSet.getColumnIndex('typeText'));
          tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
          tmp.date = resultSet.getString(resultSet.getColumnIndex('date'));
          tmp.year = resultSet.getString(resultSet.getColumnIndex('year'));
          tmp.month = resultSet.getString(resultSet.getColumnIndex('month'));
          tmp.reminder = resultSet.getString(resultSet.getColumnIndex('reminder'));
          result[i] = tmp;
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }

  queryYear(date: string, callback: Function, isAll: boolean = true){
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    if(!isAll){
      predicates.equalTo('year',date);
    }
    this.accountTable.query(predicates,(resultSet: relationalStore.ResultSet)=>{
      let count: number = resultSet.rowCount;
      if(count===0 || typeof count === 'string') {
        console.log('${CommonConstants.TABLE_TAG}'+ 'Query no results!');
        callback([]);
      }else{
        resultSet.goToFirstRow();
        const result: AccountData[] = [];
        for(let i = 0; i<count;i++){
          let tmp: AccountData = {
            id: 0, accountType: 0, typeText: '', amount: 0, date: '', year: '', month: '', reminder: ''
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType'));
          tmp.typeText = resultSet.getString(resultSet.getColumnIndex('typeText'));
          tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
          tmp.date = resultSet.getString(resultSet.getColumnIndex('date'));
          tmp.year = resultSet.getString(resultSet.getColumnIndex('year'));
          tmp.month = resultSet.getString(resultSet.getColumnIndex('month'));
          tmp.reminder = resultSet.getString(resultSet.getColumnIndex('reminder'));
          result[i] = tmp;
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }

  queryMonth(date: string, callback: Function, isAll: boolean = true){
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    if(!isAll){
      predicates.equalTo('month',date);
    }
    this.accountTable.query(predicates,(resultSet: relationalStore.ResultSet)=>{
      let count: number = resultSet.rowCount;
      if(count===0 || typeof count === 'string') {
        console.log('${CommonConstants.TABLE_TAG}'+ 'Query no results!');
        callback([]);
      }else{
        resultSet.goToFirstRow();
        const result: AccountData[] = [];
        for(let i = 0; i<count;i++){
          let tmp: AccountData = {
            id: 0, accountType: 0, typeText: '', amount: 0, date: '', year: '', month: '', reminder: ''
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType'));
          tmp.typeText = resultSet.getString(resultSet.getColumnIndex('typeText'));
          tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
          tmp.date = resultSet.getString(resultSet.getColumnIndex('date'));
          tmp.year = resultSet.getString(resultSet.getColumnIndex('year'));
          tmp.month = resultSet.getString(resultSet.getColumnIndex('month'));
          tmp.reminder = resultSet.getString(resultSet.getColumnIndex('reminder'));
          result[i] = tmp;
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }
  //分类查询（收入/支出）
  queryaccountType(accountType: number, callback: Function, isAll: boolean = true) {
      let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
      if(!isAll){
        predicates.equalTo('accountType',accountType);
      }
      this.accountTable.query(predicates,(resultSet: relationalStore.ResultSet)=>{
        let count: number = resultSet.rowCount;
        if(count===0 || typeof count === 'string') {
          console.log('${CommonConstants.TABLE_TAG}'+ 'Query no results!');
          callback([]);
        }else{
          resultSet.goToFirstRow();
          const result: AccountData[] = [];
          for(let i = 0; i<count;i++){
            let tmp: AccountData = {
              id: 0, accountType: 0, typeText: '', amount: 0, date: '', year: '', month: '', reminder: ''
            };
            tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
            tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType'));
            tmp.typeText = resultSet.getString(resultSet.getColumnIndex('typeText'));
            tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
            tmp.date = resultSet.getString(resultSet.getColumnIndex('date'));
            tmp.year = resultSet.getString(resultSet.getColumnIndex('year'));
            tmp.month = resultSet.getString(resultSet.getColumnIndex('month'));
            tmp.reminder = resultSet.getString(resultSet.getColumnIndex('reminder'));
            result[i] = tmp;
            resultSet.goToNextRow();
          }
          callback(result);
        }
      });
  }

  //搜索查询——支持的条件查询有：用途（吃、穿、住、行）、备注
  queryType(text: string, callback: Function, isAll: boolean = true) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    if (!isAll) {
      predicates.like('typeText', '%' + text + '%').or().like('reminder', '%' + text + '%');

      this.accountTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
        let count: number = resultSet.rowCount;
        if (count === 0 || typeof count === 'string') {
          console.log('${CommonConstants.TABLE_TAG}' + 'Query no results!');
          callback([]);
        } else {
          resultSet.goToFirstRow();
          const result: AccountData[] = [];
          for (let i = 0; i < count; i++) {
            let tmp: AccountData = {
              id: 0,
              accountType: 0,
              typeText: '',
              amount: 0,
              date: '',
              year: '',
              month: '',
              reminder: ''
            };
            tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
            tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType'));
            tmp.typeText = resultSet.getString(resultSet.getColumnIndex('typeText'));
            tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
            tmp.date = resultSet.getString(resultSet.getColumnIndex('date'));
            tmp.year = resultSet.getString(resultSet.getColumnIndex('year'));
            tmp.month = resultSet.getString(resultSet.getColumnIndex('month'));
            tmp.reminder = resultSet.getString(resultSet.getColumnIndex('reminder'));
            result[i] = tmp;
            resultSet.goToNextRow();
          }
          callback(result);
        }
      });
    }
  }
   //金额范围查询
  queryAmountRange(amount_low: number, amount_high: number,callback: Function, isAll: boolean = true) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    if (!isAll) {
      predicates.between('amount',amount_low,amount_high);
    }
    this.accountTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        console.log(`${CommonConstants.TABLE_TAG}` + 'Query no results!');
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: AccountData[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: AccountData = {
            id: 0, accountType: 0, typeText: '', amount: 0,date: '', year: '', month: '', reminder: ''
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType'));
          tmp.typeText = resultSet.getString(resultSet.getColumnIndex('typeText'));
          tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
          tmp.date = resultSet.getString(resultSet.getColumnIndex('date'));
          tmp.year = resultSet.getString(resultSet.getColumnIndex('year'));
          tmp.month = resultSet.getString(resultSet.getColumnIndex('month'));
          tmp.reminder = resultSet.getString(resultSet.getColumnIndex('reminder'));
          result[i] = tmp;
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }

  //日期范围查询
  queryDateRange(newAccount1: AccountData, newAccount2: AccountData,callback: Function, isAll: boolean = true) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    if (!isAll) {
      predicates.between('date',newAccount1.date,newAccount2.date);
    }
    this.accountTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        console.log(`${CommonConstants.TABLE_TAG}` + 'Query no results!');
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: AccountData[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: AccountData = {
            id: 0, accountType: 0, typeText: '', amount: 0,date: '', year: '', month: '', reminder: ''
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType'));
          tmp.typeText = resultSet.getString(resultSet.getColumnIndex('typeText'));
          tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
          tmp.date = resultSet.getString(resultSet.getColumnIndex('date'));
          tmp.year = resultSet.getString(resultSet.getColumnIndex('year'));
          tmp.month = resultSet.getString(resultSet.getColumnIndex('month'));
          tmp.reminder = resultSet.getString(resultSet.getColumnIndex('reminder'));
          result[i] = tmp;
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }
}

function generateBucket(account: AccountData): relationalStore.ValuesBucket {
  let obj: relationalStore.ValuesBucket = {};
  obj.accountType = account.accountType;
  obj.typeText = account.typeText;
  obj.amount = account.amount;
  obj.date = account.date;
  obj.year = account.year;
  obj.month = account.month;
  obj.reminder = account.reminder;
  return obj;
}