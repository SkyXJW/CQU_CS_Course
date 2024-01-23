import AccountData from '../common/bean/AccountData'

export class ScrollData{
  accountData: AccountData
  scroller: Scroller

  constructor(accountData: AccountData, scroller: Scroller) {
    this.accountData = accountData
    this.scroller = scroller
  }
}