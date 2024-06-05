function TG = deg2pix(alphx, alphy, win)


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

dx=tan(2*pi*alphx/360)*LL;
dy=tan(2*pi*alphy/360)*LL;

TGx=dx/(XX/win.screenXpixels)+win.center(1);

TGy=dy/(YY/win.screenYpixels)+win.center(2);

TG = round([TGx TGy]);
end