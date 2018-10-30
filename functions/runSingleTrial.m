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
chk = visual.fixCkRad;

% compute target path
duration = td.dur;
nFrames = round(duration/scr.fd);
% ecc = td.ecc;
% startEcc = (design.radius  - td.envDir*td.movTime*td.envSpeed/2)*visual.ppd;
% endEcc = startEcc + (td.envDir*duration*td.envSpeed/2)*visual.ppd;
% tarRad = linspace(startEcc,endEcc,nFrames);

% add random jitter to trajectory orientation of catch trials
% if td.internalMotion == 0
%     alphaJitter = sign(randn(1))*(design.alphaJitterRange(1) + rand(1)*(design.alphaJitterRange(2) - design.alphaJitterRange(1)));
% else
%     alphaJitter = 0;
% end
% alpha = -(rad2deg(td.alpha+pi)); % this is for drawing the texture on the screen with the correct rotation angle
% [tx, ty] = pol2cart(td.alpha, tarRad);
% [zeroX, zeroY] = pol2cart(td.alpha, visual.ppd*design.radius);
% tx = tx - zeroX;
% ty = ty - zeroY;
% 
% % save the true direction of displacement
% if td.envDir==1
%   trueDir = td.alpha + alphaJitter/180*pi;
% else
%   trueDir = (td.alpha+pi) + alphaJitter/180*pi;
% end

% rotate path based on alphaJitter angle
% path = [cosd(alphaJitter),-sind(alphaJitter);sind(alphaJitter),cosd(alphaJitter)]*[tx; ty];
% tx = path(1,:) + zeroX;
% ty = path(2,:) + zeroY;
% 
% tarPos = repmat([cxm cym],length(tx),1) + [tx' -ty']; % invert Y sign for screen coordinates
% tx = tarPos(:,1);
% ty = tarPos(:,2);

% determine positions rect
if td.dY>0 % right target
    pos_right = [round(cxm+td.ecc*visual.ppd), round(cym+td.dY*visual.ppd/2)];
    pos_left  = [round(cxm-td.ecc*visual.ppd), round(cym-td.dY*visual.ppd/2)];
    % need to set here also the alpha of the texture, accordingly
    alpha_right = 90;
    alpha_left = -90;
else
    pos_right = [round(cxm+td.ecc*visual.ppd), round(cym-td.dY*visual.ppd/2)];
    pos_left  = [round(cxm-td.ecc*visual.ppd), round(cym+td.dY*visual.ppd/2)];
    alpha_right = -90;
    alpha_left =   90;
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
    %if td.driftDir == -1
        c = 0; tex = zeros(nFrames, 1);
        for i=1:nFrames
            aBeg = 1 + (c*step);
            aEnd = tsize + (c*step);
            c = c+1;
            noisePatt = noiseimg(aBeg:aEnd,:);
            m = (noisePatt).*env;
            tex(i)=Screen('MakeTexture', scr.main, uint8(visual.bgColor + design.contrast*m));
        end
%     else
%         c = 0; tex = zeros(nFrames, 1);
%         for i=nFrames:-1:1
%             aBeg = 1 + (c*step);
%             aEnd = tsize + (c*step);
%             c = c+1;
%             noisePatt = noiseimg(aBeg:aEnd,:);
%             m = (noisePatt).*env;
%             tex(i)=Screen('MakeTexture', scr.main, uint8(visual.bgColor + td.contrast*m));
%         end
%     end
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
tHClk   = NaN;

%
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

%
for i = 1:nFrames

    % draw stimuli
    Screen('DrawTexture', scr.main, tex(i),[],rects_right,alpha_right);
    Screen('DrawTexture', scr.main, tex(i),[],rects_left,alpha_left);
    drawFixation(visual.fixCol,td.fixLoc,scr,visual);

    % drawing finished, flip canvas
    % Screen('DrawingFinished',scr.main);
    tFlip = Screen('Flip', scr.main, tFlip + scr.fd - design.preRelease);

    if i==1
      tBeg = tFlip;
    end

    if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 1); end
end

%%
Screen(scr.main,'Flip'); % blank screen

if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(0.3/scr.fd));
end

% %% collect perceptual response
% WaitSecs(0.3); % delay stimulus offset - response
% 
% point = rand*2*pi; % set random initial position
% 
% [mx ,my] = pol2cart(point,1);
% [px ,py] = pol2cart(point,60);
% drawArrow([tx(1) ty(1)],[px+tx(1) ,-py+ty(1)],20,scr,visual.fgColor,3);
% SetMouse(round(scr.centerX+visual.ppd*mx), round(scr.centerY-visual.ppd*my), scr.main); % set mouse
% %HideCursor;
% 
% tHClk = Screen('Flip',scr.main);
% if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 10); end
% click = false;
% while ~click
%     [mx,my,buttons] = GetMouse(scr.main);
%     [lastPoint,~] = cart2pol(mx-scr.centerX, scr.centerY-my);
%     [px ,py] = pol2cart(lastPoint,70);
%     drawArrow([tx(1) ty(1)],[px+tx(1) ,-py+ty(1)],20,scr,visual.fgColor,3);
%     Screen('Flip',scr.main);
%     if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 2); end
%     if any(buttons)
%         tResp = GetSecs;
%         click = true;
%         resp = lastPoint;
%     end
% end
% Screen('Flip',scr.main);
% if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, 2); end

% trial OK; collect response
while 1
    [keyisdown, secs, keycode] = KbCheck(-1);
    
    if keyisdown && (keycode(leftkey) || keycode(rightkey))
        tResp = secs - tOff;
        
        if keycode(leftkey)
            resp = -1;
            rr = 0;
        else
            resp = 1;
            rr = 1;
        end
        break;
    end
end

% determine accuracy
if td.internalMotion == 0
    if (td.dY<0 && rr==1) || (td.dY>0 && rr==0)
        acc = 1;
    else
        acc=0;
    end
else
    acc = NaN;
end

%% give feedback if practice session
if design.practice && td.internalMotion
  drawSmiley(scr.main, [cxm, cym], 60, acc, 1)
  Screen('Flip',scr.main);
  WaitSecs(0.2);
  SitNWait;
end

%% save data

if const.saveMovie; Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(1/scr.fd)); end

% collect trial information
trialData = sprintf('%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f',[td.fixLoc td.soa td.internalMotion td.duration td.contrast td.wavelength td.speed td.sigma td.ecc]); 

% determine presentation times relative to 1st frame of motion
timeData = sprintf('%.2f\t%i\t%i\t%i',[tBeg round(1000*([tFix tEnd tResp]-tBeg ))]);

% determine response data
respData = sprintf('%i\t%i\t%i',resp, rr, acc);

% collect data for tab [14 x trialData, 6 x timeData, 1 x respData]
data = sprintf('%s\t%s\t%s',trialData, timeData, respData);


% close active textures
Screen('Close', tex(:))
