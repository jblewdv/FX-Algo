#property copyright "Joshua Blew"
#property version   "1.00"

input int      StopLoss=30;   
input int      TakeProfit=60;   
input int      BB_Period=5;     
input int      EA_Magic=12345;  
input double   Lot=0.1;          

int handle; 
double upper[],mid[],lower[]; 
int STP, TKP;  
double upperVal,lowerVal,bandwidth;

int OnInit()
  {
   handle=iBands(_Symbol,PERIOD_D1,BB_Period,0,2,PRICE_CLOSE);
   
   if(handle<0)
   {
      Alert("Error Creating Handles for indicators - error: ",GetLastError(),"!!");
      return(-1);
   }

   STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
   return(0);
  }
  
  
void OnDeinit(const int reason)
  {
   IndicatorRelease(handle);
  }
  
void func(double &upperVal,&lowerVal,&bandwidth)
   { 
     ArraySetAsSeries(mid,true);
     ArraySetAsSeries(upper,true);
     ArraySetAsSeries(lower,true);
     
     CopyBuffer(handle,0,0,3,mid);
     CopyBuffer(handle,1,0,3,upper);
     CopyBuffer(handle,2,0,3,lower);
     
     //double midVal = mid[0];
     upperVal = NormalizeDouble(upper[0],5);
     lowerVal = NormalizeDouble(lower[0],5);
     bandwidth = upperVal-lowerVal;
   }
   
   
void OnTick()
  {
   if(Bars(_Symbol,_Period)<6) 
     {
      Alert("We have less than 6 bars, EA will now exit!!");
      return;
     }  

   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;

   int copied=CopyTime(_Symbol,_Period,0,1,New_Time);
   if(copied>0) 
     {
      if(Old_Time!=New_Time[0])
        {
         func(upperVal, lowerVal, bandwidth);
       
         IsNewBar=true;  
         
         if(MQL5InfoInteger(MQL5_DEBUGGING)) Print("We have new bar here ",New_Time[0]," old time was ",Old_Time);
         Old_Time=New_Time[0];        

        }
     }
   else
     {
      Alert("Error in copying historical times data, error =",GetLastError());
      ResetLastError();
      return;
     }
     
   if(IsNewBar==false)
     {
      return;
     }

   MqlTick Latest_Price;      
   MqlTradeRequest mrequest;
   MqlTradeResult mresult;    
   MqlRates mrate[];          
   ZeroMemory(mrequest);     
   
   SymbolInfoTick(Symbol() ,Latest_Price); 
  
   static double bidValue;
   static double askValue;
   
   bidValue = Latest_Price.bid;
   askValue = Latest_Price.ask;
       
   ArraySetAsSeries(mrate,true);

   if(CopyRates(_Symbol,_Period,0,6,mrate)<0)
     {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      ResetLastError();
      return;
     }
     
   bool Buy_opened=false;  
   bool Sell_opened=false; 

   if(PositionSelect(_Symbol)==true)
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; 
        }
     }
  
   bool Buy_Condition_1=(bidValue < lowerVal); 
   bool Buy_Condition_2=(bandwidth > 0.0030);

   if(Buy_Condition_1 && Buy_Condition_2)
     {
      if(Buy_opened)
        {
         Alert("We already have a Buy Position!!!");
         return;    
        }
      ZeroMemory(mrequest);
      mrequest.action = TRADE_ACTION_DEAL;                                 
      mrequest.price = NormalizeDouble(Latest_Price.ask,_Digits);           
      mrequest.sl = NormalizeDouble(Latest_Price.ask - STP*_Point,_Digits);
      mrequest.tp = NormalizeDouble(Latest_Price.ask + TKP*_Point,_Digits);
      mrequest.symbol = _Symbol;                                          
      mrequest.volume = Lot;                                                 
      mrequest.magic = EA_Magic;                                         
      mrequest.type = ORDER_TYPE_BUY;              
      mrequest.type_filling = ORDER_FILLING_FOK;               
      mrequest.deviation=100;                                              
  
      OrderSend(mrequest,mresult);
 
      if(mresult.retcode==10009 || mresult.retcode==10008)
        {
         Alert("Buy order successfully placed - Ticket#:",mresult.order,"!!");
        }
      else
        {
         Alert("Buy order request couldn't be completed -error:",GetLastError());
         ResetLastError();           
         return;
        }
        
     }

   bool Sell_Condition_1 = (askValue > upperVal); 
   bool Sell_Condition_2 = (bandwidth > 0.0030);

   if(Sell_Condition_1 && Sell_Condition_2)
     {
      if(Sell_opened)
        {
         Alert("We already have a Sell position!!!");
         return; 
        }
      ZeroMemory(mrequest);
      mrequest.action=TRADE_ACTION_DEAL;                           
      mrequest.price = NormalizeDouble(Latest_Price.bid,_Digits);           
      mrequest.sl = NormalizeDouble(Latest_Price.bid + STP*_Point,_Digits); 
      mrequest.tp = NormalizeDouble(Latest_Price.bid - TKP*_Point,_Digits); 
      mrequest.symbol = _Symbol;                                       
      mrequest.volume = Lot;                                       
      mrequest.magic = EA_Magic;                       
      mrequest.type= ORDER_TYPE_SELL;                  
      mrequest.type_filling = ORDER_FILLING_FOK;    
      mrequest.deviation=100;                                       
 
      OrderSend(mrequest,mresult);
  
      if(mresult.retcode==10009 || mresult.retcode==10008) 
        {
         Alert("Sell order successfully placed - Ticket#:",mresult.order,"!!");
        }
      else
        {
         Alert("Sell order request couldn't be completed -error:",GetLastError());
         ResetLastError();
         return;
        }
        
     }
   return;
  }
//+------------------------------------------------------------------+
