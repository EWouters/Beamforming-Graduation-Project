% polar_interference.m:
% Polar plot of amplitudes interfering to create beam-formed response.
% This script loops over various choices of #elements, tranducer spacing,
% and relative phase delay, to create a set of plots which are saved into
% *.png files in the current directory.
% This script calls file s.m for function S().
%
% Andy Ganse, APL-UW (Seattle), 2003
% aganse@apl.washington.edu


% set choices of values to loop over in creating plots:
N=[3 5];   % number of transducer elements
d=[5 10];  % spacing between elements (radians)
p=[-10 -7 -5 -2 0 2 5 7 10];  % phase delay (radians)

% a good size of polar plot:
maxradius=201;

% do single-element case separately first, before looping:
f=S(1,0,0);
% Matlab does not have a polar version of imagesc() that I am aware of, so
% loop over all pixels in a square plot, mapping angle/radius pairs to pixel:
for x=1:(2*maxradius)
  for y=1:(2*maxradius)
    % assumes 1,1 at lower left, but in matlab plot it's top left, so rot90 later
    a=mod(round(360*atan2(y-maxradius,x-maxradius)/(2*pi)),360);
    r=round(sqrt((x-maxradius)^2+(y-maxradius)^2));
    if(a>=1 & a<=361 & r>=1 & r<=maxradius) F(x,y)=f(a,r);
    else F(x,y)=0;
    end;
  end;
end;
imagesc( rot90(F) );  % because math assumed 1,1 was at lower left, not top left
axis square;
title('One element, no phase delay');
disp('printing file n1d0p0.png');
eval(sprintf('print -dpng n1d0p0.png'));


% Now loop over the rest of the cases:
for i=1:2
  for j=1:2
    for k=1:9
      f=S( N(i), d(j), p(k) );
      % Matlab does not have a polar version of imagesc() that I am aware of, so
      % loop over all pixels in a square plot, mapping angle/radius pairs to pixel:
      for x=1:(2*maxradius)
        for y=1:(2*maxradius)
          % assumes 1,1 at lower left, but in matlab plot it's top left, so rot90 later
          a=mod(round(360*atan2(y-maxradius,x-maxradius)/(2*pi)),360);
          r=round(sqrt((x-maxradius)^2+(y-maxradius)^2));
          if(a>=1 & a<=361 & r>=1 & r<=maxradius) F(x,y)=f(a,r);
          else F(x,y)=0;
          end;
        end;
      end;
      imagesc( rot90(F) );  % because math assumed 1,1 was lower left, not top left
      axis square;
      title([num2str(N(i)) ' elements, spacing = ' num2str(d(j)) ...
          ', relative phase delay = ' num2str(p(k))]);
      filenm = ['n' num2str(N(i)) 'd' num2str(d(j)) 'p' num2str(p(k)) '.png'];
      disp(['printing file ' filenm]);
      eval(sprintf('print -dpng ''%s''',filenm));
    end;
  end;
end;

