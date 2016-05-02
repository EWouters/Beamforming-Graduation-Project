function vis_scenario(room_dim,mics_pos,realmics_pos,source_pos,interf_pos,focal_point,focal_interf,swinrad,iwinrad,alphavis)
% Function to visualize a simulated acoustic scenario for the beamformer.
% Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl).
[XS, YS, ZS]=sphere(50);

XSs=XS.*swinrad+focal_point(1);
YSs=YS.*swinrad+focal_point(2);
ZSs=ZS.*swinrad+focal_point(3);

XSs1=XS.*swinrad/3+focal_point(1);
YSs1=YS.*swinrad/3+focal_point(2);
ZSs1=ZS.*swinrad/3+focal_point(3);

XSs2=XS.*2*swinrad/3+focal_point(1);
YSs2=YS.*2*swinrad/3+focal_point(2);
ZSs2=ZS.*2*swinrad/3+focal_point(3);


room_plot_axis=[0 room_dim(1) 0 room_dim(2) 0 room_dim(3)];
%close(figure(1));
figure(1);
clf;
hold all;
plot3(gca,realmics_pos(:,1),realmics_pos(:,2),realmics_pos(:,3),'ko','MarkerSize',7);
plot3(gca,mics_pos(:,1),mics_pos(:,2),mics_pos(:,3),'ro','MarkerFaceColor','r','MarkerSize',5);

plot3(gca,focal_interf(:,1),focal_interf(:,2),focal_interf(:,3),'ko','MarkerFaceColor','k','MarkerSize',5);
plot3(gca,focal_point(1,1),focal_point(1,2),focal_point(1,3),'ko','MarkerFaceColor','k','MarkerSize',5);
surf(XSs,YSs,ZSs,'FaceColor','none','Edgecolor',[0 1 0],'FaceAlpha',0,'EdgeAlpha',alphavis);
%surf(XSs1,YSs1,ZSs1,'FaceColor','interp','Edgecolor',[0 1 0],'FaceAlpha',0,'EdgeAlpha',alphavis);
%surf(XSs2,YSs2,ZSs2,'FaceColor','none','Edgecolor',[0 1 0],'FaceAlpha',0,'EdgeAlpha',alphavis);
plot3(gca,source_pos(:,1),source_pos(:,2),source_pos(:,3),'go','MarkerFaceColor','g','MarkerSize',7);
plot3(gca,interf_pos(:,1),interf_pos(:,2),interf_pos(:,3),'bo','MarkerFaceColor','b','MarkerSize',7);


for nn = 1:size(interf_pos,1);
XSi=XS.*iwinrad+focal_interf(nn,1);
YSi=YS.*iwinrad+focal_interf(nn,2);
ZSi=ZS.*iwinrad+focal_interf(nn,3);

XSi1=XS.*iwinrad/3+focal_interf(nn,1);
YSi1=YS.*iwinrad/3+focal_interf(nn,2);
ZSi1=ZS.*iwinrad/3+focal_interf(nn,3);

XSi2=XS.*2*iwinrad/3+focal_interf(nn,1);
YSi2=YS.*2*iwinrad/3+focal_interf(nn,2);
ZSi2=ZS.*2*iwinrad/3+focal_interf(nn,3);

surf(XSi,YSi,ZSi,'FaceColor','none','Edgecolor',[0 0 1],'FaceAlpha',0,'EdgeAlpha',alphavis);
%surf(XSi1,YSi1,ZSi1,'FaceColor','interp','Edgecolor',[0 0 1],'FaceAlpha',0,'EdgeAlpha',alphavis);
%surf(XSi2,YSi2,ZSi2,'FaceColor','interp','Edgecolor',[0 0 1],'FaceAlpha',0,'EdgeAlpha',alphavis);

end

grid on;
axis equal;
axis(room_plot_axis);
axis vis3d;
view(-36,16);
%view(-180,90);
zoom(1.4);
xlabel('x');
ylabel('y');
zlabel('z');
drawnow;

% pause(0.00001);
% frame_h = get(handle(gcf),'JavaFrame');
% set(frame_h,'Maximized',1);

return