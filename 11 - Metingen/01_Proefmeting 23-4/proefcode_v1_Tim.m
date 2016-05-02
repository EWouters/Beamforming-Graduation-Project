% Proefmetingen directivities
i=0;

h = waitbar(0,'Please wait... turning to absolute 0');
bkstep('turn absolute', 0)
pause(2)

waitbar(i/360,h,sprintf('Please wait... measurement at %i of 360',i))

while i<360
    
    %kies een van de twee:
        %playblocking(MLS_measurement);
        playblocking(TSP_measurement);
    pause(1);
    i=i+8;
    bkstep('turn relative', 8);
    pause(0.5)
    waitbar(i/360,h,sprintf('Please wait... measurement at %i of 360',i))
end;
delete(h)
h = msgbox('Measurement Completed');
