//+------------------------------------------------------------------+
//|                                                       Mark 1.mq5 |
//|                                                      Joshua Blew |
//+------------------------------------------------------------------+
#property copyright "Joshua Blew"
#property version   "1.00"

//--- input parameters
input int      StopLoss=30;      // Stop Loss
input int      TakeProfit=60;   // Take Profit
input int      BB_Period=5;      // Bollinger Bands Period
input int      EA_Magic=12345;   // EA Magic Number
input double   Lot=0.1;          // Lots to Trade

//--- Other parameters
int handle; // handle for our Bollinger Bands indicator
double upper[],mid[],lower[]; // Dynamic arrays to hold the values of Upper, Middle, & Lower Band values for each bars
double p_low; // Variable to store the close value of a bar
double p_high;
int STP, TKP;   // To be used for Stop Loss & Take Profit values

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  //--- Get handle for Bollinger Bands indicator
   handle=iBands(_Symbol,PERIOD_D1,BB_Period,0,2,PRICE_CLOSE);
   //--- What if handle returns Invalid Handle
   if(handle<0)
   {
      Alert("Error Creating Handles for indicators - error: ",GetLastError(),"!!");
      return(-1);
   }

//--- Let us handle currency pairs with 5 or 3 digit prices instead of 4
   STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release our indicator handles
   IndicatorRelease(handle);
  }
  
void func(double &upperVal, double &lowerVal)
   { 
     ArraySetAsSeries(mid,true);
     ArraySetAsSeries(upper,true);
     ArraySetAsSeries(lower,true);
     
     CopyBuffer(handle,0,0,3,mid);
     CopyBuffer(handle,1,0,3,upper);
     CopyBuffer(handle,2,0,3,lower);
     
     //double midVal = mid[0];
     upperVal = upper[0];
     lowerVal = lower[0];
     
     return;
   }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Do we have enough bars to work with
   if(Bars(_Symbol,_Period)<6) // if total bars is less than 60 bars
     {
      Alert("We have less than 6 bars, EA will now exit!!");
      return;
     }  

// We will use the static Old_Time variable to serve the bar time.
// At each OnTick execution we will check the current bar time with the saved one.
// If the bar time isn't equal to the saved time, it indicates that we have a new tick.

   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;

// copying the last bar time to the element New_Time[0]
   int copied=CopyTime(_Symbol,_Period,0,1,New_Time);
   if(copied>0) // ok, the data has been copied successfully
     {
      if(Old_Time!=New_Time[0]) // if old time isn't equal to new bar time
        {
         double upperVal;
         double lowerVal;
         func(upperVal, lowerVal);
       
         IsNewBar=true;   // if it isn't a first call, the new bar has appeared
         
         if(MQL5InfoInteger(MQL5_DEBUGGING)) Print("We have new bar here ",New_Time[0]," old time was ",Old_Time);
         Old_Time=New_Time[0];            // saving bar time

        }
     }
   else
     {
      Alert("Error in copying historical times data, error =",GetLastError());
      ResetLastError();
      return;
     }

//--- EA should only check for new trade if we have a new bar
   if(IsNewBar==false)
     {
      return;
     }
 
//--- Do we have enough bars to work with
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<6) // if total bars is less than 60 bars
     {
      Alert("We have less than 6 bars, EA will now exit!!");
      return;
     }

//--- Define some MQL5 Structures we will use for our trade
   MqlTick Latest_Price;      // To be used for getting recent/latest price quotes
   MqlTradeRequest mrequest;  // To be used for sending our trade requests
   MqlTradeResult mresult;    // To be used to get our trade results
   MqlRates mrate[];          // To be used to store the prices, volumes and spread of each bar
   ZeroMemory(mrequest);      // Initialization of mrequest structure
   
   // Info of the last tick.
   //-----------------------

   // To be used for getting recent/latest price quotes
   SymbolInfoTick(Symbol() ,Latest_Price); // Assign current prices
   
   // The BID price.
   static double bidValue;
   // The ASK price.
   static double askValue;
   
   bidValue = Latest_Price.bid; // Current Bid price.
   askValue = Latest_Price.ask; // Current Ask price.
       
/*
     Let's make sure our arrays values for the Rates, ADX Values and MA values 
     is store serially similar to the timeseries array
*/
// the rates arrays
   ArraySetAsSeries(mrate,true);



//--- Get the details of the latest 3 bars
   if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
     {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      ResetLastError();
      return;
     }
     
//--- we have no errors, so continue
//--- Do we have positions opened already?
   bool Buy_opened=false;  // variable to hold the result of Buy opened position
   bool Sell_opened=false; // variables to hold the result of Sell opened position

   if(PositionSelect(_Symbol)==true) // we have an opened position
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  //It is a Buy
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; // It is a Sell
        }
     }
  
/*
    1. Check for a long/Buy Setup : MA-8 increasing upwards, 
    previous price close above it, ADX > 22, +DI > -DI
*/
   //--- Declare bool type variables to hold our Buy Conditions
   bool Buy_Condition_1=(bidValue < lowerVal); // MA-8 Increasing upwards

//--- Putting all together   
   if(Buy_Condition_1)
     {
      // any opened Buy position?
      if(Buy_opened)
        {
         Alert("We already have a Buy Position!!!");
         return;    // Don't open a new Buy Position
        }
      ZeroMemory(mrequest);
      mrequest.action = TRADE_ACTION_DEAL;                                  // immediate order execution
      mrequest.price = NormalizeDouble(Latest_Price.ask,_Digits);           // latest ask price
      mrequest.sl = NormalizeDouble(Latest_Price.ask - STP*_Point,_Digits); // Stop Loss
      mrequest.tp = NormalizeDouble(Latest_Price.ask + TKP*_Point,_Digits); // Take Profit
      mrequest.symbol = _Symbol;                                            // currency pair
      mrequest.volume = Lot;                                                 // number of lots to trade
      mrequest.magic = EA_Magic;                                             // Order Magic Number
      mrequest.type = ORDER_TYPE_BUY;                                        // Buy Order
      mrequest.type_filling = ORDER_FILLING_FOK;                             // Order execution type
      mrequest.deviation=100;                                                // Deviation from current price
      //--- send order
      OrderSend(mrequest,mresult);
      // get the result code
      if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
        {
         Alert("A Buy order has been successfully placed with Ticket#:",mresult.order,"!!");
        }
      else
        {
         Alert("The Buy order request could not be completed -error:",GetLastError());
         ResetLastError();           
         return;
        }
        
     }
/*
    2. Check for a Short/Sell Setup : MA-8 decreasing downwards, 
    previous price close below it, ADX > 22, -DI > +DI
*/
//--- Declare bool type variables to hold our Sell Conditions
   bool Sell_Condition_1 = (askValue > upperVal);  // MA-8 decreasing downwards

//--- Putting all together
   if(Sell_Condition_1)
     {
      // any opened Sell position?
      if(Sell_opened)
        {
         Alert("We already have a Sell position!!!");
         return;    // Don't open a new Sell Position
        }
      ZeroMemory(mrequest);
      mrequest.action=TRADE_ACTION_DEAL;                                // immediate order execution
      mrequest.price = NormalizeDouble(Latest_Price.bid,_Digits);           // latest Bid price
      mrequest.sl = NormalizeDouble(Latest_Price.bid + STP*_Point,_Digits); // Stop Loss
      mrequest.tp = NormalizeDouble(Latest_Price.bid - TKP*_Point,_Digits); // Take Profit
      mrequest.symbol = _Symbol;                                          // currency pair
      mrequest.volume = Lot;                                              // number of lots to trade
      mrequest.magic = EA_Magic;                                          // Order Magic Number
      mrequest.type= ORDER_TYPE_SELL;                                     // Sell Order
      mrequest.type_filling = ORDER_FILLING_FOK;                          // Order execution type
      mrequest.deviation=100;                                             // Deviation from current price
      //--- send order
      OrderSend(mrequest,mresult);
      // get the result code
      if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
        {
         Alert("A Sell order has been successfully placed with Ticket#:",mresult.order,"!!");
        }
      else
        {
         Alert("The Sell order request could not be completed -error:",GetLastError());
         ResetLastError();
         return;
        }
        
     }
   return;
  }
//+------------------------------------------------------------------+
