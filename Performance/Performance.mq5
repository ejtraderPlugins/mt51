void OnStart()
{
   Performance();
}
void Performance() 
{
   double sum_profit = 0.0;
   double sum_loss = 0.0;
   int count_profit = 0;
   int count_loss = 0;
   double count_lots = 0.0;
   double points_profit = 0.0;
   double points_loss = 0.0;
 
   HistorySelect(0,TimeCurrent()); 
   uint     total=HistoryDealsTotal(); 
   ulong    ticket=0; 
   double   price; 
   double   profit; 
   double   lots;
   datetime time; 
   string   symbol; 
   long     type; 
   long     entry; 
   double in = 0;

   for(uint i=0;i<total;i++) 
   { 
      if((ticket=HistoryDealGetTicket(i))>0) 
      { 
         price =HistoryDealGetDouble(ticket,DEAL_PRICE); 
         time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME); 
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL); 
         type  =HistoryDealGetInteger(ticket,DEAL_TYPE); 
         entry =HistoryDealGetInteger(ticket,DEAL_ENTRY); 
         profit=HistoryDealGetDouble(ticket,DEAL_PROFIT); 
         lots  =HistoryDealGetDouble(ticket,DEAL_VOLUME); 
         //--- only for current symbol 
         if (symbol==Symbol()) {
            if (entry == DEAL_ENTRY_IN || entry == DEAL_ENTRY_INOUT) {
               in = price;
            }
            if(price && time) 
            { 
               if (profit > 0) {
                  count_profit++;
                  sum_profit += profit;
                  count_lots += lots;
                  points_profit += MathAbs(price - in);
                  
               }
               if (profit < 0) {
                  count_loss++;
                  sum_loss += profit;
                  count_lots += lots;
                  points_loss += MathAbs(price - in);
               }
               
            } 
         }
      } 
   }
   Print("===== Performance Summary =====");
   Print("Profit: R$ ", sum_profit, " (", count_profit, " trades)", 
         "     Loss: R$ ", sum_loss, " (", count_loss, " trades)");
   Print("Result: R$ ", sum_profit + sum_loss);
   Print("Win Ratio: ", DoubleToString(100 * (double)count_profit / (double)(count_profit+count_loss),0), "%",
         "     Profit to Loss Ratio: ", DoubleToString(100 * (double)sum_profit / (double)(sum_profit-sum_loss),0), "%");
   Print("Average Trade Profit: ", DoubleToString((double)sum_profit / (double)(count_profit),2), 
         "     Average Trade Loss: ", DoubleToString((double)sum_loss / (double)(count_loss),2));
   Print("Average Lots: ", DoubleToString((double)count_lots / (double)(count_profit+count_loss),2));
   Print("Profit Points: ", points_profit, "  Average: ", DoubleToString(points_profit / count_profit,2));
   Print("Loss Points: ", points_loss, "  Average: ", DoubleToString(points_loss / count_loss,2));
}
//+------------------------------------------------------------------+
