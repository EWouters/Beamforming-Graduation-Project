function recorded = audio(N, Fs, ch)

recorded = wavrecord(N, Fs, ch);
t = (1:1:N);
plot(t,recorded(:,1));
hold on
plot(t,recorded(:,2), '-.r');
title('recorded in-signals')
legend('mic 1', 'mic 2')
% file_1 = fopen('test.txt');
% 
% fprintf(file_1,'.txt', recorded);
% fclose(file_1);
recorded1 = recorded(:,1);
recorded2 = recorded(:,2);
save('H:\Desktop\test.txt' , 'recorded1','-ascii')
save('H:\Desktop\testII.txt', 'recorded2','-ascii')
end