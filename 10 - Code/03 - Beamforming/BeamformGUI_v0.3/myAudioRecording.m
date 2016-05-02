% Function that records sound from the microphone at a specified sampling
% rate for a fixed number of seconds
%
% Fs           - the sampling rate (Hz)
% durationSecs - the (optional) duration of the recording (seconds)
% N            - the (optional) FFT N-point block size
function [recorder] = myAudioRecording(Fs,durationSecs,N)

    if ~exist('durationSecs','var')
        % default to five minutes of recording
        durationSecs = 300;
    end
    
    if ~exist('N','var')
        % default to the sampling rate
        N = Fs;
    end
    
    % add an extra half-second so that we get the full duration in our
    % processing
    durationSecs = durationSecs + 0.5;
    
    % index of the last sample obtained from our recording
    lastSampleIdx = 0;
    
    % start time of the recording
    atTimSecs     = 0;
    
    % create the audio recorder
    recorder = audiorecorder(Fs,8,1);
    
    % assign a timer function to the recorder
    set(recorder,'TimerPeriod',1,'TimerFcn',@audioTimerCallback);
    
    % create a figure with two subplots
    hFig   = figure;
    hAxes1 = subplot(2,1,1);
    hAxes2 = subplot(2,1,2);
    
    % create the graphics handles to the data that will be plotted on each
    % axes
    hPlot1 = plot(hAxes1,NaN,NaN);
    hPlot2 = plot(hAxes2,NaN,NaN);
    
    drawnow;
    
    % start the recording
    record(recorder,durationSecs);
    
    % define the timer callback
    function audioTimerCallback(hObject,~)
        
        % get the sample data
        samples  = getaudiodata(hObject);
        
        % skip if not enough data
        if length(samples)<lastSampleIdx+1+Fs
            return;
        end
        
        % extract the samples that we have not performed an FFT on
        X = samples(lastSampleIdx+1:lastSampleIdx+Fs);
        
        % compute the FFT
        Y = fft(X,N);
        
        % plot the data
        t = linspace(0,1-1/Fs,Fs) + atTimSecs;
        set(hPlot1,'XData',t,'YData',X);
        
        f = 0:Fs/N:(Fs/N)*(N-1);
        set(hPlot2,'XData',f,'YData',abs(Y));
         
        % increment the last sample index
        lastSampleIdx = lastSampleIdx + Fs;
        
        % increment the time in seconds "counter"
        atTimSecs     = atTimSecs + 1; 
    end

    % do not exit function until the figure has been deleted
    waitfor(hFig);
end