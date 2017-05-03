filename = 'data.dat';
data = csvread(filename);
nbins=10;
bins = 16;

h = histfit(data,bins)

std(data)
max(data)
min(data)
mean(data)

