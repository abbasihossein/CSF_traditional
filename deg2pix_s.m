function Targ_size = deg2pix_s(STIM_size,STIM_loc,win)


% The size of the monitor in cm
XX =win.wdth;
YY =win.hght;

% Updated on June 26th, 2018. Requires that LL be part of the win
% structure.
if isfield(win,'Dist_from_screen')
LL = win.Dist_from_screen;
else
    LL = 57;%Distance to screen
end

dx=LL*(tan(2*pi*STIM_loc/360)-tan(2*pi*(STIM_loc-STIM_size/2)/360));

Targ_size=round(dx/(XX/win.screenXpixels));
end