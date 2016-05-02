function vis_scenarioBAP(room_dim,mics_pos,realmics_pos,source_pos,interf_pos,focal_point,focal_interf,swinrad,iwinrad,alphavist,alphavisi)
% Function to visualize a simulated acoustic scenario for the beamformer.
% Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl).
[XS, YS, ZS]=sphere(50);

XSs=XS.*swinrad+focal_point(1);
YSs=YS.*swinrad+focal_point(2);
ZSs=ZS.*swinrad+focal_point(3);



room_plot_axis=[0 room_dim(1) 0 room_dim(2) 0 room_dim(3)];
%close(figure(1));
figh=figure(1);
clf;
hold all;
plot3(gca,realmics_pos(:,1),realmics_pos(:,2),realmics_pos(:,3),'ko','MarkerSize',7);
plot3(gca,mics_pos(:,1),mics_pos(:,2),mics_pos(:,3),'ro','MarkerFaceColor','r','MarkerSize',5);

plot3(gca,focal_interf(:,1),focal_interf(:,2),focal_interf(:,3),'bo','MarkerFaceColor','b','MarkerSize',5);
plot3(gca,focal_point(1,1),focal_point(1,2),focal_point(1,3),'go','MarkerFaceColor','g','MarkerSize',5);
surf(XSs,YSs,ZSs,'FaceColor','none','Edgecolor',[0 1 0],'FaceAlpha',0,'EdgeAlpha',alphavist);
plot3(gca,source_pos(:,1),source_pos(:,2),source_pos(:,3),'ko','MarkerSize',7);
plot3(gca,interf_pos(:,1),interf_pos(:,2),interf_pos(:,3),'ko','MarkerSize',7);


for nn = 1:size(interf_pos,1);
XSi=XS.*iwinrad+focal_interf(nn,1);
YSi=YS.*iwinrad+focal_interf(nn,2);
ZSi=ZS.*iwinrad+focal_interf(nn,3);

surf(XSi,YSi,ZSi,'FaceColor','none','Edgecolor',[0 0 1],'FaceAlpha',0,'EdgeAlpha',alphavisi);

end
xwidth = 900;
ywidth = 500;

grid on;
axis equal;
axis(room_plot_axis);
axis vis3d;
view(-10,30);
zoom(1.4);
xlabel('x','fontsize',18);
ylabel('y','fontsize',18);
zlabel('z','fontsize',18);
set(gca,'fontsize',18);
set(gca,'xtick',[0 1 2 3 4 5 6],'xticklabel',[0 1 2 3 4 5 6]);
set(gca,'ytick',[0 1 2 3],'yticklabel',[0 1 2 3]);
set(gca,'ztick',[0 1 2 3],'zticklabel',[0 1 2 3]);

set(figh,'PaperPositionMode','auto')
set(figh, 'Position', [0 0 xwidth ywidth])
set(get(gca,'xlabel'),'Position',[-2.5 -35.5 20.3136])
set(get(gca,'ylabel'),'Position',[-6.8 -33.0 20.6252])

drawnow;

% pause(0.00001);
% frame_h = get(handle(gcf),'JavaFrame');
% set(frame_h,'Maximized',1);

return