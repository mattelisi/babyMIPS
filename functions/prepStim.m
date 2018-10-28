function[visual] = prepStim(scr, const)
%
% 
%
% Prepare display parameters & similar
%

visual.ppd = va2pix(1,scr);   % pixel per degree

visual.black = BlackIndex(scr.main);
visual.white = WhiteIndex(scr.main);

visual.bgColor = floor((visual.black + visual.white) / 2);     % background color
visual.fgColor = visual.black;

visual.scrCenter = [scr.centerX scr.centerY scr.centerX scr.centerY];

visual.fixCkRad = round(2.5*visual.ppd);    % fixation check radius
visual.fixCkCol = visual.black;      % fixation check color
visual.fixCol = 50;

visual.HandClockWidth = round(0.2*visual.ppd);
visual.HandClockColor = visual.black;

% target
visual.tarSize = 200;
visual.res = 1*[visual.tarSize visual.tarSize];

% gamma correction
if const.gammaLinear
    load(const.gamma);
    load(const.gammaRGB);
    
    % prepare and load lookup gamma table
    luminanceRamp = linspace(LR.LMin, LR.LMax, 256);
    invertedRamp = LR.LtoVfun(LR, luminanceRamp);
    invertedRamp = invertedRamp./255;
    % plot(invertedRamp)
    
    inverseCLUT = repmat(invertedRamp',1,3);
    % save gammaTable_greyscale.mat inverseCLUT
    
    Screen('LoadNormalizedGammaTable', scr.main, inverseCLUT);
    
    % visual.bgColor = 20;
    visual.bgColorLuminance = LR.VtoLfun(LR, invertedRamp(visual.bgColor)*255);
end

% increment rage for given white and gray values
% visual.inc = visual.bgColor-visual.black;

% set priority of window activities to maximum
priorityLevel=MaxPriority(scr.main);
Priority(priorityLevel);
