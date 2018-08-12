//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                                    Copyright 2018, Yosuke Adachi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Yosuke Adachi"
#property link      ""
#property version   "1.111"
#property strict
#property indicator_chart_window

static const int DAYS = 4;  //表示する日数

//ライン
static const int LINE_WIDTH = 1;  //ライン幅
static color  LineHighStyles[] = {0, 0, 0, 0};  //高値ラインスタイル
static color  LineLowStyles[] = {0, 0, 0, 0}; //安値ラインスタイル
static color  LineHighColors[] = {Red, Green, Blue, Yellow};  //高値ライン色
static color  LineLowColors[] = {Red, Green, Blue, Yellow}; //安値ライン色

//ラベル
static string  ObjNameHigh = "H"; //高値ラベル
static string  ObjNameLow = "L";  //安値ラベル
static const int FONT_SIZE = 10; //フォントサイズ
static int printedYs[] = {0,0,0,0};

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){

  for(int i = 0; i < DAYS; i++) {
    double _high = iHigh(NULL,PERIOD_D1,i);
    printf("init _highs[%d]:%f",i, _high);
    CreateLineObj(_high, ObjNameHigh, i, LINE_WIDTH, LineHighStyles[i], LineHighColors[i]);

    double _low = iLow(NULL,PERIOD_D1,i);
    printf("init _lows[%d]:%f",i, _low);
    CreateLineObj(_low, ObjNameLow, i, LINE_WIDTH, LineLowStyles[i], LineLowColors[i]);
  }

  return(0);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){
  for(int i = 0; i < DAYS; i++){
    DeleteLineObj(ObjNameHigh, i);
    DeleteLineObj(ObjNameLow, i);
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
                const int& spread[]) {

  for(int i = 0; i < DAYS; i++) {
    double _high = iHigh(NULL,PERIOD_D1,i);
    printf("OnCalculate _highs[%d]:%f",i, _high);
    UpdateLineObj(_high, ObjNameHigh, i);

    double _low = iLow(NULL,PERIOD_D1,i);
    printf("OnCalculate _lows[%d]:%f",i, _low);
    UpdateLineObj(_low, ObjNameLow, i);
  }
  WindowRedraw();

  return(0);
}

// ライン関連を作成
void CreateLineObj(double dt, string aName, int aDayIndex, int aWidth, int aStyle, color aColor){
  //ライン
  string _name = CreateLineObjName(aName, aDayIndex);
  ObjectCreate(_name, OBJ_HLINE, 0, 0, dt);
  ObjectSet(_name, OBJPROP_WIDTH, aWidth);
  ObjectSet(_name, OBJPROP_STYLE, aStyle);
  ObjectSet(_name, OBJPROP_COLOR, aColor);

  //ラベル
  int pixcel_x,pixcel_y;
  ChartTimePriceToXY( 0,0, Time[0],dt, pixcel_x,pixcel_y);

  // テキストラベルオブジェクト生成
  string _labelObjName = CreateLabelObjName(_name);
  ObjectCreate(_labelObjName,OBJ_LABEL,0,0,0);               // テキストラベルオブジェクト生成
  ObjectSet(_labelObjName,OBJPROP_XDISTANCE,pixcel_x);    // テキストラベルオブジェクトX軸位置設定
  ObjectSet(_labelObjName,OBJPROP_YDISTANCE,pixcel_y);    // テキストラベルオブジェクトY軸位置設定
  ObjectSetText(_labelObjName, _name , FONT_SIZE , "ＭＳ　ゴシック" , aColor); // テキストラベルオブジェクト、テキストタイプ設定
  Print("desc:" + _name + "(" + IntegerToString(pixcel_x) + "/" + IntegerToString(pixcel_y) +")");
}

// ライン関連を更新
void UpdateLineObj(double dt, string aName, int aDayIndex) {
  string _name = CreateLineObjName(aName, aDayIndex);
  if(ObjectSet(_name, OBJPROP_PRICE1, dt) == false){
    Print(__FUNCTION__, " ObjectSet Error : ", GetLastError());
  }
} 

// ライン関連を削除
void DeleteLineObj(string aName, int aDayIndex) {
  string _name = CreateLineObjName(aName, aDayIndex);
  ObjectDelete(_name);
  ObjectDelete(CreateLabelObjName(_name));
}

// ラベルオブジェクト名作成
string CreateLabelObjName(string aLineName) {
  return aLineName+"ラベル";
}

// ラインオブジェクト名生成
string CreateLineObjName(string aName, int aDayIndex) {
  return aName + IntegerToString(aDayIndex);
}



//+------------------------------------------------------------------+
