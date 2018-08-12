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

static const int DAYS = 4;  //�\���������

//���C��
static const int LINE_WIDTH = 1;  //���C����
static color  LineHighStyles[] = {0, 0, 0, 0};  //���l���C���X�^�C��
static color  LineLowStyles[] = {0, 0, 0, 0}; //���l���C���X�^�C��
static color  LineHighColors[] = {Red, Green, Blue, Yellow};  //���l���C���F
static color  LineLowColors[] = {Red, Green, Blue, Yellow}; //���l���C���F

//���x��
static string  ObjNameHigh = "H"; //���l���x��
static string  ObjNameLow = "L";  //���l���x��
static const int FONT_SIZE = 10; //�t�H���g�T�C�Y
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

// ���C���֘A���쐬
void CreateLineObj(double dt, string aName, int aDayIndex, int aWidth, int aStyle, color aColor){
  //���C��
  string _name = CreateLineObjName(aName, aDayIndex);
  ObjectCreate(_name, OBJ_HLINE, 0, 0, dt);
  ObjectSet(_name, OBJPROP_WIDTH, aWidth);
  ObjectSet(_name, OBJPROP_STYLE, aStyle);
  ObjectSet(_name, OBJPROP_COLOR, aColor);

  //���x��
  int pixcel_x,pixcel_y;
  ChartTimePriceToXY( 0,0, Time[0],dt, pixcel_x,pixcel_y);

  // �e�L�X�g���x���I�u�W�F�N�g����
  string _labelObjName = CreateLabelObjName(_name);
  ObjectCreate(_labelObjName,OBJ_LABEL,0,0,0);               // �e�L�X�g���x���I�u�W�F�N�g����
  ObjectSet(_labelObjName,OBJPROP_XDISTANCE,pixcel_x);    // �e�L�X�g���x���I�u�W�F�N�gX���ʒu�ݒ�
  ObjectSet(_labelObjName,OBJPROP_YDISTANCE,pixcel_y);    // �e�L�X�g���x���I�u�W�F�N�gY���ʒu�ݒ�
  ObjectSetText(_labelObjName, _name , FONT_SIZE , "�l�r�@�S�V�b�N" , aColor); // �e�L�X�g���x���I�u�W�F�N�g�A�e�L�X�g�^�C�v�ݒ�
  Print("desc:" + _name + "(" + IntegerToString(pixcel_x) + "/" + IntegerToString(pixcel_y) +")");
}

// ���C���֘A���X�V
void UpdateLineObj(double dt, string aName, int aDayIndex) {
  string _name = CreateLineObjName(aName, aDayIndex);
  if(ObjectSet(_name, OBJPROP_PRICE1, dt) == false){
    Print(__FUNCTION__, " ObjectSet Error : ", GetLastError());
  }
} 

// ���C���֘A���폜
void DeleteLineObj(string aName, int aDayIndex) {
  string _name = CreateLineObjName(aName, aDayIndex);
  ObjectDelete(_name);
  ObjectDelete(CreateLabelObjName(_name));
}

// ���x���I�u�W�F�N�g���쐬
string CreateLabelObjName(string aLineName) {
  return aLineName+"���x��";
}

// ���C���I�u�W�F�N�g������
string CreateLineObjName(string aName, int aDayIndex) {
  return aName + IntegerToString(aDayIndex);
}



//+------------------------------------------------------------------+
