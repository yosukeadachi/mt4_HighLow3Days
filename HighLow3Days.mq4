//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                                    Copyright 2018, Yosuke Adachi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Yosuke Adachi"
#property link      ""
#property version   "2.02"
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
  double high[];
  double low[];
  color c;
  string nameHigh;
  string nameLow;
};
StructBufferInfo Buffers[DAYS];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
  // buffer settings
  for(int i = 0; i < ArraySize(Buffers); i++) {
    Buffers[i].dayIndex = i;
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
  if (id == CHARTEVENT_CHART_CHANGE){         // オブジェクトがクリックされた
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
void CreateLabel(string aName, color aColor){
  int pixcel_x,pixcel_y;
  ChartTimePriceToXY( 0,0, Time[0], 0, pixcel_x,pixcel_y);
  pixcel_x = 0;
  // テキストラベルオブジェクト生成
  string _labelObjName = aName;
  ObjectCreate(_labelObjName,OBJ_LABEL,0,0,0);               // テキストラベルオブジェクト生成
  ObjectSet(_labelObjName,OBJPROP_XDISTANCE,pixcel_x);    // テキストラベルオブジェクトX軸位置設定
  ObjectSet(_labelObjName,OBJPROP_YDISTANCE,pixcel_y);    // テキストラベルオブジェクトY軸位置設定
  ObjectSetText(_labelObjName, _labelObjName , FONT_SIZE , "ＭＳ　ゴシック" , aColor); // テキストラベルオブジェクト、テキストタイプ設定
  // Print("desc:" + _labelObjName + "(" + IntegerToString(pixcel_x) + "/" + IntegerToString(pixcel_y) +")");
}

// ラベル関連を作成 high&low
void CreateLabelHighLow(StructBufferInfo &aBuffer){
  CreateLabel(aBuffer.nameHigh, aBuffer.c);
  CreateLabel(aBuffer.nameLow, aBuffer.c);
}

// ラベル関連を全て作成
void CreateLabelAll(StructBufferInfo &aBuffers[]){
  for(int i = 0; i < ArraySize(aBuffers); i++) {
    CreateLabelHighLow(aBuffers[i]);
  }
}

//--------------
// 更新
// ラベル関連を更新
void UpdateLabel(string aName, double aValue) {
  int pixcel_x,pixcel_y;
  ChartTimePriceToXY( 0,0, Time[0],aValue, pixcel_x,pixcel_y);
  pixcel_x = 0;
  string _labelObjName = aName;
  ObjectSet(_labelObjName,OBJPROP_XDISTANCE,pixcel_x);    // テキストラベルオブジェクトX軸位置設定
  ObjectSet(_labelObjName,OBJPROP_YDISTANCE,pixcel_y);    // テキストラベルオブジェクトY軸位置設定

}

// ラベル関連を更新 high&Low
void UpdateLabelHighLow(StructBufferInfo &aBuffer) {
  double _high = iHigh(NULL,PERIOD_D1,aBuffer.dayIndex);
  // printf("%d high:%f", day, _high);
  double _low = iLow(NULL,PERIOD_D1,aBuffer.dayIndex);
  // printf("%d low:%f", day, _low);
  for(int bar = 0; bar < Bars; bar++) {
    if(ArraySize(aBuffer.high) > 0) {
      aBuffer.high[bar] = _high;
      UpdateLabel(aBuffer.nameHigh, aBuffer.high[0]);
    }
    if(ArraySize(aBuffer.low) > 0) {
      aBuffer.low[bar] = _low;
      UpdateLabel(aBuffer.nameLow, aBuffer.low[0]);
    }
  }
} 

//　ラベル関連を全て更新
void UpdateLabelObjAll(StructBufferInfo &aBuffers[]) {
  for(int day = 0; day < ArraySize(aBuffers); day++) {
    UpdateLabelHighLow(aBuffers[day]);
  }
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
