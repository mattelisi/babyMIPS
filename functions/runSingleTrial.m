 function [data, rr, acc] = runSingleTrial(td, scr, visual, const, design)
%
% say td.dY is the trial-by-trial suggestion of quest plus

% clear keyboard buffer
FlushEvents('KeyDown');

% define response keys
leftkey = KbName('LeftArrow');
rightkey = KbName('RightArrow');

% predefine boundary information
cxm = round(td.fixLoc(1)); % that is already in pixels
cym = round(td.fixLoc(2));

% compute target path
duration = td.dur;
nFrames = round(duration/scr.fd);

% determine positions rect
if td.side==1  % right target higher
    pos_right = [round(cxm+td.ecc*visual.ppd), round(cym-td.dY*visual.ppd)];
    pos_left  = [round(cxm-td.ecc*visual.ppd), round(cym+td.dY*visual.ppd)];
    % need to set here also the alpha of the texture, accordingly
    alpha_right = -180;
    alpha_left = 0;
else
    pos_right = [round(cxm+td.ecc*visual.ppd), round(cym+td.dY*visual.ppd)];
    pos_left  = [round(cxm-td.ecc*visual.ppd), round(cym-td.dY*visual.ppd)];
    alpha_right = 0;
    alpha_left = -180;
end

% target path (rect coordinates)
tsize = round(design.textureSize*design.sigma*visual.ppd); % texture size
rects_right = [(pos_right -round(tsize/2)) (pos_right +round(tsize/2))];
rects_left = [(pos_left -round(tsize/2)) (pos_left +round(tsize/2))];

% compute noise pattern
if mod(tsize,2)==0; tsize = tsize+1; end
if td.internalMotion == 1
    step = round(visual.ppd*(td.speed*scr.fd));
    noiseimg = (255*fractionalNoise(zeros(ceil(tsize*2+step*nFrames), tsize), td.wavelength, td.nOctaves)) -visual.bgColor;
    [gx,gy]=meshgrid(-floor(tsize/2):floor(tsize/2), -floor(tsize/2):floor(tsize/2)); % gaussian envelope
    env = exp( -((gx.^2)+(gy.^2)) /(2*(td.sigma*visual.ppd)^2));
    % compute textures for individual frames
    c = 0; tex = zeros(nFrames, 1);
    for i=1:nFrames
        aBeg = 1 + (c*step);
        aEnd = tsize + (c*step);
        c = c+1;
        noisePatt = noiseimg(aBeg:aEnd,:);
        m = (noisePatt).*env;
        tex(i)=Screen('MakeTexture', scr.main, uint8(visual.bgColor + design.contrast*m));
    end
    
    WaitSecs(0.6);
else
    step = visual.ppd*(td.speed*scr.fd) * design.control_f;
    noiseimg = (255*fractionalNoise3(zeros(tsize, tsize, nFrames+10), td.wavelength, td.nOctaves, step)) -visual.bgColor;
    [gx,gy]=meshgrid(-floor(tsize/2):floor(tsize/2), -floor(tsize/2):floor(tsize/2)); % gaussian envelope
    env = exp( -((gx.^2)+(gy.^2)) /(2*(td.sigma*visual.ppd)^2));
    tex = zeros(nFrames, 1);
    for i=1:nFrames
        noisePatt = noiseimg(:,:,i);
        m = (noisePatt).*env;
        tex(i)=Screen('MakeTexture', scr.main, uint8(visual.bgColor + design.contrast*m));
    end
end

% predefine time stamps
tBeg    = NaN;
tEnd    = NaN;
tResp   = NaN;
data = '';

% draw fixation
drawFixation(visual.fixCol,[cxm cym],scr,visual);
tFix = Screen('Flip', scr.main,0);
if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(td.soa/scr.fd));
end

% random SoA before stimulus
tFlip = tFix + td.soa;
WaitSecs(td.soa - 2*design.preRelease);

% stimulus loop
for i = 1:nFrames

    Screen('DrawTexture', scr.main, tex(i),[],rects_right,alpha_right);
    Screen('DrawTexture', scr.main, tex(i),[],rects_left,alpha_left);
    drawFixation(visual.fixCol,td.fixLoc,scr,visual);
    tFlip = Screen('Flip', scr.main, tFlip + scr.fd - design.preRelease);
    if i==1
      tBeg = tFlip;
    end
    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 1); end
end
tEnd = tFlip;

%%
drawFixation(visual.fixCol,[cxm cym],scr,visual);
Screen(scr.main,'Flip'); % blank screen

if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(0.3/scr.fd));
end

% collect response
while 1
    [keyisdown, secs, keycode] = KbCheck(-1);
    if keyisdown && (keycode(leftkey) || keycode(rightkey))
        tResp = secs - tEnd;
        if keycode(leftkey)
            resp = -1;
        else
            resp = 1;
        end
        rr = (td.side*resp +1)/2;
        break;
    end
end

% determine accuracy
if td.internalMotion == 0
    acc = rr;
else
    acc = NaN;
end

%% give feedback if practice session
if design.practice && td.internalMotion==0
  if acc==0
    drawSmiley(scr.main, [cxm, cym], 60, acc+0.1, 1);
  else
    drawSmiley(scr.main, [cxm, cym], 60, acc, 1);
  end
  Screen('Flip',scr.main);
  WaitSecs(0.2);
  SitNWait;
end

%% save data

if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(1/scr.fd)); end

% collect trial information
trialData = sprintf('%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%i',[td.fixLoc td.soa td.internalMotion td.dur td.wavelength td.speed td.sigma td.ecc td.side td.dY td.cond]); 
trialData = sprintf('%s\t%s',trialData, td.acode);

% determine presentation times relative to 1st frame of motion
timeData = sprintf('%.2f\t%i\t%i\t%i',[tBeg round(1000*([tFix tEnd tResp]-tBeg ))]);

% determine response data
respData = sprintf('%i\t%i\t%i',resp, rr, acc);

% collect data for tab [14 x trialData, 6 x timeData, 1 x respData]
data = sprintf('%s\t%s\t%s',trialData, timeData, respData);


% close active textures
Screen('Close', tex(:))
