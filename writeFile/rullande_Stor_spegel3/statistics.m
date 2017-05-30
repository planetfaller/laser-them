clear all
data = csvread("dataD.dat");
dataP = csvread("dataP.dat");
dataT = csvread("dataT.dat");

data(data>1500)=[];

nbins=10;
bins = 16;

h = histfit(data,bins)



%scatter(data,dataP);

std(data)
max(data)
min(data)
mean(data)
numberOnes = sum(data(1,:)==1) % find number of ones
above5 = (sum(data(1,:)>500) / length(data)) * 100
andel = (numberOnes / length(data)) * 100

