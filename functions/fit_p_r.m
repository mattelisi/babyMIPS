function [mu, logsigma, lambda, L] = fit_p_r(x,r, mu0, logsigma0, lambda0)
%
% fit cumulative Gaussian with symmetric asymptotes (lambda and 1-lambda)
%

% initial parameters
if nargin < 5; lambda0 = 0; end
if nargin < 4; logsigma0 = log(mean(abs(x))); end
if nargin < 3; mu0 = 0; end
par0 = [mu0, logsigma0, lambda0];

% options
options = optimset('Display', 'off') ;

% set boundaries
lb = [-4*exp(logsigma0),    -Inf, 0];
ub = [ 4*exp(logsigma0),     Inf, 0.4];

% do optimization
fun = @(par) -L_r(x, r, par(1), par(2), par(3));
[par, L] = fmincon(fun, par0, [],[],[],[], lb, ub,[],options);

% output parameters & loglikelihood
mu = par(1); 
logsigma = par(2);
lambda = par(3);
L = -L;
