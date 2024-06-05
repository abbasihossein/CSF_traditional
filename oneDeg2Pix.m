function TG = oneDeg2Pix(alphx,win)


% The size of the monitor in cm
XX =win.wdth;

% Updated on June 26th, 2018. Requires that LL be part of the win
% structure.
if isfield(win,'dist2screen')
LL = win.Dist_from_screen;
else
    LL = 57;%Distance to screen
end

dx=tan(2*pi*alphx/360)*LL;

TGx=dx/(XX/win.screenXpixels);


TG = round(TGx);
end