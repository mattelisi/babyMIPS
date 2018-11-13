function [design, qp] = runTrials(design, datFile,  scr, visual, const, qp)
% run experimental blocks

% hide cursor
HideCursor;

% preload important functions
Screen(scr.main, 'Flip');
GetSecs;
WaitSecs(.2);
FlushEvents('keyDown');

% create data fid
datFid = fopen(datFile, 'w');

% track score
all_score = [];

% unify keynames for different operating systems
KbName('UnifyKeyNames');

for b = 1:design.nBlocks

    ntt = length(design.b(b).trial);

    % instructions
    systemFont = 'Arial'; % 'Courier';
    systemFontSize = 19;
    GeneralInstructions = ['Block ',num2str(b),' of ',num2str(design.nBlocks),'. \n\n',...
        'Press any key to start.'];
    Screen('TextSize', scr.main, systemFontSize);
    Screen('TextFont', scr.main, systemFont);
    Screen('FillRect', scr.main, visual.bgColor);

    DrawFormattedText(scr.main, GeneralInstructions, 'center', 'center', visual.fgColor,70);
    Screen('Flip', scr.main);

    SitNWait;

    t = 0;
    while t < ntt
        t = t + 1;
        td = design.b(b).trial(t);
        
        % Quest+: get recommendations for next trial ----------------------------------------------------------
        if td.cond~=0 % td.internalMotion == 1 && design.practice~=0 && 
            if eval(['qp.',td.acode,'.count > 0'])
                eval(['[nextS, qp.',td.acode,']= QuestNext(qp.',td.acode,');']);
                td.dY = nextS;
            else
                td.dY = 1;
            end
        else
            % set a random, easy stimulus for catch trials (uniform dY in 1:2)
            td.dY = (0.5 + rand(1));
        end
        % ------------------------------------------------------------------------------------------------------

        [data, rr, acc] = runSingleTrial(td, scr, visual, const, design);
        dataStr = sprintf('%i\t%i\t%s\n',b,t,data); % print data to string
        fprintf(datFid,dataStr);                    % write data to datFile
        
        % Quest+: update staircase structure file --------------------------------------------------------------
        if td.cond~=0 % td.internalMotion == 1 % && design.practice~=0
            eval(['qp.',td.acode,'.count = qp.',td.acode,'.count + 1;']);
            eval(['qp.',td.acode,'.x(qp.',td.acode,'.count) = td.dY;']);
            eval(['qp.',td.acode,'.rr(qp.',td.acode,'.count) = rr;']);
            eval(['qp.',td.acode,'.tab.p = p_m_uncond(td.dY, qp.',td.acode,'.tab, rr);']); % update parameter posterior probability density
        end
        % ------------------------------------------------------------------------------------------------------
        
        % keep track of score in catch trials
        if td.internalMotion==0
            all_score = [all_score, acc];
        end

        WaitSecs(design.iti);

        if const.saveMovie
            if t > const.nTrialMovie
                return
            end
        end

    end
end

fclose(datFid); % close datFile

Screen('FillRect', scr.main,visual.bgColor);
Screen(scr.main,'DrawText','Thanks! You have completed this part of the study.',100,100,visual.fgColor);
drawSmiley(scr.main, [scr.centerX, scr.centerY], 120, mean(all_score), 1);
Screen(scr.main,'DrawText','Press any key to exit.',100,scr.yres-100,visual.fgColor);
Screen(scr.main,'Flip');
ShowCursor;
WaitSecs(0.5);
SitNWait;

