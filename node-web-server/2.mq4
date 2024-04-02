//+------------------------------------------------------------------+
//|                                                    GetData.mq4   |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input string symbolName = "EURUSD"; // Symbol name
input ENUM_TIMEFRAMES timeframe = PERIOD_M5; // Change to PERIOD_M5 for 5-minute timeframe
input int barsToRetrieve = 100; // Number of bars to retrieve

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Clean up any resources if needed
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    double accountNumber = AccountNumber(); // Account number
    double accountBalance = AccountBalance(); // Account balance
    double accountEquity = AccountEquity(); // Account equity
    double drawdown = CalculatePeakDrawdown(barsToRetrieve); // Peak drawdown
    datetime startDate = GetChartStartDate(); // Start date
    
    Print("Account Number: ", accountNumber,
          ", Account Balance: ", accountBalance,
          ", Account Equity: ", accountEquity,
          ", Peak Drawdown: ", drawdown, "%",
          ", Chart Start Date: ", TimeToString(startDate, TIME_DATE | TIME_MINUTES));
          
    int fileHandle = FileOpen("output.txt", FILE_WRITE | FILE_TXT | FILE_CSV); // Open the file for writing
    
    if (fileHandle != INVALID_HANDLE)
    {
        // Convert data to strings
        string data_1 = DoubleToString(accountNumber, 0);
        string data_2 = DoubleToString(accountBalance, 2);
        string data_3 = DoubleToString(accountEquity, 2);
        string data_4 = DoubleToString(drawdown, 2);
        string data_5 = TimeToString(startDate, TIME_DATE | TIME_MINUTES);
        
        // Write data to the text file
        FileWrite(fileHandle, data_1 + "," + data_2 + "," + data_3 + "," + data_4 + "," + data_5);
        
        // Close the file
        FileClose(fileHandle);
    }
    else
    {
        Print("Failed to open file for writing!");
    }
}

//+------------------------------------------------------------------+
//| Calculate peak drawdown function                                |
//+------------------------------------------------------------------+
double CalculatePeakDrawdown(int barsToCheck)
{
    double peakEquity = AccountBalance(); // Initialize with current equity
    double lowestEquity = AccountEquity(); // Initialize with current equity
    double drawdown = 0.0;
    if (peakEquity > 0.0)
    {
        drawdown = (peakEquity - lowestEquity) / peakEquity;
    }

    return drawdown;
}

//+------------------------------------------------------------------+
//| Get chart start date function                                    |
//+------------------------------------------------------------------+
datetime GetChartStartDate()
{
    datetime startDate = 0;
    int limit = MathMin(Bars, barsToRetrieve); // Ensure we don't exceed the number of available bars

    for (int i = 0; i < limit; i++)
    {
        if (Time[i] != 0)
        {
            startDate = Time[i];
            break;
        }
    }

    if (startDate == 0)
    {
        Print("Error: Unable to determine the start date of the chart's data.");
    }

    return startDate;
}
