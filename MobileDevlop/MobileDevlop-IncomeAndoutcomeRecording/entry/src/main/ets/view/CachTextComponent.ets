@Component
export default struct CashText {
  @Prop amount: string;
  fontSize: number | string | Resource = $r('app.float.edge_size_MP');
  fontWeight: number | FontWeight | string = 500;
  fontFamily: string | Resource ='HarmonyHeiTi-Bold';
  fontColor: '#FF000000';

  build(){
    Text(this.amount)
      .fontSize(this.fontSize)
      .fontWeight(this.fontWeight)
      .fontColor(this.fontColor)
      .fontFamily(this.fontFamily)
  }

}