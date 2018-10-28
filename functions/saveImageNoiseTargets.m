% script that draw a bunch of noise targets

%addpath('functions/');
const.gammaLinear = 0;

%
scr = prepScreen(const);
visual = prepStim(scr, const);
design = genDesign(visual, scr, 0);

% target positions
x_coord = linspace(0, scr.xres, 10);
y_coord = linspace(0, scr.yres, 7);
x_coord = x_coord(2:end-1);
y_coord = y_coord(2:end-1);

tsize = round(design.textureSize*design.sigma*visual.ppd); % texture size
if mod(tsize,2)==0; tsize = tsize+1; end

% gaussian envelope
[gx,gy]=meshgrid(-floor(tsize/2):floor(tsize/2), -floor(tsize/2):floor(tsize/2));
env = exp( -((gx.^2)+(gy.^2)) /(2*(design.sigma*visual.ppd)^2));

wl = 1/5 * visual.ppd;

Screen('FillRect', scr.main,visual.bgColor);
HideCursor;

i=0;
for x_i = x_coord
for y_i = y_coord

    i = i+1;
    noiseimg = (255*fractionalNoise(zeros(tsize, tsize), wl, 3)) -visual.bgColor;
    m = (noiseimg).*env;
    tex(i)=Screen('MakeTexture', scr.main, uint8(visual.bgColor + m));

    imrect = [([x_i y_i] -round(tsize/2)) ([x_i y_i] +round(tsize/2))];
    Screen('DrawTexture', scr.main, tex(i),[],imrect);
    
end
end
Screen(scr.main,'Flip'); 

imageArray = Screen('GetImage', scr.main);
imwrite(imageArray, 'noise_stimuli.jpg')

WaitSecs(.1);
ShowCursor;
Screen('CloseAll');

