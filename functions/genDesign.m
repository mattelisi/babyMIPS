function [design, qp] = genDesign(visual,scr, practice, session, vpcode)
%
% generate experiment design
%
% Matteo Lisi, 2014
%

%% display parameters
design.radius = [5 10]; % eccentricity ofthe stimulus
design.fixJtStd = 0.2;  % x-y std. if you want fixation point to vary from trial to trial

%% noise parameter
design.spatFreq = 5; %
design.tempFreq = [2, 10]; % it is actually speed [dva/sec]X, not temporal frequency

if practice
    % 0 is catch trials; the set is repeated 2*design.rep times
  design.internalMotion = [0 0];
else
  design.internalMotion = [0 1 1 1 1]; %
end
design.practice = practice;

%design.envSpeed = 0; % deg/sec
design.sigma = 0.35;
design.contrast = 1;    % keep 1
design.textureSize = 8; % 8 times the sigma of the envelope, so you are sure it is not clipped at edges
design.nOctaves = 2;
design.control_f = 0.5; % determine physical temporal frequency of control trials relative to double-drift

%% task settings
design.side = [1, -1]; % 1 indicates right target is lower (perceptually shifted upward)
design.duration = [0.05, 0.25];
design.range_offset = [-4 4]; % how much higher is the right one?

%% timing
design.soa = [0 300];
design.iti = 0.1;
design.preRelease = scr.fd/3; % half or less of the monitor refresh interval
design.adjustSoa = 0.2;       % catch stimulus takes more to compute, this approximately makes the SoA equal

%% prepare staircase structure
%design.rep = 50;
design.range_mu = [-3, 3];
design.range_sigma = [0.05, 4];
design.gridsize = 50;
design.lambdas_val = 0; %[0, 0.01, 0.02, 0.05, 0.1];
design.stim_n = 100;
c = 0;
cond_matrix = NaN(3, length(design.duration)*length(design.tempFreq)*length(design.radius));
for dur = design.duration 
for speed = design.tempFreq 
for ecc = design.radius
    
    c = c+1;
    cond_matrix(:,c) = [dur, speed, ecc]';
    % condition settings
    eval(['qp.s',num2str(c),'.dur = dur;']);
    eval(['qp.s',num2str(c),'.speed = speed;']);
    eval(['qp.s',num2str(c),'.ecc = ecc;']);
    
    % staircase settings
    eval(['qp.s',num2str(c),'.count = 0;']);
    eval(['qp.s',num2str(c),'.x = [];']);
    eval(['qp.s',num2str(c),'.rr = [];']);
    eval(['qp.s',num2str(c),'.tab = set_unif_lambda(design.range_mu, design.range_sigma, design.gridsize,design.lambdas_val);']);
    eval(['qp.s',num2str(c),'.x_range = design.range_offset;']);
    eval(['qp.s',num2str(c),'.x_n = design.stim_n;']);
    eval(['qp.s',num2str(c),'.x_values = linspace(design.range_offset(1),design.range_offset(2),design.stim_n);']);
    eval(['qp.s',num2str(c),'.x_EH = NaN(1,design.stim_n);']);
    
    % if not the first session, load posterior probability from previous one
    if session > 1
        eval(['qp.s',num2str(c),'.tab.p = readPtab(vpcode, c);']);
    end
end
end
end
design.cond_matrix = cond_matrix;
design.n_cond = c;

%% exp structure
design.nBlocks = 1;
if practice
    design.rep = 1;
else
    design.rep = 5;
end

%% trials list
t = 0;
if ~practice
for c = 1:design.n_cond
for r = 1:round(design.rep/2)
for side = design.side
for im = design.internalMotion(design.internalMotion==1)

    t = t+1;

    trial(t).cond = c;
    trial(t).fixLoc = [scr.centerX scr.centerY] + round(randn(1,2)*design.fixJtStd*visual.ppd);
    trial(t).soa = (design.soa(1) + rand*design.soa(2))/1000;
    trial(t).dur = design.cond_matrix(1,c);
    trial(t).speed = design.cond_matrix(2,c);
    trial(t).ecc = design.cond_matrix(3,c);
    trial(t).side = side;

    % target parameters
    trial(t).spatFreq = design.spatFreq;
    trial(t).wavelength = 1/design.spatFreq * visual.ppd;
    trial(t).sigma = design.sigma;
    trial(t).nOctaves = design.nOctaves;
    trial(t).internalMotion = im;
    trial(t).acode = ['s',num2str(c)];

end
end
end
end
end

% add catch trials to the list
for c = 1:design.n_cond
for r = 1
for side = design.side
for im = design.internalMotion(design.internalMotion==0)
    
    t = t+1;

    trial(t).cond = 0;
    trial(t).fixLoc = [scr.centerX scr.centerY] + round(randn(1,2)*design.fixJtStd*visual.ppd);
    trial(t).soa = (design.soa(1) + rand*design.soa(2))/1000 + design.adjustSoa;
    trial(t).dur = design.cond_matrix(1,c);
    trial(t).speed = design.cond_matrix(2,c);
    trial(t).ecc = design.cond_matrix(3,c);
    trial(t).side = side;
    trial(t).spatFreq = design.spatFreq;
    trial(t).wavelength = 1/design.spatFreq * visual.ppd;
    trial(t).sigma = design.sigma;
    trial(t).nOctaves = design.nOctaves;
    trial(t).internalMotion = im;
    trial(t).acode = 'catch';

end
end
end
end


design.totTrials = t;

% random order
r = randperm(design.totTrials);
trial = trial(r);

% generate blocks
design.blockOrder = 1:design.nBlocks;
design.nTrialsInBlock = design.totTrials/design.nBlocks;
beginB=1; endB=design.nTrialsInBlock;
for i = 1:design.nBlocks
    design.b(i).trial = trial(beginB:endB);
    beginB  = beginB + design.nTrialsInBlock;
    endB    = endB   + design.nTrialsInBlock;
end
