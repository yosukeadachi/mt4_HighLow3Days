//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                                    Copyright 2018, Yosuke Adachi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Yosuke Adachi"
#property link      ""
#property version   "1.01"
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
static int times = 0;

static double gHighs[3] = {0,0,0};
static double gLows[3] = {0,0,0};

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

   for(int i = 0; i < ArraySize(gHighs) + ArraySize(gLows); i++){
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
  if(gHighs[0] != _highs[0]) {
    gHighs[0] = _highs[0];
    Print("OnCalculate update _highs[0]:" + _highs[0]);
    int _lineNo = 0;
    string _name = Objname + _lineNo;
    ObjectDelete(_name);
    CreateLineObj(_highs[0], _name, 1, LineStyle0, LineColorHigh0);
  }
  if(gLows[0] != _lows[0]) {
    gLows[0] = _lows[0];
    Print("OnCalculate update _lows[0]:" + _lows[0]);
    int _lineNo = 1;
    string _name = Objname + _lineNo;
    ObjectDelete(_name);
    CreateLineObj(_lows[0], _name, 1, LineStyle0, LineColorLow0);
  }
  if(gHighs[1] != _highs[1]) {
    gHighs[1] = _highs[1];
    Print("OnCalculate update _highs[1]:" + _highs[1]);
    int _lineNo = 2;
    string _name = Objname + _lineNo;
    ObjectDelete(_name);
    CreateLineObj(_highs[1], _name, 1, LineStyle1, LineColorHigh1);
  }
  if(gLows[1] != _lows[1]) {
    gLows[1] = _lows[1];
    Print("OnCalculate update _lows[1]:" + _lows[1]);
    int _lineNo = 3;
    string _name = Objname + _lineNo;
    ObjectDelete(_name);
    CreateLineObj(_lows[1], _name, 1, LineStyle1, LineColorLow1);
  }
  if(gHighs[2] != _highs[2]) {
    gHighs[2] = _highs[2];
    Print("OnCalculate update _highs[2]:" + _highs[2]);
    int _lineNo = 4;
    string _name = Objname + _lineNo;
    ObjectDelete(_name);
    CreateLineObj(_highs[2], _name, 1, LineStyle2, LineColorHigh2);
  }
  if(gLows[2] != _lows[2]) {
    gLows[2] = _lows[2];
    Print("OnCalculate update _lows[2]:" + _lows[2]);
    int _lineNo = 5;
    string _name = Objname + _lineNo;
    ObjectDelete(_name);
    CreateLineObj(_lows[2], _name, 1, LineStyle2, LineColorLow2);
  }
  return(0);
}

// ラインを引く
void CreateLineObj(double dt, string aLineName, int aWidth, int aStyle, color aColor){
  ObjectCreate(aLineName, OBJ_HLINE, 0, 0, dt);
  ObjectSet(aLineName, OBJPROP_WIDTH, aWidth);
  ObjectSet(aLineName, OBJPROP_STYLE, aStyle);
  ObjectSet(aLineName, OBJPROP_COLOR, aColor);
}



//+------------------------------------------------------------------+
