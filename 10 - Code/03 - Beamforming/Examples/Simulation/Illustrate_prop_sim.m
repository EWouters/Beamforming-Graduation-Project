% plot to illustrate the simulations

figure(1)

hold on

%Plot microphones
plot3(1,1,0,'bo')
plot3(1.5,1.15,0,'bo')
plot3(2.3,1.1,0,'bo')
plot3(0.9,2.0,0,'bo')
plot3(1.6,1.9,0,'bo')
plot3(2.25,1.7,0,'bo')

%Plot source of interest
plot3(3,1.5,0.7,'rx', 'MarkerSize', 14)

%Plot interfering sources
plot3(0.5,0.5,0.4,'g>', 'MarkerSize', 14)
plot3(2,2.5,0.4,'g>', 'MarkerSize', 14)
plot3(1.25,0.3,0.4,'g>', 'MarkerSize', 14)

%Plot a plane to illustrate a table
grey = [0.4,0.4,0.4];
patch([0 3 3 0], [0 0 2.5 2.5], [0 0 0 0], grey)

hold off

% Add a title, lables and grid by the plot
title({'Mic position denote by blue Os, and source of interest denoted by red Xs', ...
        'and interfering source denoted by green triangles'})
xlabel('X-Dimension in meters')
ylabel('Y-Dimension in meters')
zlabel('Z-Dimension in meters')
grid on

axis equal  %   For equal axis
view (3)    %   3d view