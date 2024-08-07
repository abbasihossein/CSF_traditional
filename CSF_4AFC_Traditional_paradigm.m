%--------------------
% Read Me 30.04.2024
%--------------------
%%before running the experiment add the path of the experiment floder to the matlab path.

%%Variables screen_info.wdth and screen_info.hght stads for the width and
%hight of the monitor. Please adjust them based on your monitor size!

%%When running the task, you have to define  trial numbers (nTrials) better
%%to keep this vale at 60.

%%Test consists of nine blocks, each block with one constant spatial
%%frequency ([0.5 1 2 4 8 12 18 24 28 32];).

%%There is a threshold for contrast reversal (Rev_Threshold = 7; line 31 and line 527)
%in the change in the contrast in which a block terminats and no more trial
%in that spatial frequency is presented. (this part is not activated and is not used)

%%Trial number hast to be an a factor of 4,the distance of the participants'
%eyes from the monitor (screen_info.Dist_from_screen), the distance between
%the center of the target and the center of display (stimuli_info.STIM_loc,in degree)
%and the size of the target (stimuli_info.STIM_size, from left to right edge in degree) should be sat carefully according to your setting.


sca;
close all;
clear;

do_the_practice = false;% set it to 'false' if you dont want to have practice
test = false;% set it to false for the real measurement
% Rev_Threshold = 7; % Reversal threshold for the contrast


stimuli_info.List_of_Freqs_cpd = [0.5 1 2 4 8 12 15 18 21 24];
stimuli_info.List_of_start_contrast = [0.03 0.015 0.008 0.008 0.008 0.04 0.1 0.2 0.21 0.23];


Screen('Preference', 'SkipSyncTests', 1);
HideCursor
% Setup PTB with some default values
PsychDefaultSetup(2);
screen_info.screenNumber = max(Screen('Screens'));


%The gerneral folder where all the code and date are saved
CSF_Traditional_EXP = 'D:\Hossein Abbasi\CSF - TraditionalVersion';



%Experiment Codes path
ExperimentCodes_path = [CSF_Traditional_EXP, '\CSF_traditional'];
addpath(ExperimentCodes_path);
cd(ExperimentCodes_path)

%Stroy Objects
StroyObjects_path = [ExperimentCodes_path, '\objects'];
addpath(StroyObjects_path)

%Fake Gabors for practice
FAKEstim_path = [StroyObjects_path, '\Fake Gabors'];
addpath(StroyObjects_path)

%Where to save the data
% Check if the folder for saving data exists
if exist(fullfile(CSF_Traditional_EXP, 'SavedData'), 'dir') ~= 7
    % If the folder does not exist, create it
    SaveDirectory = mkdir(CSF_Traditional_EXP, 'SavedData');
    disp(['Folder "', 'SavedData', '" created in directory "', CSF_Traditional_EXP, '"']);
else
    SaveDirectory = [CSF_Traditional_EXP, '\SavedData'];
    disp(['Folder "', 'SavedData', '" already exists in directory "', CSF_Traditional_EXP, '"']);
end

cd(fullfile(CSF_Traditional_EXP, 'SavedData'));
% Display the current directory to verify the change
disp(['Current directory: ', pwd]);
%--------------------
% Ask for input
%--------------------
if ~test
    nTrials = 1;
    Pass = mod(nTrials,4) == 0;
    while ~Pass
        disp('Attention: The trial number should be a factor of 4')
        definput = {'Hossein Abbasi','e.g. 11','100','80','3','5'};
        fieldsize = [1 45; 1 45; 1 45; 1 45; 1 45; 1 45];
        Get_Inp.answer = inputdlg({'Experimenter:','Participant ID:','Trial numbers','Distance from screen (cm)','Target size (°)','Eccentricity (°)'},'Input',fieldsize,definput);
        Get_Inp.experimenter = Get_Inp.answer{1};
        Get_Inp.VP_id = str2double(Get_Inp.answer{2});
        nTrials = str2double(Get_Inp.answer{3});
        Pass = mod(nTrials,4) == 0;
        screen_info.Dist_from_screen = str2double(Get_Inp.answer{4}); %distance between the participants eyes and the screen
        stimuli_info.STIM_size = str2double(Get_Inp.answer{5}); %the size of the target in degree
        stimuli_info.STIM_loc = str2double(Get_Inp.answer{6}); %the distance between the center of the target and the center of the display
    end
    
    % Stimulus duration
    timelist = {'100' '150' '200' '500' '800'};
    Get_Inp.stimdur = listdlg('PromptString','Select a stimulus duration (miliseconds):',...
        'SelectionMode','single',...
        'ListString',timelist,'InitialValue',2);
    stimuli_info.stimDuration_ms = str2double(timelist(Get_Inp.stimdur));
    
    if isempty(Get_Inp.stimdur)
        stimuli_info.stimDuration_ms = 150; % in ms
    end
    %--------------------
    % Screen information
    %--------------------
    
    % Screen Dimensions in cm % adjust it depending on the screen size
    definput = {'53','29.5'};
    fieldsize = [1 45; 1 45];
    Get_Inp.Monitor = inputdlg({'Screen width (cm):','Screen hight (cm):'},'Input',fieldsize,definput);
    
    if isempty (Get_Inp.Monitor)||isempty (Get_Inp.Monitor{1})|| isempty (Get_Inp.Monitor{2})
        screen_info.wdth = 53;%in cm
        screen_info.hght = 29.5;%in cm
    else
        screen_info.wdth = str2double(Get_Inp.Monitor{1});
        screen_info.hght = str2double(Get_Inp.Monitor{2});
    end
else
    Get_Inp.experimenter = 'Hossein';
    Get_Inp.VP_id = 100;
    nTrials = 8; % trial numbers
    screen_info.Dist_from_screen = 80; %distance between the participants eyes and the screen in cm
    stimuli_info.STIM_size = 3; %the size of the target in degree
    stimuli_info.STIM_loc = 5; %the distance between the center of the target and the center of the display
    screen_info.wdth = 53;%in cm
    screen_info.hght = 29.5;%in cm
    stimuli_info.stimDuration_ms = 150; %in ms
end

% Define black, white and grey
screen_info.white = WhiteIndex(screen_info.screenNumber);
screen_info.black = BlackIndex(screen_info.screenNumber);
screen_info.grey = screen_info.white / 2;

% Open the screen
[screen_info.window, screen_info.windowRect] = PsychImaging('OpenWindow', screen_info.screenNumber, screen_info.grey);
[screen_info.center(1), screen_info.center(2)] = RectCenter(screen_info.windowRect);

% Query the frame duration
screen_info.ifi = Screen('GetFlipInterval', screen_info.window);
screen_info.frequency = round(1/screen_info.ifi);

%
stimuli_info.stimDuration_Frames = round((stimuli_info.stimDuration_ms/1000) / screen_info.ifi);
%--------------------
% Gabor information
%--------------------
screen_info.screenXpixels = screen_info.windowRect(3);
screen_info.screenYpixels = screen_info.windowRect(4);
screen_info.xCenter = screen_info.screenXpixels/2;
screen_info.yCenter = screen_info.screenYpixels/2;

% define the Central position of the Gabor on the left and right of the fixation point
stimuli_info.Loc_Nr = 4;% it is 4AFCT
stimuli_info.FIXpos = [0 0];
stimuli_info.TARGpos = [[0 stimuli_info.STIM_loc 0 -stimuli_info.STIM_loc ]',  [stimuli_info.STIM_loc  0 -stimuli_info.STIM_loc 0]'];
stimuli_info.FIXpos_pix = deg2pix(stimuli_info.FIXpos(:,1), stimuli_info.FIXpos(:,2), screen_info);
stimuli_info.TRGpos_pix = deg2pix(stimuli_info.TARGpos(:,1), stimuli_info.TARGpos(:,2), screen_info);

% calculate the half-dimention of the stimulus in pixel(from left/righ edge to the center)
stimuli_info.gaborDimPix = deg2pix_s(stimuli_info.STIM_size,stimuli_info.STIM_loc, screen_info);


% define the borders of the Gabor
% here we set the possible stimulus positions. order in stimuli_info.All_Stim_positions: [up; right; down; left]
for i = 1:stimuli_info.Loc_Nr
    stimuli_info.All_Stim_positions(i,:)=[stimuli_info.TRGpos_pix(i)-stimuli_info.gaborDimPix, stimuli_info.TRGpos_pix(i+stimuli_info.Loc_Nr)-stimuli_info.gaborDimPix, ...
        stimuli_info.TRGpos_pix(i)+stimuli_info.gaborDimPix, stimuli_info.TRGpos_pix(i+stimuli_info.Loc_Nr)+stimuli_info.gaborDimPix];
end

% Sigma of Gaussian (SD of the Gaussian)
stimuli_info.sigma = stimuli_info.gaborDimPix / 7;

% Obvious Parameters
stimuli_info.orientation = 0;
stimuli_info.aspectRatio = 1.0;
stimuli_info.phase = 0;

stimuli_info.pixels_per_degree = oneDeg2Pix(1,screen_info); % how many pixel in one deg

% Build a procedural gabor texture (Note: to get a "standard" Gabor patch
% we set a grey background offset, disable normalisation, and set a
% pre-contrast multiplier of 0.5).

%%%%explanation from the source: If you set the ‘disableNorm’ parameter to 1 to disable the builtin normf
%normalization and then specify contrastPreMultiplicator = 0.5 then the
%per gabor ‘contrast’ value will correspond to what practitioners of the
%field usually understand to be the contrast value of a gabor.
stimuli_info.backgroundOffset = [0.5 0.5 0.5 0.0];
stimuli_info.disableNorm = 1;
stimuli_info.preContrastMultiplier = 0.5;
stimuli_info.gabortex = CreateProceduralGabor(screen_info.window, stimuli_info.gaborDimPix, stimuli_info.gaborDimPix, [],...
    stimuli_info.backgroundOffset, stimuli_info.disableNorm, stimuli_info.preContrastMultiplier);

%------------------------------------------
%    Other stimuli info, e.g. fixation, frames, objects etc.
%------------------------------------------
% fixation
stimuli_info.FixationColor = [0.2 0.4 0.9];
stimuli_info.baseRect_fixation = [0 0 50 50];
stimuli_info.centeredFixation = CenterRectOnPointd(stimuli_info.baseRect_fixation, screen_info.xCenter, screen_info.yCenter);
stimuli_info.DiamFixation = max(stimuli_info.baseRect_fixation);

% frames
stimuli_info.frameColor = screen_info.black;
stimuli_info.borderThickness = 5;

% response selection
stimuli_info.baseRect_Resp = (stimuli_info.gaborDimPix-stimuli_info.borderThickness)*2;

% here we set the possible "response" positions. order in stimuli_info.All_Resp_positions: [up; right; down; left]
for i = 1:stimuli_info.Loc_Nr
    stimuli_info.All_Resp_positions(i,:)=[stimuli_info.TRGpos_pix(i)-stimuli_info.baseRect_Resp/2, stimuli_info.TRGpos_pix(i+stimuli_info.Loc_Nr)-stimuli_info.baseRect_Resp/2, ...
        stimuli_info.TRGpos_pix(i)+stimuli_info.baseRect_Resp/2, stimuli_info.TRGpos_pix(i+stimuli_info.Loc_Nr)+stimuli_info.baseRect_Resp/2];
end

% cursor in Response selection
stimuli_info.CurserColor = [0.7 0.1 0.5];
stimuli_info.CurserSize = 30;

% Sync us and get a time stamp
screen_info.vbl = Screen('Flip', screen_info.window);
screen_info.waitframes = 1;
% Maximum priority level
topPriorityLevel = MaxPriority(screen_info.window);
Priority(topPriorityLevel);


%Add objects
cd(StroyObjects_path)% change the address to where these images are saved

stimuli_info.HouseFrame = imread('house_frame_GrayBack.png');
stimuli_info.HouseFrame_Texture = Screen('MakeTexture', screen_info.window, stimuli_info.HouseFrame);

stimuli_info.Zebra = imread('Zebra1_withBGND.png');
stimuli_info.Zebra_Texture = Screen('MakeTexture', screen_info.window, stimuli_info.Zebra);

stimuli_info.Happy_Zebra = imread('Happy_Zebra.png');
stimuli_info.Happy_Zebra_Texture = Screen('MakeTexture', screen_info.window, stimuli_info.Happy_Zebra);

stimuli_info.Sad_Zebra = imread('Sad_Zebra.png');
stimuli_info.Sad_Zebra_Texture = Screen('MakeTexture', screen_info.window, stimuli_info.Sad_Zebra);

stimuli_info.feedback_Pos = [screen_info.xCenter-stimuli_info.baseRect_Resp, screen_info.yCenter-stimuli_info.baseRect_Resp, ...
    screen_info.xCenter+stimuli_info.baseRect_Resp, screen_info.yCenter+stimuli_info.baseRect_Resp];
%------------------------------------------
%    Practice
%------------------------------------------
if do_the_practice
    done = false;
    while ~done
        [done,New_vbl] = Practice(screen_info,stimuli_info,FAKEstim_path);
    end
    screen_info.vbl = New_vbl;
end


%%

HouseFrame = imread('house_frame_GrayBack.png');
HouseFrame_Texture = Screen('MakeTexture', screen_info.window, HouseFrame);
Houserect = [screen_info.xCenter-600, screen_info.yCenter-630, screen_info.xCenter+600, screen_info.yCenter+480];

Zebra = imread('Zebra1_withBGND.png');
Zebra_Texture = Screen('MakeTexture', screen_info.window, Zebra);


stimuli_info.List_of_Freqs_PIxperDEG = stimuli_info.List_of_Freqs_cpd ./ stimuli_info.pixels_per_degree;%in cycles per pixel


for BLOCK = 1:length(stimuli_info.List_of_Freqs_cpd)
    ThisRevs = zeros(1,100);
    %------------------------------------------
    %    target and no target locations
    %------------------------------------------
    POSs = [1;2;3;4];
    idx = zeros(1, nTrials);
    idx(1:nTrials/4)=POSs(1); idx(nTrials/4+1:nTrials/2)=POSs(2); idx(nTrials/2+1:(3*nTrials)/4)=POSs(3); idx((3*nTrials)/4+1:end)=POSs(4);
    TargLoc_idx = idx(randperm(length(idx)));
    % Ensure not more than three consecutive repetitions
    while any(conv(double(diff(TargLoc_idx) == 0), ones(1,3),'valid') >= 3)
        % Reshuffle the vector until the condition is met
        TargLoc_idx = TargLoc_idx(randperm(length(TargLoc_idx)));
    end
    
    % get the position for the locations without target
    noTargLoc_idx = zeros(stimuli_info.Loc_Nr-1, length(TargLoc_idx));
    for i = 1:length(TargLoc_idx)
        noTargLoc_idx(:,i) = unique(TargLoc_idx(TargLoc_idx ~= TargLoc_idx(i)))';
    end
    
    Target_Locations = []; noTarget_Locations = {};
    for trl = 1:nTrials
        Target_Locations(trl,:) = stimuli_info.All_Stim_positions(TargLoc_idx(trl),:);
        noTarget_Locations{trl} = stimuli_info.All_Stim_positions(noTargLoc_idx(:,trl),:);
        Locations{trl} = [Target_Locations(trl,:);noTarget_Locations{1,trl}];
    end
    
    %%
    stimuli_info.sz = [1 nTrials];
    stimuli_info.ISI = unifrnd(0.800, 1.200,stimuli_info.sz);%% ISI between 600 and 900 ms.
    stimuli_info.ISI_ms = stimuli_info.ISI*1000;
    stimuli_info.isiTimeFrames = round(stimuli_info.ISI / screen_info.ifi);
    
    
    This_Freq = stimuli_info.List_of_Freqs_PIxperDEG(BLOCK);
    
    for trl = 1:nTrials
        
        
        if trl == 1
            This_Contrast = stimuli_info.List_of_start_contrast(BLOCK);
        end
        
        fprintf(' trial:%1.0f contrast:%1.4f  spatialFreq:%1.2f \n',trl,This_Contrast,stimuli_info.List_of_Freqs_cpd(BLOCK))
        %------------------------------------------
        %    Promote each trial
        %------------------------------------------
        SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
        if trl ==1
            BBB = num2str(BLOCK); AllBBB = num2str(length(stimuli_info.List_of_Freqs_cpd));
            MSG = ['Block ' BBB '/' AllBBB];
            for frm = 1:20
                [mx, my, ~] = GetMouse(screen_info.screenNumber);
                Screen('TextSize', screen_info.window, 50);
                DrawFormattedText(screen_info.window, MSG, 'center', screen_info.yCenter-150, screen_info.black);
                DrawFormattedText(screen_info.window, 'Click to start!', 'center', 'center', screen_info.black);
                Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            end
            
            clickOccurred = false;
            while ~clickOccurred
                
                [mx, my, buttons] = GetMouse(screen_info.screenNumber);
                Screen('TextSize', screen_info.window, 50);
                DrawFormattedText(screen_info.window, MSG, 'center', screen_info.yCenter-150, screen_info.black);
                DrawFormattedText(screen_info.window, 'Click to start!', 'center', 'center', screen_info.black);
                Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
                
                
                %                 % Capture the screen content
                %                 startt = Screen('GetImage', screen_info.window);
                %                 % Save the image
                %                 imwrite(startt, 'startt.png');
                
                
                if sum(buttons) > 0
                    clickOccurred = true;
                end
            end
        end
        
        %         for frm = 1:screen_info.frequency*(0.5)
        %             Screen('FillOval', screen_info.window, stimuli_info.FixationColor, stimuli_info.centeredFixation, stimuli_info.DiamFixation);
        %             screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
        %         end
        
        %------------------------------------------
        %    Draw placeholders pre-stimulus
        %------------------------------------------
        
        for frm = 1:stimuli_info.isiTimeFrames(trl)
            Screen('DrawTexture', screen_info.window, HouseFrame_Texture, [], Houserect);
            Screen('FillOval', screen_info.window, stimuli_info.FixationColor, stimuli_info.centeredFixation, stimuli_info.DiamFixation);
            for i = 1:stimuli_info.Loc_Nr
                Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Stim_positions(i,:), stimuli_info.borderThickness);
            end
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            
            %             % Capture the screen content
            %                 placeH = Screen('GetImage', screen_info.window);
            %                 % Save the image
            %                 imwrite(placeH, 'placeH.png');
            
        end
        
        SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
        
        %------------------------------------------
        %    Draw stimulus in one of the placehoders that is the target position
        %------------------------------------------
        % correct blending for Gabors
        
        Screen('BlendFunction', screen_info.window, 'GL_ONE', 'GL_ZERO');
        stimuli_info.propertiesMat = [stimuli_info.phase, This_Freq, stimuli_info.sigma, This_Contrast, stimuli_info.aspectRatio, 0, 0, 0];
        
        %         sec1 = GetSecs;
        for frm = 1:stimuli_info.stimDuration_Frames
            Screen('DrawTexture', screen_info.window, HouseFrame_Texture, [], Houserect);
            Screen('FillOval', screen_info.window, stimuli_info.FixationColor, stimuli_info.centeredFixation, stimuli_info.DiamFixation);
            Screen('DrawTextures', screen_info.window, stimuli_info.gabortex, [], Target_Locations(trl,:), stimuli_info.orientation, [], [], [], [],...
                kPsychDontDoRotation, stimuli_info.propertiesMat');
            
            for i = 1:stimuli_info.Loc_Nr
                Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Stim_positions(i,:), stimuli_info.borderThickness);
            end
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            
            %             % Capture the screen content
            %                 stimul = Screen('GetImage', screen_info.window);
            %                 % Save the image
            %                 imwrite(stimul, 'stimul.png');
            
        end
        %         sec2 = GetSecs;
        %         StimPre_tim {BLOCK}(trl) = sec2-sec1;
        
        
        %------------------------------------------
        %    Draw placeholders post-stimulus
        %------------------------------------------
        
        for frm = 1:screen_info.frequency*(0.3)
            Screen('DrawTexture', screen_info.window, HouseFrame_Texture, [], Houserect);
            Screen('FillOval', screen_info.window, stimuli_info.FixationColor, stimuli_info.centeredFixation, stimuli_info.DiamFixation);
            for i = 1:stimuli_info.Loc_Nr
                Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Stim_positions(i,:), stimuli_info.borderThickness);
            end
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
        end
        
        
        
        %------------------------------------------
        %    Show the response screen
        %------------------------------------------
        SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
        clickOccurred = false;
        while ~clickOccurred
            
            [mx, my, buttons] = GetMouse(screen_info.screenNumber);
            Screen('DrawTexture', screen_info.window, HouseFrame_Texture, [], Houserect);
            Screen('FillOval', screen_info.window, stimuli_info.FixationColor, stimuli_info.centeredFixation, stimuli_info.DiamFixation);
            
            
            for i = 1:stimuli_info.Loc_Nr
                Screen('DrawTexture', screen_info.window, Zebra_Texture, [], stimuli_info.All_Resp_positions(i,:));
            end
            for i = 1:stimuli_info.Loc_Nr
                Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Stim_positions(i,:), stimuli_info.borderThickness);
            end
            Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
            
            Screen('TextSize', screen_info.window, 60);
            DrawFormattedText(screen_info.window, '?', 'center', 'center', screen_info.black);
            
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            
            %             % Capture the screen content
            %                 RepsS = Screen('GetImage', screen_info.window);
            %                 % Save the image
            %                 imwrite(RepsS, 'RepsS.png');
            
            
            for st = 1:4
                insides(st) = IsInRect(mx, my,Locations{trl}(st,:));
            end
            
            index = find(insides == 1);% find which stimulus was selected
            if isempty(index)
                continue;
                
            elseif index == 1 && sum(buttons) ==1% if the target is selected
                clickOccurred = true;
                ThisACC = 1;
                for frm = 1:round(screen_info.frequency*(2/3))
                    Screen('DrawTexture', screen_info.window, stimuli_info.HouseFrame_Texture, [], Houserect);
                    for i = 1:stimuli_info.Loc_Nr
                        Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Stim_positions(i,:), stimuli_info.borderThickness);
                    end
                    Screen('DrawTexture', screen_info.window, stimuli_info.Happy_Zebra_Texture, [], stimuli_info.feedback_Pos);
                    screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
                end
                
            elseif (index > 1 && index < 5)&& sum(buttons) ==1 % if a distractor is selected
                clickOccurred = true;
                ThisACC = 0;
                for frm = 1:round(screen_info.frequency*(2/3))
                    Screen('DrawTexture', screen_info.window, stimuli_info.HouseFrame_Texture, [], Houserect);
                    for i = 1:stimuli_info.Loc_Nr
                        Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Stim_positions(i,:), stimuli_info.borderThickness);
                    end
                    Screen('DrawTexture', screen_info.window, stimuli_info.Sad_Zebra_Texture, [], stimuli_info.feedback_Pos);
                    screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
                end
            end
        end
        
        SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
        
        
        Behavioral_response.contrast{BLOCK}(trl,1) = This_Contrast;
        Behavioral_response.accuracy{BLOCK}(trl,1) = ThisACC;
        
        fprintf(' trial:%1.0f accuracy:%1.0f \n',trl,ThisACC)
        
        
        if Behavioral_response.accuracy{BLOCK}(trl,1) == 0
            This_Contrast = Behavioral_response.contrast{BLOCK}(trl,1)+0.1*Behavioral_response.contrast{BLOCK}(trl,1);
            
            
            
        elseif Behavioral_response.accuracy{BLOCK}(trl,1) == 1 && size(Behavioral_response.accuracy{BLOCK},1) > 2
            if Behavioral_response.accuracy{BLOCK}(trl,1)==1 && Behavioral_response.accuracy{BLOCK}(trl-1,1)==1 && Behavioral_response.accuracy{BLOCK}(trl-2,1)==1 && (Behavioral_response.contrast{BLOCK}(trl,1) == Behavioral_response.contrast{BLOCK}(trl-1,1) && Behavioral_response.contrast{BLOCK}(trl,1) == Behavioral_response.contrast{BLOCK}(trl-2,1))
                This_Contrast = This_Contrast-0.1*This_Contrast;
                
                if This_Contrast < (128-127)/(128+127) || This_Contrast == (128-127)/(128+127)
                    This_Contrast = (128-127)/(128+127);
                end
            end
        end
        
        if Behavioral_response.accuracy{BLOCK}(trl,1)>1% to keep the contrast less than 1
            Behavioral_response.accuracy{BLOCK}(trl,1) =1;
        end
        
        
        %------------------------------------------
        %    A break at the middle of the experiment
        %------------------------------------------
        if trl  == nTrials/2
            for frm = 1:20
                [~, ~, buttons] = GetMouse(screen_info.screenNumber);
                Screen('TextSize', screen_info.window, 50);
                DrawFormattedText(screen_info.window, 'Take a break! \n\n Click to continue when ready!', 'center','center', screen_info.black);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            end
            
            clickOccurred = false;
            while ~clickOccurred
                [mx, my, buttons] = GetMouse(screen_info.screenNumber);
                Screen('TextSize', screen_info.window, 50);
                DrawFormattedText(screen_info.window, 'Take a break! \n\n Click to continue when ready!', 'center','center', screen_info.black);
                Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
                if sum(buttons) > 0
                    clickOccurred = true;
                end
            end
        end
        
        %------------------------------------------
        %    Screen for finishing the experiment
        %------------------------------------------
        SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
        if trl == nTrials && BLOCK == length(stimuli_info.List_of_Freqs_cpd)
            for frm = 1:20
                [~, ~, buttons] = GetMouse(screen_info.screenNumber);
                Screen('TextSize', screen_info.window, 50);
                DrawFormattedText(screen_info.window, 'Experiment is done! \n\n Click and wait for the experimenter!', 'center','center', screen_info.black);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            end
            
            clickOccurred = false;
            while ~clickOccurred
                [mx, my, buttons] = GetMouse(screen_info.screenNumber);
                Screen('TextSize', screen_info.window, 50);
                DrawFormattedText(screen_info.window, 'Experiment is done! \n\n Click and wait for the experimenter!', 'center','center', screen_info.black);
                Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
                if sum(buttons) > 0
                    clickOccurred = true;
                end
            end
            
        elseif (trl == nTrials && BLOCK ~= length(stimuli_info.List_of_Freqs_cpd))
            
            for frm = 1:20
                [~, ~, buttons] = GetMouse(screen_info.screenNumber);
                Screen('TextSize', screen_info.window, 50);
                DrawFormattedText(screen_info.window, 'Take a break! \n\n Click to start when ready!', 'center','center', screen_info.black);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            end
            
            clickOccurred = false;
            while ~clickOccurred
                [mx, my, buttons] = GetMouse(screen_info.screenNumber);
                Screen('TextSize', screen_info.window, 50);
                DrawFormattedText(screen_info.window, 'Take a break! \n\n Click to start when ready!', 'center','center', screen_info.black);
                Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
                if sum(buttons) > 0
                    clickOccurred = true;
                end
            end
        end
        
        uniqueIndices = [true; diff(Behavioral_response.contrast{BLOCK}) ~= 0];
        UniqueContrast = Behavioral_response.contrast{BLOCK}(uniqueIndices);
        
        J = 1;
        for i = 2:length(UniqueContrast)-1
            if UniqueContrast(i)<UniqueContrast(i-1) && UniqueContrast(i) < UniqueContrast(i+1)
                ThisRevs(J) = UniqueContrast(i);
                J = J+1;
            elseif UniqueContrast(i)>UniqueContrast(i-1) && UniqueContrast(i) > UniqueContrast(i+1)
                ThisRevs(J) = UniqueContrast(i);
                J = J+1;
            end
        end
        
        RversedContrasts{BLOCK} = ThisRevs(ThisRevs ~= 0);%% remove unnecessary zeros
        %
        %         if exist('RversedContrasts', 'var') && length (RversedContrasts{BLOCK}) > Rev_Threshold %% here a Block ends in the number of reversals meets the threshold
        %             for frm = 1:20
        %                 [~, ~, buttons] = GetMouse(screen_info.screenNumber);
        %                 Screen('TextSize', screen_info.window, 50);
        %                 DrawFormattedText(screen_info.window, 'Take a break! \n\n Click to start when you are ready!', 'center','center', screen_info.black);
        %                 screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
        %             end
        %
        %             clickOccurred = false;
        %             while ~clickOccurred
        %                 [mx, my, buttons] = GetMouse(screen_info.screenNumber);
        %                 Screen('TextSize', screen_info.window, 50);
        %                 DrawFormattedText(screen_info.window, 'Take a break! \n\n Click to start when you are ready!', 'center','center', screen_info.black);
        %                 Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
        %                 screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
        %                 if sum(buttons) > 0
        %                     clickOccurred = true;
        %                 end
        %             end
        %             break
        %         end
    end
    
    
    
    Behavioral_response.Revs{BLOCK} = ThisRevs(ThisRevs ~= 0);%% remove unnecessary zeros
    
    REVexist = ~isempty(Behavioral_response.Revs{BLOCK});
    if REVexist == 1 && length(Behavioral_response.Revs{BLOCK})>2
        Switches.USED{BLOCK} = Behavioral_response.Revs{BLOCK}(3:end);
    elseif REVexist == 1 && length(Behavioral_response.Revs{BLOCK})<3
        Switches.USED{BLOCK} = Behavioral_response.Revs{BLOCK};
    elseif REVexist == 0
        Switches.USED{BLOCK} = Behavioral_response.contrast{BLOCK}(end,1);
    end
    Behavioral_response.Contrast_Thresholds(BLOCK) = mean(Switches.USED{BLOCK});
end
sca;
%clear unnecessary variables
clearvars AllBBB BBB acc mx my index frm i insides POSs st This_Contrast This_Freq ThisACC trl buttons clickOccurred correct definput done fieldsize frm HouseFrame HouseFrame_Texture Houserect i idx inside_noTarg1 inside_noTarg2 inside_noTarg3
clearvars inside_Targ lcolor mx my New_vbl nextContrastToTest nextFreqToTest plotPriors POSs ttext xticks2 xticks3 yticks2 yticks3 Zebra Zebra_Texture
%save data
cd(SaveDirectory)
filename = sprintf('Data_VP%d', Get_Inp.VP_id);
save(filename)