%% DJC - 4-6-2018
% script to generate TOJs to be read in

delayRange = input('What is the range of delays to use? (in milliseconds, with 0 being tactor delivery. \n -150 would be 150 ms before tactor, +150 would be 150 ms after tactor \n input as [-150,150] \n');

distBetween = 50; % 10 means 10 ms increments, 1 means 1 ms increments, 50 would be 50 ms increments
%

%delays = randi([delayRange(1) delayRange(2)],1,50); % this would be delays in 1 ms increments
delays = randi([delayRange(1)/distBetween delayRange(2)/distBetween],1,50); % this would be delays in 10 ms increments
delays = distBetween*delays;
% add in 2700 to represent tactor
delays = delays + 2700;
figure
histogram(delays,10)
% write these times to file for TOJ delivery

filename = sprintf('TOJ_times.txt');
fileID = fopen(filename,'w+');
fprintf(fileID,'%d\r\n',delays);
fclose(fileID);
