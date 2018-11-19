
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix


seed = 52
np.random.seed(seed)
scaler = MinMaxScaler()


data = pd.read_csv('AAPL-TestData.csv', usecols=(6,7,8,9,10,11,12,13))


X = data.iloc[:,0:7]
Y = data.iloc[:,7]


# sampleX = X.tail(25)
# sampleY = Y.tail(25)

# X = X[:-25]
# Y = Y[:-25]



X[['MACD_Hist', 'MACD', 'MACD_Signal', 'RSI', 'WILLR', 'ADX', 'MOM']] = scaler.fit_transform(X[['MACD_Hist', 'MACD', 'MACD_Signal', 'RSI', 'WILLR', 'ADX', 'MOM']])

# x_train, x_test, y_train, y_test = train_test_split(X, Y, train_size=None, test_size=0.01, shuffle=False, random_state=seed)


X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size=0.2, shuffle=False, random_state=seed)

X_test, X_val, y_test, y_val = train_test_split(X_test, y_test, test_size=0.1, shuffle=True, random_state=seed)




# INIT MODEL
rfc = RandomForestClassifier(n_estimators=300, max_depth=5)

# TRAIN
rfc.fit(X_train, y_train)

preds = rfc.predict(X_val).tolist()

probs = rfc.predict_proba(X_val).tolist()
# score = rfc.score(X_val, y_val)
# conmax = confusion_matrix(y_val, preds)
# print(conmax)
# print (score)

print(rfc.predict(X_val))
print (y_val)



for index, i in enumerate(probs):
	if i[0] > 0.90 or i[1] > 0.90:
		print (index)

# All predictions with probabilities > 90% are correct

'''

[1 1 0 1 0 0 0 1 1 0 1 1 0 0 1 1 1 0 1 1 0]

944     1
862     1
894     0
879     0
907     0
842     0
1012    1
898     0
881     1
989     1
968     1
913     1
908     0
846     0
940     1
926     1
859     1
1020    1
941     1
822     1
845     0

0
1
2
4
12
14
15
16
18

'''



