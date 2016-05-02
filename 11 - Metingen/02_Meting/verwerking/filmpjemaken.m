clear all;
close all;

% rot_deg=2; % voor normale dingen
rot_deg=0.3; % voor het grid

format compact
set(gcf,'Menubar','none','Name','Spheres', ...
 'NumberTitle','off','Position',[10,70,800,600], ...
 'Color',[1 1 1]);

h = axes('Position',[0 0 1 1]);

%Draws sphere
% [X Y Z]=sphere(20);
% C = Z^2 + Y^2;
% hs = surf(X, Y, Z, C);

%%
% KIES een van de ...
% metingen_output_NX506
% metingen_output_tafeltje
grid_presentatie
% metingen_output_NX501

%%
% colorbar weghalen
delete(h);

view([90 30])

%sets wireframe to visible
%set(hs,'EdgeColor',[0.5 0.5 0.5]);

%Alters transparency of sphere
%alpha('color');
%alphamap('rampdown');

%Sets lighting of sphere
%camlight right;
lighting phong
hidden off
axis equal

%Create writerObj
writerObj = VideoWriter('sphere.avi');  
open(writerObj)

%Animated movie of the rotation of the 3D globe
oh=findobj(gca,'type','surface');
%Spins about z axis.
for i = 1:(360/rot_deg)
axis off;
rotate(oh,[0 0 1],rot_deg);
M(i) = getframe(gca);
frame = getframe;
writeVideo(writerObj,frame);
end
% %Spins about y axis.
% for i = 1:36
% axis off;
% rotate(oh,[0 1 0],10);
% M(i) = getframe(gca);
% frame = getframe;
% writeVideo(writerObj,frame);
% end
% %Spins about x axis.
% for i = 1:36
% axis off;
% rotate(oh,[1 0 0],10);
% M(i) = getframe(gca);
% frame = getframe;
% writeVideo(writerObj,frame);
% end

close(writerObj);