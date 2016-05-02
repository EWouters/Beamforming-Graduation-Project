% polar_ang_avg.m:
% Polar plot of angular average of sum of squares of amplitudes which
% interfere to create beam-formed response.  Exact same set-up here as in
% file polar_interference.m; the only difference is here the amplitudes are
% averaged at each angle to create a line plot rather than imagesc() style
% of plot.
% This script loops over various choices of #elements, tranducer spacing,
% and relative phase delay, to create a set of plots which are saved into
% *.png files in the current directory.
% This script calls file s.m for function S().
%
% Andy Ganse, APL-UW (Seattle), 2003
% aganse@apl.washington.edu


% set choices of values to loop over in creating plots:
N=[3 5 7];   % number of transducer elements
d=[5 10 25];  % spacing between elements (radians)
p=[0 5 10 25 40];  % phase delay (radians)

t=0:360;
t=t*2*pi/360;

%do single-element case separately first, before looping:
z=S(1,0,0);
Z=sum(abs(z),2);
polar(t,Z'./max(Z'));
title('One element, no phase delay');
disp('printing file n1d0p0.polar.png');
eval(sprintf('print -dpng n1d0p0.polar.png'));



% Now loop over the rest of the cases:
for i=1:3
  for j=1:3
    for k=1:5
      z=S(N(i),d(j),p(k));
      Z=sum(abs(z),2);
      polar(t,Z'./max(Z'));
      title([num2str(N(i)) ' elements, spacing = ' num2str(d(j)) ...
          ', relative phase delay = ' num2str(p(k))]);
      filenm = ['n' num2str(N(i)) 'd' num2str(d(j)) 'p' num2str(p(k)) '.polar.png'];
      disp(['printing file ' filenm]);
      eval(sprintf('print -dpng ''%s''',filenm));
    end;
  end;
end;


