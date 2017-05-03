filename = 'data.dat';
data = csvread(filename);
nbins=10;
bins = 10;

h = histfit(data,bins)

std(data)
