function v = Evar_sigma(x,mu, logsigma, lambda)
% this function compute the expected variance
% of the psychometric slope (sigma)
% - changed parametrization to log-sigma

v = (pi* (exp(logsigma)^4) * exp(((x - mu)/exp(logsigma))^2) * (1 - (1 - 2*lambda)^2 * erf((x - mu)/(sqrt(2)*exp(logsigma)))^2)) / (2*(1 - 2*lambda)^2 *(x -mu)^2);