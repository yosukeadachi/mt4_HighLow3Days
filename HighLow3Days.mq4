//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                                    Copyright 2018, Yosuke Adachi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Yosuke Adachi"
#property link      ""
#property version   "2.03"
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
  string nameHigh;
  string nameLow;
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
    Buffers[i].nameHigh = GenerateLabelObjName(i, ObjNameHigh);
    Buffers[i].nameLow = GenerateLabelObjName(i, ObjNameLow);
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

  CreateLabelAll(Buffers);
  return(INIT_SUCCEEDED);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
  DeleteLabelAll(Buffers);
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

  UpdateLabelObjAll(Buffers);

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
    UpdateLabelObjAll(Buffers);
  }
}

// ラベル名生成
string GenerateLabelObjName(int aDayIndex, string aName) {
  return "(" + IntegerToString(aDayIndex) + ")" + aName;
}

//--------------
// 作成
// ラベル関連を作成
void CreateLabel(string aName, color aColor, int aBarIndex){
  int pixcel_x,pixcel_y;
  ChartTimePriceToXY( 0,0, Time[0], 0, pixcel_x,pixcel_y);
  pixcel_x = 0;
  // テキストラベルオブジェクト生成
  string _labelObjName = aName;
  ObjectCreate(_labelObjName,OBJ_LABEL,0,0,0);               // テキストラベルオブジェクト生成
  ObjectSet(_labelObjName,OBJPROP_XDISTANCE,pixcel_x);    // テキストラベルオブジェクトX軸位置設定
  ObjectSet(_labelObjName,OBJPROP_YDISTANCE,pixcel_y);    // テキストラベルオブジェクトY軸位置設定
  string _labelStr = _labelObjName + "/" + TimeToStr(iTime(NULL,PERIOD_D1,aBarIndex),TIME_DATE);//ラベル文字
  ObjectSetText(_labelObjName, _labelStr , FONT_SIZE , "ＭＳ　ゴシック" , aColor); // テキストラベルオブジェクト、テキストタイプ設定
  // Print("desc:" + _labelObjName + "(" + IntegerToString(pixcel_x) + "/" + IntegerToString(pixcel_y) +")");
}

// ラベル関連を作成 high&low
void CreateLabelHighLow(StructBufferInfo &aBuffer, int aBarIndex){
  CreateLabel(aBuffer.nameHigh, aBuffer.c, aBarIndex);
  CreateLabel(aBuffer.nameLow, aBuffer.c, aBarIndex);
}

// ラベル関連を全て作成
void CreateLabelAll(StructBufferInfo &aBuffers[]){
  for(int i = 0; i < ArraySize(aBuffers); i++) {
    CreateLabelHighLow(aBuffers[i], i);
  }
}

//--------------
// 更新
//日付更新
bool UpdateDatetime(StructBufferInfo &aBuffer) {
  bool _doUpdate = false;
  //日付更新
  datetime _new = getNowDatetime() - (aBuffer.dayIndex * 60 * 60 *24);
  if(aBuffer.date != _new) {
    aBuffer.date = _new;
    _doUpdate = true;
  }
  if(_new == getNowDatetime()) {
    _doUpdate = true;
  }
  return _doUpdate;
}
//高値安値更新
void UpdateHighLow(StructBufferInfo &aBuffer) {
  aBuffer.highest = 0;
  aBuffer.lowest = 999999999.0f;
  //highest,lowest 更新
  datetime _beginDatetime = StrToTime(TimeToStr(aBuffer.date, TIME_DATE) + " 00:00:00");
  datetime _endDatetime = StrToTime(TimeToStr(aBuffer.date, TIME_DATE) + " 23:59:59");
  for(int bar = 0; bar < Bars; bar++) {
    datetime _barDatetime = Time[bar];
    //範囲が終わっていれば終了
    if(_barDatetime < _beginDatetime) { 
      break;
    }
    //範囲外なら次へ
    if((_beginDatetime > _barDatetime) || (_barDatetime > _endDatetime)) {
      continue;
    }

    //更新
    if(aBuffer.highest < High[bar]) {
      aBuffer.highest = High[bar];
    }
    if(aBuffer.lowest > Low[bar]) {
      aBuffer.lowest = Low[bar];
    }
  }
}

// ラベル関連を更新
void UpdateLabel(string aName, double aValue, datetime aDatetime, color aColor) {
  int pixcel_x,pixcel_y;
  ChartTimePriceToXY( 0,0, Time[0],aValue, pixcel_x,pixcel_y);
  pixcel_x = 0;
  string _labelObjName = aName;
  ObjectSet(_labelObjName,OBJPROP_XDISTANCE,pixcel_x);    // テキストラベルオブジェクトX軸位置設定
  ObjectSet(_labelObjName,OBJPROP_YDISTANCE,pixcel_y);    // テキストラベルオブジェクトY軸位置設定
  //ラベル文字
  string _labelStr = _labelObjName + "/" + TimeToStr(aDatetime, TIME_DATE);
  // printf("UpdateLabel obj:%s str:%s", _labelObjName, _labelStr);
  ObjectSetText(_labelObjName, _labelStr , FONT_SIZE , "ＭＳ　ゴシック" , aColor); // テキストラベルオブジェクト、テキストタイプ設定
}

// ラベル関連を更新 high&Low
void UpdateLabelHighLow(StructBufferInfo &aBuffer) {
  if(UpdateDatetime(aBuffer)){
    UpdateHighLow(aBuffer);
  }

  if((ArraySize(aBuffer.high) <= 0) || (ArraySize(aBuffer.low) <= 0)) {
    return;
  }

  double _high = aBuffer.highest;
  // printf("%d high:%f", aBuffer.dayIndex, _high);
  commentStr += "" + IntegerToString(aBuffer.dayIndex) + " high:" + DoubleToString(_high) + " " + TimeToStr(aBuffer.date, TIME_DATE|TIME_MINUTES) + "\n";
  double _low = aBuffer.lowest;
  // printf("%d low:%f", aBuffer.dayIndex, _low);
  commentStr += "" + IntegerToString(aBuffer.dayIndex) + " low:" + DoubleToString(_low) + " " + TimeToStr(aBuffer.date, TIME_DATE|TIME_MINUTES) + "\n";
  for(int bar = 0; bar < Bars; bar++) {
    aBuffer.high[bar] = _high;
    aBuffer.low[bar] = _low;
  }
  UpdateLabel(aBuffer.nameHigh, _high, aBuffer.date, aBuffer.c);
  UpdateLabel(aBuffer.nameLow, _low, aBuffer.date, aBuffer.c);
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

//--------------
// 削除
// ラベル関連を削除
void DeleteLabel(string aName) {
  ObjectDelete(aName);
}

// ラベル関連を削除 high&low
void DeleteLabelHighLow(StructBufferInfo &aBuffer) {
  DeleteLabel(aBuffer.nameHigh);
  DeleteLabel(aBuffer.nameLow);
}

// ラベル関連を全て削除
void DeleteLabelAll(StructBufferInfo &aBuffers[]) {
  for(int i = 0; i < ArraySize(aBuffers); i++){
    DeleteLabelHighLow(aBuffers[i]);
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
