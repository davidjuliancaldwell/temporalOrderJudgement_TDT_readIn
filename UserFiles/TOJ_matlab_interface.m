%% TOJ_Matlab_interface
% DJC - 4-23-2018

% generate the delaysTotal which will be used for everything that follows
generateTOJ_concatenated_forUseWithMATLAB
%%
%%%%%%%%%%%%%%%%
close all;

%% Open connection with TDT and begin program
DA = actxcontrol('TDevAcc.X');
DA.ConnectServer('Local'); %initiates a connection with an OpenWorkbench server. The connection adds a client to the server
pause(1)

while DA.CheckServerConnection ~= 1
    disp('OpenWorkbench is not connected to server. Trying again...')
    close all
    DA = actxcontrol('TDevAcc.X');
    DA.ConnectServer('Local');
    pause(1) % seconds
end
clc
disp('Connected to server')

% If OpenWorkbench is not in Record mode, then this will set it to record
if DA.GetSysMode ~= 3
    DA.SetSysMode(3);
    while DA.GetSysMode ~= 3
        pause(.1)
    end
end

% Before proceeding make sure that the system is armed:
if DA.GetTargetVal('RZ5D.IsArmed') == 0
    disp('System is not armed');
elseif DA.GetTargetVal('RZ5D.IsArmed') == 1
    disp('System armed');
end

while DA.GetTargetVal('RZ5D.IsArmed')~=1
    % waiting until the system is armed
end
pause(1)
disp('System armed');

tank = DA.GetTankName;
%
% if wanting to do manual stims at the beginning
while DA.GetTargetVal('RZ5D.condition') == 0
    pause(0.1)
end

% once satisfied, run it

%% run it
% initialize values
iter = 1;
blockNum = 1;
trial = 1;
iterVec = [];
trialVec = [];
blockVec = [];
feltFirstVec = [];
confidenceVec = [];
delaysUsed = [];

%%
while blockNum <= numBlocks
    
    while trial <= length(delayRangeRepped)
        
        while ~DA.GetTargetVal('RZ5D.stimPressed')
            pause (0.1);
        end
        DA.SetTargetVal('RZ5D.trialNumber',iter);
        DA.SetTargetVal('RZ5D.delayReadIn',delaysTotal(iter));
        
        waitEnter = 1;
        while waitEnter
            
            feltFirst = input('Did they feel first? "s" or "t" ? \n','s');
            while isempty(feltFirst) | (feltFirst ~= 's' & feltFirst ~= 't')
                feltFirst = input('Did they feel first? "s" or "t" ? \n','s');
            end
            
            % write to TDT to make sure it's saved
            if feltFirst == 's'
                feltFirstNum = 0;
            elseif feltFirst =='t'
                feltFirstNum = 1;
            end
            
            confidence = input('How confident? 1-5, 1 is not, 5 is very ? \n');
            while isempty(confidence) | ~sum(confidence == [1:5])
                confidence = input('How confident? 1-5, 1 is not, 5 is very ? \n');
            end
            
            DA.SetTargetVal('RZ5D.feltFirstNum',feltFirstNum);
            DA.SetTargetVal('RZ5D.confidence',confidence);
            
            
            delaysUsed = [delaysUsed; delaysTotal(iter)];
            confidenceVec = [confidenceVec; confidence];
            feltFirstVec = [feltFirstVec; feltFirst];
            waitEnter = 0;
            
        end
        
        iterVec = [iterVec; iter];
        iter = iter + 1;
        trialVec = [trialVec; trial];
        
        trial = trial + 1;
    end
    % first check that the TDT system is still in record mode, if not
    % then end the experiment early and save the variables
    if DA.GetSysMode ~= 3
        disp('TDT Recording was ended early, ending and saving Matlab script now')
        Save_TOJ
        return
    end
    
    figure
    plot(confidenceVec(feltFirstVec=='s'),delaysUsed(feltFirstVec == 's'),'o');
    hold on
    plot(confidenceVec(feltFirstVec=='t'),delaysUsed(feltFirstVec == 't'),'o');
    legend('stim first','tactor first')
    ylabel('relative delay for stim to tactor')
    xlabel('confidence')
    
    trial = 1;
    blockVec = [blockVec; blockNum];
    blockNum = blockNum + 1;
end

%% When run is ended, close the connection

% Disarm stim:
DA.SetTargetVal('RZ5D.ArmSystem', 0);

% Read the loaded circuit's name so that we can save this
circuitLoaded = DA.GetDeviceRCO('RZ5D');

% Close ActiveX connection:
DA.CloseConnection
if DA.CheckServerConnection == 0
    disp('Server was disconnected');
end

%% Save
Save_TOJ

