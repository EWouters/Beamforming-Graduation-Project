x_5x12=[linspace(0,120,13) linspace(0,120,13) linspace(0,120,13) linspace(0,120,13) linspace(0,120,13)];
x_2x6=[linspace(0,120,7) linspace(0,120,7)];
x_1x3=[0 40 80 120];
x_pool=60;
x=[x_5x12 x_2x6 x_1x3 x_pool];
y=[60*ones(1,13) 52.5*ones(1,13) 45*ones(1,13) 37.5*ones(1,13) 30*ones(1,13) 22.5*ones(1,7) 15*ones(1,7) 7.5*ones(1,4) 0];
plot(x,y,'r.','MarkerSize',20);
grid
xlabel('\theta in degrees', 'FontSize', 18)
ylabel('\phi in degrees', 'FontSize', 18)
title('Sampling point on one face of a pole (\theta\in[0^\circ,120^\circ] and \phi\in[0^\circ,60^\circ])', 'FontSize', 16)