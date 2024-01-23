import TreeMap from '@ohos.util.TreeMap';
const YEAR:string = '年';
const MONTH:string ='月';
const DAY:string = '日';

export function padto2Digits(num: number){
  return num.toString().padStart(2,'0');
}
export function dataToStr(date: Date){
  return date.toDateString();
}
export function dateFormat(date: Date){
  return date.getFullYear() + YEAR + padto2Digits(date.getMonth() + 1)  + MONTH + padto2Digits(date.getDate()) + DAY;
}
export function DateFormat(timestamp: number){
  let tempDate = new Date(timestamp);
  return dateFormat(tempDate);
}