function drawFixation(col,loc,scr,visual)
%
% simple dot
%

if length(loc)==2
    loc=[loc loc];
end
pu = round(visual.ppd*0.1);
Screen('DrawLine',scr.main,col,loc(1)-3*pu, loc(2), loc(1)+3*pu, loc(2),3);
Screen('DrawLine',scr.main,col,loc(1), loc(2)-3*pu, loc(1), loc(2)+3*pu, 3);
%Screen(scr.main,'FrameOval',col,loc+2*[-pu -pu pu pu],pu/2);
%Screen(scr.main,'FillOval',col,loc+[-pu -pu pu pu]);
% Screen(scr.main,'FrameOval',rim,loc+3*[-pu -pu pu pu],pu/2);

