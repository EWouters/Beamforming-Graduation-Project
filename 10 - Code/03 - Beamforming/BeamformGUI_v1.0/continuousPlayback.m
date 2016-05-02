load handel
a = audioplayer(y,Fs);

tic
playblocking(a)
toc

totalSamples = length(y);
windowSize = Fs;
currentSample = 1;

% y(currentSample:currentSample+windowSize-1,:)

a = audioplayer(y(currentSample:currentSample+windowSize-1,:),Fs);
currentSample = currentSample+windowSize;
b = audioplayer(y(currentSample:currentSample+windowSize-1,:),Fs);

updateA = false;
updateB = true;
whichOne = true;

while currentSample + windowSize < totalSamples
%     if whichOne
%         if ~a.isplaying && ~b.isplaying
%             
%         end
%     end
    if ~a.isplaying && ~b.isplaying
        if whichOne
            play(a)
            whichOne = false;
        else
            play(b)
            whichOne = true;
        end
    end
    if a.isplaying && updateB
        b = audioplayer(y(currentSample:currentSample+windowSize-1,:),Fs);
        updateB = false;
        currentSample = currentSample+windowSize;
    elseif b.isplaying && updataA
        b = audioplayer(y(currentSample:currentSample+windowSize-1,:),Fs);
        updateB = false;
        currentSample = currentSample+windowSize;
    end
    disp(currentSample)
end



% my_file_name = 'handel'
hafr = dsp.AudioFileReader();
hap = dsp.AudioPlayer('SampleRate',22050);
while ~isDone(hafr)
   audio = step(hafr);
   step(hap,audio);
end
pause(hap.QueueDuration);  % Wait until audio plays to the end
release(hafr); % close input file, release resources
release(hap);  % close audio output device, release resources



a = dsp

