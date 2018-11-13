function p = p_r1_cond(x,mu, logsigma, lambda)
%
% probability of choosing "+" for a cumulative 
% Gaussian with symmetric asymptote
% - parametrization changed to logsigma

p = lambda + (1-2*lambda).*(1/2).*(1 + erf((x-mu)./(sqrt(2)*exp(logsigma))));