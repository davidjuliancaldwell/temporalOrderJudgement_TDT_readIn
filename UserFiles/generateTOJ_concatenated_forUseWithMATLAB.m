%%  script to generate TOJs to be read in 
% this is a script to generate numbers to be read into MATLAB during the
% TOJ task 
% David.J.Caldwell 4.12.2018
%
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
    delaysTotal = [delaysTotal; delayRangeShuffle];
    
end

disp(['The number of trials in each block is ' num2str(length(delayRangeShuffle))])
disp(['The number of blocks are ' num2str(numBlocks)])
disp(['The total number of trials is ' num2str(numBlocks*length(delayRangeShuffle))])
