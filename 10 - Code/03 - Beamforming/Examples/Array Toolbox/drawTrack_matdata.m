function drawTrack_matdata(x,y,intensity, maxintens, minintens, slope)

% simply plots the points for the current timestamp

%first determine the size of the dot.
% size=70 at maxintens
% size=5 at minintens
% linear weighting is applied for now
dotweight= slope*intensity+5;

scatter(x, y, dotweight, 'red');