x = 0:pi/100:10*pi;
y = sin(x);
z = cos(x);
w = x./x;
% loop
n = numel(x);
% axes1 plot
h(1) = plot(handles.axes1, x(1), y(1));
h(2) = plot(handles.axes1, x(1), z(1));
% axes2 plot
h(3) = plot(handles.axes2, x(1), w(1));
t1 = tic()
for i = 1:n-1
        % axes1
        set(h(1), 'XData', x(1:i), 'YData', y(1:i));
        set(h(2), 'XData', x(1:i), 'YData', z(1:i), 'color', 'green');
        % axes2
        set(h(3), 'XData', x(1:i), 'YData', w(1:i), 'color', 'red');
        drawnow;
        pause(1/10);
end 
toc
hold off
