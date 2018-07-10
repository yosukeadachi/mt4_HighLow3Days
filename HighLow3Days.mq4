//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                                    Copyright 2018, Yosuke Adachi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Yosuke Adachi"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

extern string  Line0 = "--   LineStyle 0-5   --";
extern int     LineStyle0 = 0;
extern int     LineStyle1 = 0;
extern int     LineStyle2 = 0;
extern color   LineColorHigh0 = Red;
extern color   LineColorLow0 = Red;
extern color   LineColorHigh1 = Green;
extern color   LineColorLow1 = Green;
extern color   LineColorHigh2 = Blue;
extern color   LineColorLow2 = Blue;

static string  Objname = "USDJPY_Line";
static int     LineNo  = 0;

static int times = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   
   return(0);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){
   
   string name;

   for(int i = 0; i < LineNo; i++){
      name = Objname + i;
      ObjectDelete(name);
   }
   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
  //  if(times > 0) return(0);      //最初だけ実行
  //  else  times = 1;
   
  double Decimal;         //小数点の位置
  if(Point == 0.01) Decimal = 100;
  else Decimal = 10000;
  
  double _highs[3] = {0,0,0};
  double _lows[3] = {0,0,0};
  _highs[0] = iHigh(NULL,PERIOD_D1,0);
  _highs[1] = iHigh(NULL,PERIOD_D1,1);
  _highs[2] = iHigh(NULL,PERIOD_D1,2);
  _lows[0] = iLow(NULL,PERIOD_D1,0);
  _lows[1] = iLow(NULL,PERIOD_D1,1);
  _lows[2] = iLow(NULL,PERIOD_D1,2);
  // Print("OnCalculate _highs[0]:" + _highs[0]);
  CreateLineObj(_highs[0], LineNo, 1, LineStyle0, LineColorHigh0);
  CreateLineObj(_lows[0], LineNo, 1, LineStyle0, LineColorLow0);
  CreateLineObj(_highs[1], LineNo, 1, LineStyle1, LineColorHigh1);
  CreateLineObj(_lows[1], LineNo, 1, LineStyle1, LineColorLow1);
  CreateLineObj(_highs[2], LineNo, 1, LineStyle2, LineColorHigh2);
  CreateLineObj(_lows[2], LineNo, 1, LineStyle2, LineColorLow2);
  return(0);
}

// ラインを引く
void CreateLineObj(double dt, int aLineNo, int aWidth, int aStyle, color aColor){
  string _name = Objname + LineNo;
  ObjectCreate(_name, OBJ_HLINE, 0, 0, dt);
  ObjectSet(_name, OBJPROP_WIDTH, aWidth);
  ObjectSet(_name, OBJPROP_STYLE, aStyle);
  ObjectSet(_name, OBJPROP_COLOR, aColor);
  LineNo++;
}



//+------------------------------------------------------------------+
