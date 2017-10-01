//+------------------------------------------------------------------+
//|                                                    Tabajara.mq5  |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//---- plot ColorBars
#property indicator_label1  "Tabajara"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  Green,Red,DarkRed,DarkGreen
#property indicator_label1  "Open;High;Low;Close"
//--- indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];

double MA_value = 0.0;
double MA_factor = 2.0 / (20 + 1);

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicators
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//--- don't show indicator data in DataWindow
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int  i=0;
   
//--- set position for beginning
   if(i<prev_calculated) i=prev_calculated-1;
//--- start calculations
   while(i<rates_total && !IsStopped())
     {
      ExtOpenBuffer[i]=open[i];
      ExtHighBuffer[i]=high[i];
      ExtLowBuffer[i]=low[i];
      ExtCloseBuffer[i]=close[i];
      
      MA_value += (close[i] - MA_value) * MA_factor;
      
      if (close[i] > MA_value) {
         if (close[i] > open[i]) ExtColorsBuffer[i]=0.0;
         else ExtColorsBuffer[i]=3.0;
      }
      else {
         if (close[i] < open[i]) ExtColorsBuffer[i]=1.0;
         else  ExtColorsBuffer[i]=2.0;
      }
      //---
      i++;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
