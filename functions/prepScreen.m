function scr = prepScreen(const)
%
% screen settings - double-drift with noise targets
%
% Matteo Lisi, 2014
%

HideCursor;

scr.subDist = 56;   % subject distance (cm)
scr.colDept = 32;
scr.width   = 333;  % monitor width (mm)

% If there are multiple displays guess that one without the menu bar is the
% best choice.  Dislay 0 has the menu bar.
scr.allScreens = Screen('Screens');
scr.expScreen  = max(scr.allScreens);

% this is needed on my crappy mac running High Sierra
% it should be commented to guarantee accurate timing in a decent setup
Screen('Preference', 'SkipSyncTests', 1);

% set resolution ?
%Screen('Resolution', scr.expScreen, 1600, 900);

% Open a window.  Note the new argument to OpenWindow with value 2, specifying the number of buffers to the onscreen window.
[scr.main,scr.rect] = Screen('OpenWindow',scr.expScreen, [0.5 0.5 0.5],[],scr.colDept,2,0,4);

Screen('BlendFunction',scr.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% get information about  screen
[scr.xres, scr.yres]    = Screen('WindowSize', scr.main);       % heigth and width of screen [pix]

% determine th main window's center
[scr.centerX, scr.centerY] = WindowCenter(scr.main);

% refresh duration
scr.fd = Screen('GetFlipInterval',scr.main);    % frame duration [s]

% Give the display a moment to recover from the change of display mode when
% opening a window. It takes some monitors and LCD scan converters a few seconds to resync.
WaitSecs(2);
