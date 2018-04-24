%% TOJ_Matlab_interface
% DJC - 4-23-2018 - This is the MATLAB to TDT interface for the Temporal
% Order Judgement task with sensory stimulation ECoG patients. Briefly,
% after a baseline run of response timing is run, and the difference in
% perception for cortical stimulation relative to haptic stimulation is
% calculated, a distribution of induced differences between the two can be
% generated below, and used to test the perception of relatively closely
% timed DCS and haptic stimuli 

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

%% this is where the MATLAB/TDT communication primarily occurs

% iterate through blocks
while blockNum <= numBlocks
    
    % iterate through trials in each block 
    while trial <= length(delayRangeRepped)
        
        % wait until the stim button is pressed
        while ~DA.GetTargetVal('RZ5D.stimPressed')
            pause (0.1);
        end
        
        % set the trial number, and the delay for this trial in the TDT
        DA.SetTargetVal('RZ5D.trialNumber',iter);
        DA.SetTargetVal('RZ5D.delayReadIn',delaysTotal(iter));
        
        % now waiting for user input to report results of that trial
        waitEnter = 1;
        while waitEnter
             fprintf(['trial ' num2str(trial) '\n']);
            
             % which was felt first? a "s" or "t" must be input, otherwise
             % it keeps asking the user to input a valid entry
            feltFirst = input('Did they feel first? "s" or "t" ? \n','s');
            while isempty(feltFirst) | (feltFirst ~= 's' & feltFirst ~= 't')
                feltFirst = input('Did they feel first? "s" or "t" ? \n','s');
            end
            
            % convert to numeric so it can be written to TDT
            if feltFirst == 's'
                feltFirstNum = 0;
            elseif feltFirst =='t'
                feltFirstNum = 1;
            end
           
             % how confident was the patient? a value [1:5] must be input, otherwise
             % it keeps asking the user to input a valid entry
            confidence = input('How confident? 1-5, 1 is not, 5 is very ? \n');
            while isempty(confidence) | ~sum(confidence == [1:5])
                confidence = input('How confident? 1-5, 1 is not, 5 is very ? \n');
            end
            
            % write to TDT
            DA.SetTargetVal('RZ5D.feltFirstNum',feltFirstNum);
            DA.SetTargetVal('RZ5D.confidence',confidence);
            
            % build up vector for saving 
            delaysUsed = [delaysUsed; delaysTotal(iter)];
            confidenceVec = [confidenceVec; confidence];
            feltFirstVec = [feltFirstVec; feltFirst];
            waitEnter = 0;
            
        end
        % build up vector for saving 

        iterVec = [iterVec; iter];
        trialVec = [trialVec; trial];

        % iterate trial and iteration
        iter = iter + 1;
        trial = trial + 1;
    end
    
    % first check that the TDT system is still in record mode, if not
    % then end the experiment early and save the variables
    if DA.GetSysMode ~= 3
        disp('TDT Recording was ended early, ending and saving Matlab script now')
        Save_TOJ
        return
    end
    
    % after each block, plot it so we have an idea of what is going on
    figure
    plot(confidenceVec(feltFirstVec=='s'),delaysUsed(feltFirstVec == 's'),'o');
    hold on
    plot(confidenceVec(feltFirstVec=='t'),delaysUsed(feltFirstVec == 't'),'o');
    legend('stim first','tactor first')
    ylabel('relative delay for stim to tactor')
    xlabel('confidence')
    
    % reset the trials
    trial = 1;
    
    % build up vector of blocks
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

%% Save the values
Save_TOJ

