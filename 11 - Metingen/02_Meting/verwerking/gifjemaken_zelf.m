
filename = 'lalala.gif';
hoek=linspace(0,360,10);
for n = 1:length(hoek)
      % om te laten draaien
      view([hoek(n) 0])
      drawnow
      frame = getframe(1);
      im = frame2im(frame);
      [imind,cm] = rgb2ind(im,256);
      if n == 1;
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
      else
          imwrite(imind,cm,filename,'gif','WriteMode','append');
      end
end