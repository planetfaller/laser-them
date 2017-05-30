
data = csvread("dataD.dat");
dataP = csvread("dataP.dat");
dataT = csvread("dataT.dat");

nbins=10;
bins = 16;

% h = histfit(data,bins)

scatter(data,dataP);

std(data)
max(data)
min(data)
mean(data)

