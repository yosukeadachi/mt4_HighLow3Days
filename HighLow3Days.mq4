//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                                    Copyright 2018, Yosuke Adachi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Yosuke Adachi"
#property link      ""
#property version   "2.05"
#property strict
#property indicator_chart_window
#property indicator_buffers 8

#define DAYS  4  //表示する日数

//色
static color Colors[] = {Red, Green, Blue, Orange};

//ラベル
static string  ObjNameHigh = "High"; //高値ラベル
static string  ObjNameLow = "Low";  //安値ラベル
static const int FONT_SIZE = 10; //フォントサイズ
static int printedYs[] = {0,0,0,0};

//---- indicator buffers
static const int INIDICATOR_BUFFERS_COUNT = 8;
struct StructBufferInfo {
  int dayIndex;
  datetime date;
  double high[];
  double low[];
  double highest;
  double lowest;
  color c;
  string nameLabelHigh;
  string nameLabelLow;
  string nameLineHigh;
  string nameLineLow;
  int lineWidth;
  int lineStyle;
};
StructBufferInfo Buffers[DAYS];

string commentStr;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
  // buffer settings
  for(int i = 0; i < ArraySize(Buffers); i++) {
    Buffers[i].dayIndex = i;
    Buffers[i].date = 0;
    Buffers[i].highest = 0;
    Buffers[i].lowest = 0;
    Buffers[i].c = Colors[i];
    Buffers[i].nameLabelHigh = GenerateLabelObjName(i, ObjNameHigh);
    Buffers[i].nameLabelLow = GenerateLabelObjName(i, ObjNameLow);
    Buffers[i].nameLineHigh = "Line" + GenerateLabelObjName(i, ObjNameHigh);
    Buffers[i].nameLineLow = "Line" + GenerateLabelObjName(i, ObjNameLow);
    Buffers[i].lineWidth = 1;
    Buffers[i].lineStyle = 0;
  }

  //--- 1 additional buffers
  IndicatorBuffers(INIDICATOR_BUFFERS_COUNT);
  //---- indicator buffers
  for(int i = 0; i < ArraySize(Buffers); i++) {
    SetIndexBuffer((i*2)+0,Buffers[i].high);
    SetIndexBuffer((i*2)+1,Buffers[i].low);
    ArrayInitialize(Buffers[i].high,0.0);
    ArrayInitialize(Buffers[i].low,0.0);
  }

  //---- drawing settings
  for(int i = 0; i < INIDICATOR_BUFFERS_COUNT; i++) {
    SetIndexStyle(i,DRAW_LINE,STYLE_SOLID,1,Buffers[i/2].c);
  }
  //---- indicator short name
  IndicatorShortName("HighLowDays");

  CreateLabelObjAll(Buffers);
  CreateLineObjAll(Buffers);
  UpdateAll();
  return(INIT_SUCCEEDED);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
  DeleteLabelAll(Buffers);
  DeleteLineAll(Buffers);
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
                const int& spread[]) {

  UpdateAll();
  return(0);
}

//+------------------------------------------------------------------+
//| イベント関数                                              |
//+------------------------------------------------------------------+
void OnChartEvent(
                 const int     id,      // イベントID
                 const long&   lparam,  // long型イベント
                 const double& dparam,  // double型イベント
                 const string& sparam)  // string型イベント
{
  if (id == CHARTEVENT_CHART_CHANGE){
    UpdateAll();
  }
}

// ラベル名生成
string GenerateLabelObjName(int aDayIndex, string aName) {
  return "(" + IntegerToString(aDayIndex) + ")" + aName;
}

//--------------
// 作成
// ラベル関連を作成
// ラベル関連を全て作成
void CreateLabelObjAll(StructBufferInfo &aBuffers[]){
  for(int i = 0; i < ArraySize(aBuffers); i++) {
    ObjectCreate(aBuffers[i].nameLabelHigh,OBJ_LABEL,0,0,0);               // テキストラベルオブジェクト生成
    ObjectCreate(aBuffers[i].nameLabelLow,OBJ_LABEL,0,0,0);               // テキストラベルオブジェクト生成
  }
}

// Line
// ラインを作成
void CreateLineObj(string aName, int aColor, int aWidth, int aStyle) {
  string _objName = aName;
  ObjectCreate(_objName, OBJ_HLINE, 0, 0, 0);
  ObjectSet(_objName, OBJPROP_COLOR, aColor);
  ObjectSet(_objName, OBJPROP_WIDTH, aWidth);
  ObjectSet(_objName, OBJPROP_STYLE, aStyle);
}

//　ラインを全て作成
void CreateLineObjAll(StructBufferInfo &aBuffers[]) {
  for(int i = 0; i < ArraySize(aBuffers); i++) {
    CreateLineObj(aBuffers[i].nameLineHigh, aBuffers[i].c, aBuffers[i].lineWidth, aBuffers[i].lineStyle);
    CreateLineObj(aBuffers[i].nameLineLow, aBuffers[i].c, aBuffers[i].lineWidth, aBuffers[i].lineStyle);
  }
}

//--------------
// 更新
void UpdateAll() {
  UpdateHighLow(Buffers);
  UpdateLabelObjAll(Buffers);
  UpdateLineObjAll(Buffers);
}

//高値安値更新
void UpdateHighLow(StructBufferInfo &aBuffers[]) {
  for(int day = 0; day < ArraySize(aBuffers); day++) {
    aBuffers[day].highest = iHigh(NULL,PERIOD_D1,aBuffers[day].dayIndex);
    aBuffers[day].lowest = iLow(NULL,PERIOD_D1,aBuffers[day].dayIndex);
  }
}

// ラベル関連を更新
void UpdateLabel(string aName, double aValue, datetime aDatetime, color aColor) {
  int pixcel_x = 0;
  int pixcel_y = 0;
  if(ArraySize(Time) > 0) {
    ChartTimePriceToXY( 0,0, Time[0],aValue, pixcel_x,pixcel_y);
  }
  pixcel_x = 0;
  string _labelObjName = aName;
  ObjectSet(_labelObjName,OBJPROP_XDISTANCE,pixcel_x);    // テキストラベルオブジェクトX軸位置設定
  ObjectSet(_labelObjName,OBJPROP_YDISTANCE,pixcel_y);    // テキストラベルオブジェクトY軸位置設定
  //ラベル文字
  string _labelStr = _labelObjName;
  // printf("UpdateLabel obj:%s str:%s", _labelObjName, _labelStr);
  ObjectSetText(_labelObjName, _labelStr , FONT_SIZE , "ＭＳ　ゴシック" , aColor); // テキストラベルオブジェクト、テキストタイプ設定
}

// ラベル関連を更新 high&Low
void UpdateLabelHighLow(StructBufferInfo &aBuffer) {
  if((ArraySize(aBuffer.high) <= 0) || (ArraySize(aBuffer.low) <= 0)) {
    return;
  }

  double _high = aBuffer.highest;
  // printf("%d high:%f", aBuffer.dayIndex, _high);
  commentStr += "" + IntegerToString(aBuffer.dayIndex) + " high:" + DoubleToString(_high) + " " + TimeToStr(aBuffer.date, TIME_DATE|TIME_MINUTES) + "\n";
  double _low = aBuffer.lowest;
  // printf("%d low:%f", aBuffer.dayIndex, _low);
  commentStr += "" + IntegerToString(aBuffer.dayIndex) + " low:" + DoubleToString(_low) + " " + TimeToStr(aBuffer.date, TIME_DATE|TIME_MINUTES) + "\n";
  int countBars = Bars;
  for(int bar = 0; bar < countBars; bar++) {
    if(ArraySize(aBuffer.high) > bar) {
      aBuffer.high[bar] = _high;
    }
    if(ArraySize(aBuffer.low) > bar) {
      aBuffer.low[bar] = _low;
    }
  }
  UpdateLabel(aBuffer.nameLabelHigh, _high, aBuffer.date, aBuffer.c);
  UpdateLabel(aBuffer.nameLabelLow, _low, aBuffer.date, aBuffer.c);
} 

//　ラベル関連を全て更新
void UpdateLabelObjAll(StructBufferInfo &aBuffers[]) {
  commentStr = "";
  for(int day = 0; day < ArraySize(aBuffers); day++) {
    // printf("UpdateLabelObjAll aBuffers[%d].dayIndex:%d", day, aBuffers[day].dayIndex);
    UpdateLabelHighLow(aBuffers[day]);
  }
  // Comment(commentStr);
}

// Line
// ラインを更新
void UpdateLine(string aName, double aValue) {
  string _objName = aName;
  if(ArraySize(Time) > 0) {
    ObjectMove(_objName, 0, Time[0], aValue);
  }
}

//　ラインを全て更新
void UpdateLineObjAll(StructBufferInfo &aBuffers[]) {
  // commentStr = "";
  for(int i = 0; i < ArraySize(aBuffers); i++) {
    UpdateLine(aBuffers[i].nameLineHigh, aBuffers[i].highest);
    UpdateLine(aBuffers[i].nameLineLow, aBuffers[i].lowest);
  }
  // Comment(commentStr);
}

//--------------
// 削除
// ラベル関連を全て削除
void DeleteLabelAll(StructBufferInfo &aBuffers[]) {
  for(int i = 0; i < ArraySize(aBuffers); i++){
    ObjectDelete(aBuffers[i].nameLabelHigh);
    ObjectDelete(aBuffers[i].nameLabelLow);
  }
}

// ラインを全て削除
void DeleteLineAll(StructBufferInfo &aBuffers[]) {
  for(int i = 0; i < ArraySize(aBuffers); i++){
    ObjectDelete(aBuffers[i].nameLineHigh);
    ObjectDelete(aBuffers[i].nameLineLow);
  }
}

//+------------------------------------------------------------------+
// Utility

datetime getNowDatetime() {
  return StrToTime(
        "" + 
        IntegerToString(Year()) + "." +
        IntegerToString(Month()) + "." + 
         IntegerToString(Day())+ " 00:00");
}

//+------------------------------------------------------------------+
