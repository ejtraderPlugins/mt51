//+------------------------------------------------------------------+
//|                                               ChartTraderRVR.mq5 |
//|                         Copyright 2017, Rodrigo Valceli Raimundo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Rodrigo Valceli Raimundo"
#property link      ""
#property version   "1.00"
#property description "Permite enviar ordens OCO diretamente pelo gráfico usando o mouse. A tecla shift serve para ativar/desativar o modo COMPRA e a tecla control ativa/desativa o modo VENDA. As teclas devem ser pressionadas somente uma vez para ligar/desligar o modo, ou seja, NÃO mantenha as teclas pressionadas como no Tryd ou no ProfitChart."

#include <Trade\Trade.mqh>

input double sl = 100.0; // StopLoss (exemplos: 100.0 pra indice, 10.0 pra dolar, 0.001 pra forex)
input double tp = 100.0; // TakeProfit
input int    vol = 1;  // Quantidade de lotes
input ulong  max_slippage = ULONG_MAX; // Slippage
input bool   exibir_confirmacao = true; // Exibe mensagem para confirmar o envio da ordem
input ENUM_ORDER_TYPE_TIME validade = ORDER_TIME_DAY; // Validade da ordem 

bool buy = false;
bool sell = false;
double price = 0.0;
double tick_size = 0.0;
double tick = 0.0;
double point = 0.0;

CTrade trader;

void OnInit() {
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, true);
   tick_size = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   tick = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);
   point = SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   
   trader.SetDeviationInPoints(max_slippage);
   trader.LogLevel(LOG_LEVEL_ALL);
   trader.SetExpertMagicNumber(1337);
   
   trader.SetTypeFilling(ORDER_FILLING_RETURN);
   
   Print("Tick size: ", tick_size);
   Print("Tick: ", tick);
   Print("Point: ", point);
   // no caso de forex
   //if (tick > tick_size) tick = tick_size;
}


void Update(int x, int y) {
   double sl_price = price, tp_price = price;
   string op = "buy ";
   if (buy) {
      sl_price -= sl;
      tp_price += tp;
   }
   else if (sell) {
      sl_price += sl;
      tp_price -= tp;
      op = "sell ";
   }
   
   ObjectMove(0, "price-line", 0, 0, price);
   ObjectMove(0, "sl-line",  0, 0, sl_price);
   ObjectMove(0, "tp-line",  0, 0, tp_price);
   
   ObjectSetInteger(0, "price-text", OBJPROP_XDISTANCE, x + 20);
   ObjectSetInteger(0, "price-text", OBJPROP_YDISTANCE, y + (buy ? -20 : 10));
   ObjectSetString(0, "price-text", OBJPROP_TEXT, "Click to "+ op + IntegerToString(vol) + " at " + (string)price);
    
   ChartRedraw(0);
}

void Draw() {
   double sl_price = price, tp_price = price;
   int color_price = clrGreen, color_tpsl = clrRed;
   string op = "Buy ";
   if (buy) {
      sl_price -= sl;
      tp_price += tp;
      
      Print("Buy mode: ", price);
   }
   else if (sell) {
      sl_price += sl;
      tp_price -= tp;
      color_price = clrRed;
      color_tpsl = clrGreen;
      op = "Sell ";
      
      Print("Sell mode: ", price);
   }
   
   ObjectCreate(0, "price-line", OBJ_HLINE, 0, 0, price);
   ObjectCreate(0, "sl-line",    OBJ_HLINE, 0, 0, sl_price);
   ObjectCreate(0, "tp-line",    OBJ_HLINE, 0, 0, tp_price);  
   ObjectSetInteger(0,"price-line", OBJPROP_COLOR, color_price);
   ObjectSetInteger(0,"tp-line",    OBJPROP_COLOR, color_tpsl);
   ObjectSetInteger(0,"sl-line",    OBJPROP_COLOR, color_tpsl); 
   ObjectSetInteger(0,"price-line", OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0,"tp-line",    OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0,"sl-line",    OBJPROP_STYLE, STYLE_DASH); 
   ObjectSetString(0,"price-line", OBJPROP_TOOLTIP, "\n");
   ObjectSetString(0,"tp-line",    OBJPROP_TOOLTIP, "\n");
   ObjectSetString(0,"sl-line",    OBJPROP_TOOLTIP, "\n");
   
   ObjectCreate(0, "price-text", OBJ_LABEL, 0, 0, 0);
   //ObjectSetString(0, "price-text", OBJPROP_TEXT, op + (string)vol + " at " + (string)price);
   ObjectSetString(0, "price-text", OBJPROP_FONT, "Courier New");
   ObjectSetInteger(0, "price-text", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "price-text", OBJPROP_COLOR, color_price);
   ObjectSetInteger(0, "price-text", OBJPROP_SELECTABLE, false);
   ChartRedraw(0);
}

void Destroy() {
   ObjectDelete(0, "price-line");
   ObjectDelete(0, "tp-line");
   ObjectDelete(0, "sl-line");
   ObjectDelete(0, "price-text");
   ObjectDelete(0, "tp-text");
   ObjectDelete(0, "sl-text");
   ChartRedraw(0);
}

double FixPrice(double p) {
   double r = MathMod(p, tick_size);
    if (r < point)
        return p;

    return p + tick_size - r;
}

void OnChartEvent(const int id, 
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
{
   switch(id)
   {
      
      case CHARTEVENT_KEYDOWN:
      {
         if (lparam == 16) {
            sell = false;
            buy = buy ? false : true;
         } else if (lparam == 17) {
            buy = false;
            sell = sell ? false : true;
         }
         if (buy || sell) {
            Draw();
         } else {
            Destroy();
         }
         break;
      }
      case CHARTEVENT_MOUSE_MOVE:
      {
         int subwindow;
         datetime time;
         double _price;
         ChartXYToTimePrice(0, (int)lparam, (int)dparam, subwindow, time, _price);
         _price = FixPrice(_price);
         if (buy || sell) {
            if (_price != price) {
               price = _price;
               Update((int)lparam, (int)dparam);
               Sleep(100);
            }
         } else {
            price = _price;
         }
         
         break;
      }
      case CHARTEVENT_CLICK:
      {
         if (buy || sell) {
            BuySell();
         }
         break;
      }     
   }
 }
 
 
 void BuySell() {
   string op = buy ? "compra" : "venda";
   int ok = 1;
   if (exibir_confirmacao) { 
       ok = MessageBox("Confirmar "+op+" de "+(string)vol+" a "+(string)price+"?", "Confirmar operação...",  MB_APPLMODAL | MB_OKCANCEL);
   }
   
   MqlTick t;
   SymbolInfoTick(Symbol(), t);
            
   if (ok == 1) {
     
      if (buy) {
         if (price > t.last) {
            trader.BuyStop(vol,price,Symbol(), price - sl, price + tp, validade);
         } else {
            trader.BuyLimit(vol,price,Symbol(), price - sl, price + tp, validade);
         }
      }
      else if (sell) {
         if (price > t.last) {
            trader.SellLimit(vol,price,Symbol(), price + sl, price - tp, validade);
         } else {
            trader.SellStop(vol,price,Symbol(), price + sl, price - tp, validade);
         }
      }
   }
   
   buy = false;
   sell = false;
   Destroy();
 }