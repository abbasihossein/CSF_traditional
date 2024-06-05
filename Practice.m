function [done,New_vbl] = Practice(screen_info,stimuli_info,Practice_info)
%------------------------------------------
%    target and no target locations in practice phase %%
%------------------------------------------
Practice_info.Practice_trl_Nr = 20;
% the first six values are set to 1, because the stimulus in the first six practice trials are some saved images and not real Gabors
Practice_info.spatial_freqs_cpd = [1 1 1 1 1 1 4 36 8 2 15 6 26 10 20 24 30 22 1 12];
Practice_info.contrast = [1 1 1 1 1 1 0.3 0.7 1 0.02 0.5 0.05 0.1 0.9 0.4 0.55 0.75 0.00 0.035 1];
Practice_info.freq_PIxperDEG = Practice_info.spatial_freqs_cpd ./ stimuli_info.pixels_per_degree;%in cycles per pixel
POSs = [1;2;3;4];
idx = zeros(1, Practice_info.Practice_trl_Nr);
idx(1:Practice_info.Practice_trl_Nr/4)=POSs(1); idx(Practice_info.Practice_trl_Nr/4+1:Practice_info.Practice_trl_Nr/2)=POSs(2); idx(Practice_info.Practice_trl_Nr/2+1:(3*Practice_info.Practice_trl_Nr)/4)=POSs(3); idx((3*Practice_info.Practice_trl_Nr)/4+1:end)=POSs(4);
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
for trl = 1:Practice_info.Practice_trl_Nr
    Target_Locations(trl,:) = stimuli_info.All_Stim_positions(TargLoc_idx(trl),:);
    noTarget_Locations{trl} = stimuli_info.All_Stim_positions(noTargLoc_idx(:,trl),:);
end

Practice_info.Fake_Gabors_list = dir(fullfile(Practice_info.stim_path, '*.png'));
for i = 1:numel(Practice_info.Fake_Gabors_list)
    Practice_info.Fake_Gabors{i} = imread(fullfile(Practice_info.stim_path, Practice_info.Fake_Gabors_list(i).name));
    disp(['Image ', num2str(i), ': ', Practice_info.Fake_Gabors_list(i).name]);
end
%%
% SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
for trl = 1:Practice_info.Practice_trl_Nr
    if trl ==1 %% to initiate a short practice phase
        SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
        for frm = 1:20
            [mx, my, ~] = GetMouse(screen_info.screenNumber);
            Screen('TextSize', screen_info.window, 50);
            DrawFormattedText(screen_info.window, 'This is a practice phase.\n\n Click to start!', 'center', 'center', screen_info.black);
            Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
        end
        
        clickOccurred = false;
        while ~clickOccurred
            
            [mx, my, buttons] = GetMouse(screen_info.screenNumber);
            Screen('TextSize', screen_info.window, 50);
            DrawFormattedText(screen_info.window, 'This is a practice phase.\n\n Click to start!', 'center', 'center', screen_info.black);
            Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            
            if sum(buttons) > 0
                clickOccurred = true;
            end
        end
    end
    
    for frm = 1:screen_info.frequency
        Screen('FillOval', screen_info.window, stimuli_info.FixationColor, stimuli_info.centeredFixation, stimuli_info.DiamFixation);
        screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
    end
    %------------------------------------------
    %    Draw placeholders
    %------------------------------------------
    Houserect = [screen_info.xCenter-600, screen_info.yCenter-630, screen_info.xCenter+600, screen_info.yCenter+480];
    for frm = 1:round(screen_info.frequency*(2/3)) % stimulus duration for 500ms
        Screen('DrawTexture', screen_info.window, stimuli_info.HouseFrame_Texture, [], Houserect);
        Screen('FillOval', screen_info.window, stimuli_info.FixationColor, stimuli_info.centeredFixation, stimuli_info.DiamFixation);
        for i = 1:stimuli_info.Loc_Nr
            Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Stim_positions(i,:), stimuli_info.borderThickness);
        end
        screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
    end
    
    %------------------------------------------
    %    use the fake stimuli
    %------------------------------------------
    
    if trl<7 % for the first 6practive trials, the stimulus is the zebra belly.
        Practice_info.Fake_Gabors_Texture = Screen('MakeTexture', screen_info.window, Practice_info.Fake_Gabors{trl});
        for frm = 1:screen_info.frequency/2 % stimulus duration for 500ms
            Screen('DrawTexture', screen_info.window, stimuli_info.HouseFrame_Texture, [], Houserect);
            Screen('FillOval', screen_info.window, stimuli_info.FixationColor, stimuli_info.centeredFixation, stimuli_info.DiamFixation);
            Screen('DrawTexture', screen_info.window, Practice_info.Fake_Gabors_Texture, [], Target_Locations(trl,:));
            for i = 1:stimuli_info.Loc_Nr
                Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Stim_positions(i,:), stimuli_info.borderThickness);
            end
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
        end

    else
        Screen('BlendFunction', screen_info.window, 'GL_ONE', 'GL_ZERO');
        stimuli_info.propertiesMat = [stimuli_info.phase, Practice_info.freq_PIxperDEG(trl), stimuli_info.sigma, Practice_info.contrast(trl), stimuli_info.aspectRatio, 0, 0, 0];
        
        for frm = 1:screen_info.frequency/2 % stimulus duration for 500ms
            Screen('DrawTexture', screen_info.window, stimuli_info.HouseFrame_Texture, [], Houserect);
            Screen('FillOval', screen_info.window, stimuli_info.FixationColor, stimuli_info.centeredFixation, stimuli_info.DiamFixation);
            Screen('DrawTextures', screen_info.window, stimuli_info.gabortex, [], Target_Locations(trl,:), stimuli_info.orientation, [], [], [], [],...
                kPsychDontDoRotation, stimuli_info.propertiesMat');
            for i = 1:stimuli_info.Loc_Nr
                Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Stim_positions(i,:), stimuli_info.borderThickness);
            end
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            
        end
    end
    
    %------------------------------------------
    %    Show the response screen
    %------------------------------------------
    SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
    clickOccurred = false;
    while ~clickOccurred
        
        Screen('DrawTexture', screen_info.window, stimuli_info.HouseFrame_Texture, [], Houserect);
        [mx, my, buttons] = GetMouse(screen_info.screenNumber);
        inside_Targ = IsInRect(mx, my, Target_Locations(trl,:));
        inside_noTarg1 = IsInRect(mx, my, noTarget_Locations{trl}(1,:));
        inside_noTarg2 = IsInRect(mx, my, noTarget_Locations{trl}(2,:));
        inside_noTarg3 = IsInRect(mx, my, noTarget_Locations{trl}(3,:));
        Screen('TextSize', screen_info.window, 70);
        DrawFormattedText(screen_info.window, '?', 'center', 'center', screen_info.black);
        
        for i = 1:stimuli_info.Loc_Nr
            Screen('DrawTexture', screen_info.window, stimuli_info.Zebra_Texture, [], stimuli_info.All_Resp_positions(i,:));
        end
        for i = 1:stimuli_info.Loc_Nr
            Screen('FrameRect', screen_info.window, stimuli_info.frameColor,stimuli_info.All_Resp_positions(i,:), stimuli_info.borderThickness);
        end
        Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
        screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
        
        if inside_Targ == 1 && sum(buttons) > 0
            clickOccurred = true;
            acc = 1;
            
            for frm = 1:screen_info.frequency
                Screen('DrawTexture', screen_info.window, stimuli_info.HouseFrame_Texture, [], Houserect);
                Screen('DrawTexture', screen_info.window, stimuli_info.Happy_Zebra_Texture, [], stimuli_info.feedback_Pos);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            end
            
        elseif  sum(buttons) > 0 && (inside_noTarg1 == 1 || inside_noTarg2 == 1 || inside_noTarg3 == 1)
            clickOccurred = true;
            acc = 0;
            
            for frm = 1:screen_info.frequency
                Screen('DrawTexture', screen_info.window, stimuli_info.HouseFrame_Texture, [], Houserect);
                Screen('DrawTexture', screen_info.window, stimuli_info.Sad_Zebra_Texture, [], stimuli_info.feedback_Pos);
                screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            end
        end
    end
    tested_stimuli.Practice_accuracy(1,trl) =  acc;
end
Practice_ACC = mean(tested_stimuli.Practice_accuracy)*100;
if Practice_ACC>50
    done = true;
    SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
    clickOccurred = false;
        while ~clickOccurred
            
            [mx, my, buttons] = GetMouse(screen_info.screenNumber);
            
            Screen('TextSize', screen_info.window, 50);
            DrawFormattedText(screen_info.window, 'It seems you have learned the task.\n\n Click to start the main task!', 'center', 'center', screen_info.black);
            Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            if sum(buttons) > 0
                clickOccurred = true;
            end
        end
else
    done = false;
    SetMouse(screen_info.xCenter, screen_info.yCenter, screen_info.window);
    clickOccurred = false;
        while ~clickOccurred
            
            [mx, my, buttons] = GetMouse(screen_info.screenNumber);
            Screen('TextSize', screen_info.window, 50);
            DrawFormattedText(screen_info.window, 'It seems you need more practice.\n\n Click to repeat the practice phase!', 'center', 'center', screen_info.black);
            Screen('FillOval', screen_info.window, stimuli_info.CurserColor, [mx-stimuli_info.CurserSize/2, my-stimuli_info.CurserSize/2, mx+stimuli_info.CurserSize/2, my+stimuli_info.CurserSize/2], stimuli_info.CurserSize);
            screen_info.vbl  = Screen('Flip', screen_info.window, screen_info.vbl + (screen_info.waitframes - 0.5) * screen_info.ifi);
            
            if sum(buttons) > 0
                clickOccurred = true;
            end
        end
end
New_vbl = screen_info.vbl;

end