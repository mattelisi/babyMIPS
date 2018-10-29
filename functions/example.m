% this show how to use Quest+ for a 3 parameters psy functions

clear all; 

% settings
n_trial = 100; % number of trials
use_sweet = 0; % whether you want to present stimuli at sweetpoints instead of boundaries

%% true parameters
mu = 0; 
sigma = 1;
lambda = 0.01;

%% initialize quest
range_mu = [-2, 2];
range_sigma = [0.1, 4];
gridsize = 30;
lambdas_ = [0, 0.01, 0.02, 0.05, 0.1];
qp = set_unif_p_table(range_mu, range_sigma, gridsize,lambdas_); % this set the uniform prior

%% define stimuli range
stim_range = [-4, 4];
stim_n = 100;
stim_x = linspace(stim_range(1),stim_range(2),stim_n);

%% initialize remaining parts of quest+ structure
qp.x_values = stim_x; % stimuli needs to be also in the quest+ structure
qp.x_n = stim_n;
qp.x_range = stim_range;
qp.EH_x = NaN(stim_n,1); % initialize vector of expected entropies

% preallocate
x = NaN(n_trial,1);
r = NaN(n_trial,1);
x(1) = mean(range_mu)+rand*stim_range(2) - stim_range(2)/2; % random intensity for the first trial

%% run
for t = 1:n_trial
    
    % generate response
    r(t) = binornd(1, p_r1_cond(x(t),mu,sigma, lambda));
    
    % update posterior probability over parameters
    qp.p = p_m_uncond(x(t), qp, r(t));
    
    % this is needed only if you want to compute the sweetpoints
    if use_sweet
        qp.x = x(1:t); qp.rr = r(1:t);
    end
        
    % find the stimulus associated with the smallest expected entropy
    if t<n_trial
        x(t+1) = QuestNext(qp, use_sweet);
    end
    
end

%% use MLE to obtain final estimates
[mu_hat, sigma_hat, lambda_hat, L] = fit_p_r(x, r);

fprintf('\n\nEstimates: mu=%.2f  sigma=%.2f lambda=%.2f \n',[mu_hat, sigma_hat, lambda_hat]);
fprintf('\nThe true values were: mu=%.2f  sigma=%.2f lambda=%.2f.\n',[mu, sigma, lambda]);


%% plot stimuli placements
figure('Color','w', 'Position',[0 50 500 220]); 
subplot(1,2,1)
plot(x,'o','Color','k'); hold on
t_i = 1:t;
plot(t_i(r(1:t)==1), x(r(1:t)==1),'o','Color','k', 'MarkerFaceColor', 'k'); hold off
ylim(stim_range)
xlim([-2 n_trial+3])
xlabel('trial')
ylabel('stimulus')
title('Stimuli placements & responses')
drawnow


%% Plot function with maximum likelihood fit - Watson style
subplot(1,2,2)
hold on
stim = unique(x);
nTrials = NaN(size(stim));
pCorrect = NaN(size(stim));
for cc = 1:length(stim)
    nTrials(cc) = sum(x==stim(cc));
    pCorrect(cc) = mean(r(x==stim(cc)));
end
stimFine = linspace(stim_range(1),stim_range(2),100)';
plotProportionsFit = p_r1_cond(stimFine,mu_hat, sigma_hat, lambda_hat);

for cc = 1:length(stim)
    h = scatter(stim(cc),pCorrect(cc),100,'o','MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],...
        'MarkerFaceAlpha',nTrials(cc)/max(nTrials),'MarkerEdgeAlpha',nTrials(cc)/max(nTrials));
end
plot(stimFine,plotProportionsFit,'-','Color',[1 0.2 0.0],'LineWidth',3);
xlabel('Stimulus Value');
ylabel('Proportion Correct');
xlim(stim_range); ylim([0 1]);
title({sprintf('mu=%.2f  sigma=%.2f lambda=%.2f',[mu_hat, sigma_hat, lambda_hat]), ''});
hold off
