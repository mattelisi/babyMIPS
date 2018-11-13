function L = L_r(x, r, mu, logsigma, lambda)
%
% log-likelihood of the psychometric function defined in p_r1_cond.m
% 
% changed parametrization to log-sigma

L = sum(log(p_r1_cond(x(r==1), mu, exp(logsigma), lambda))) + sum(log(1 - p_r1_cond(x(r==0), mu, exp(logsigma), lambda)));