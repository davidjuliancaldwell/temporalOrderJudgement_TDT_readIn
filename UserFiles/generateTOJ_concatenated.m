%% DJC - 4-12-2018
% script to generate TOJs to be read in
timeToPerception = input('What was the rough time to perception? (ms) \n');
delayRange = input('What is the range of delays to use? (in milliseconds, with 0 being tactor delivery. \n -150 would be 150 ms before tactor, +150 would be 150 ms after tactor \n input as [-150,150] \n');
distBetween = input('What is the distance between each offset (ms) we want to use? \n '); % 10 means 10 ms increments, 1 means 1 ms increments, 50 would be 50 ms increments
delayRange = [delayRange(1):distBetween:delayRange(2)];
fprintf(['This is at least ' num2str(length(delayRange)) ' trials to cover each element in the vector \n \n']);
%
numTrials = input('What is the number of repetitions of the above vector within each block? \n');
numBlocks = input('How many blocks do we want to run? \n');
delaysTotal = [];
delayRange = delayRange - timeToPerception;  

%%
for i = 1:numBlocks
    
    delayRangeRepped = repmat(delayRange,1,numTrials);
    delayRangeShuffle = delayRangeRepped(randperm(length(delayRangeRepped)));
    delaysTotal = [delaysTotal delayRangeShuffle];
    
end
%%
% add in 2700 to represent tactor
delays = delaysTotal + 2700;

figure
histogram(delaysTotal,10)
% write these times to file for TOJ delivery

figure
plot(delaysTotal)

filename = sprintf('TOJ_times.txt');
fileID = fopen(filename,'w+');
fprintf(fileID,'%d\r\n',delaysTotal);
fclose(fileID);
