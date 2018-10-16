# --- Imports ---
import pandas as pd
import numpy as np
from alpha_vantage.foreignexchange import ForeignExchange
import statistics
import time
import schedule
# ------

# ////////////////

# --- Globals ---
ALPHAVANTAGE_API_KEY = 'NPV7P4MGLYKO6A9S'
base = 'EUR'
quote = 'USD'
entryThreshold = 0.0005

# --- ACCOUNT INFO ---
balance = 10000
tradeVol = 0.10 
maxLev = 25 
positionCount = 0 
spread = 0.00075 # EUR/USD
minBandSpread = 0.0040 
TP1 = minBandSpread/3 

# --- Alpha Vantage Connection ---
fx = ForeignExchange(key=ALPHAVANTAGE_API_KEY, output_format='pandas')
# ------

# ////////////////

# --- PRICE FUNCTIONS ---
def getHourly(fx, base, quote):
	data, meta = fx.get_currency_exchange_intraday(base, quote, '60min', 'compact')
	data = data.iloc[::-1]
	avgWindow = data.iloc[0:5]
	print (avgWindow)

def getLatest(fx, base, quote):
	data, meta = fx.get_currency_exchange_intraday(base, quote, '1min', 'compact')
	data = data.iloc[::-1]
	close = data.iloc[0][3]
	print (close)

def bollingerBands(values, window):
	values = []
	for i, x in window.iterrows():
		values.append(x[3])
	average = round(sum(values)/5, 4)

	stdev = statistics.stdev(values)
	upper = round(average + (stdev*2), 4)
	middle = average
	lower = round(average - (stdev*2), 4)
	return upper, middle, lower
# ------

# ////////////////

# --- CONDITIONALS ---
def isLong(lower, latest):
	if latest < lower-entryThreshold:
		return True
	else:
		return False

def isShort(upper, latest):
	if latest > upper+entryThreshold:
		return True
	else:
		return False
# ------

# ////////////////

# --- TRADING ---
schedule.every().hour.do(getHourly, fx, base, quote)
schedule.every().minutes.do(getLatest, fx, base, quote)

while True:
	schedule.run_pending()
	time.sleep(1)








# ////////////////






# count  101.000000
# mean    69.811881
# std     32.248322
# min      8.000000
# 25%     54.000000
# 50%     72.000000
# 75%     91.000000
# max    151.000000



####################

'''
PSEUDOCODE
'''



     




