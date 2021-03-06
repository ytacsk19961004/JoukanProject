//+------------------------------------------------------------------+
//|                                                   JKProject1.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define MAGIC 1234

#include<AdjustPoint.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   Print("PERIOD_CURRENT : " + PERIOD_CURRENT);
   // 初期化処理として現在時刻を取得
   currentTime = Time[0];
//   Print("PriceChangeWidth : " + PriceChangeWidth(PERIOD_M5,0,3,1));
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int Ticket = 0;
bool flag = false;
int currentTime = 0;

int TicketNumber = 0;
double SellTicketValue = 0;


bool buyFlag = false;
int  buyCurrentTime = 0;


void OnTick(){
   {
      double moving_average  = iMA(NULL,PERIOD_CURRENT,35,0,0,0,0);
      double bands           = iBands(NULL,PERIOD_CURRENT,35,1.6,0,PRICE_CLOSE,1,0);
      
//      double ichimoku_tenkan = iIchimoku(NULL, PERIOD_CURRENT,9,26,52,1,0);
//      double ichimoku_kijun  = iIchimoku(NULL, PERIOD_CURRENT,9,26,52,2,0);
//      double macd            = iMACD(NULL,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,0,0);
   }
   
   {
//         Ask <= iEnvelopes(NULL,PERIOD_CURRENT,35,MODE_SMA,0,PRICE_CLOSE,0.15,2,0
//         Ask <= iBands(NULL,PERIOD_CURRENT,20,2,0,PRICE_CLOSE,1,0)
   
//         double bands           = ;

   }

//   if(TicketNumber == 0 || TicketNumber == -1){
   if(currentTime != Time[0]){
      
      if(buyFlag == false){
         if(Ask <= iEnvelopes(NULL,PERIOD_CURRENT,35,MODE_SMA,0,PRICE_CLOSE,0.15,2,0) && 
            (MathAbs(Close[1] - Open[1]) < MathAbs(Close[2] - Open[2]) || 
             MathAbs(High[2] - Open[2]) + MathAbs(Low[2] - Close[2]) < MathAbs(High[1] - Open[1]) + MathAbs(Low[1] - Close[1])) &&
             PriceChangeWidth(PERIOD_M5,0,3,1) < PriceChangeWidth(PERIOD_M5,1,3,1)){
             
            buyFlag = true;
         }
      }else{
         TicketNumber = OrderSend(Symbol(),OP_BUY,1,Ask,0.1,Ask - AdjustPoint(Symbol()) * 23,Ask + AdjustPoint(Symbol()) * 20,NULL,MAGIC,0,Red);
         buyFlag = false;
      }
      currentTime = Time[0];
   }
}
  

// 移動平均幅の取得処理 - 【分足】【開始期間】【範囲期間】【取得線】
// 分足【5】 開始期間【0】 範囲期間【2日 (60 * 60 * 24 * 2) / 5】 取得線【0 = 上 1 = 下】
// 5 , 0 , 60 * 24 * 2 / 5, 1
// 5 , 60 * 24 / 5 ,  60 * 60 * 24 * 2 / 5, 1
//1分
// time   = ローソク足の分足
// entry  = 今の時間からいくつ前から取得するのか
// length = 何本前のローソク足の値まで取得するのか
// line   = 0の時に高値の移動平均幅を取得
//          1の時に安値の移動平均幅を取得

double PriceChangeWidth(int time,int entry,int length,int line){
   double sum = 0;
   
   switch(line){
      case 0:
         for(int i = 0;i < length;i++){
            sum += iHigh(NULL,time,entry + i);
         }
         break;
      case 1:
         for(int i = 0;i < length;i++){
            sum += iLow(NULL,time,entry + i);
         }
         break;
   }
   
   return sum / length;
}


// 価格変動幅が1足前よりも下回っている時に　期間は2日間
// 