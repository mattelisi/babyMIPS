function [practice] = getAddInfo
%
% asks for any additional info
%

FlushEvents('keyDown');

prct = input('\n\n>>>> Is this a practice session? (y/n)  ','s');

if strcmp(prct,'y')
  practice = 1;
else
  practice = 0;
end
