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
    datetime chartStartDate = GetChartStartDate(); // Start date
    
    // Construct the data to send in the request body
    string postData = "accountNumber=" + DoubleToString(accountNumber, 0) +
                      "&accountBalance=" + DoubleToString(accountBalance, 2) +
                      "&accountEquity=" + DoubleToString(accountEquity, 2) +
                      "&drawdown=" + DoubleToString(drawdown, 2) +
                      "&chartStartDate=" + TimeToString(chartStartDate, TIME_DATE | TIME_MINUTES);
    Print(postData);
    
    // Set the timeout value (in milliseconds)
    int timeout = 5000; // 5 seconds
    
    // Set the URL of the Node.js server
    string url = "http://localhost/test.php";
    
    // Convert postData to char array
    char postDataArray[];
    StringToCharArray(postData, postDataArray);
    
    // Initialize result and headers arrays
    char result[];
    string headers;
    
    // Perform a POST request to send data
    int res = WebRequest("GET", url, NULL, NULL, timeout, postDataArray, ArraySize(postDataArray) - 1, result, headers);
    
    // Checking errors
    if (res == -1)
    {
        Print("Error in WebRequest. Error code =", GetLastError());
    }
    else
    {
        PrintFormat("Data sent successfully to the server.");
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
    if(peakEquity > 0.0) {
    
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
