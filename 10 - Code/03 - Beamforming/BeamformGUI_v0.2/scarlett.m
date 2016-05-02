classdef scarlett < handle
    %% Focusrite Scarlett 18i20 Interface Class 
    %  This class will interface with the Scarlett USB audio interface
    %% Constants
    properties (Constant)
        Name = 'Scarlett 18i20 USB';
        nChanMax = 18;      % Maximum number of channels
    end
    %% Properties
    properties
        Fs = 48000;         % Sample Frequency
        nChan = 4;          % Number of channels
        RecTime = 10/1000;  % Time to record when calling rec without arguments
        FirstChan = 1;      % ID of first channel (usually 1)
    end
    %% Methods
    methods
        %% Scarlett Constuctor
        function obj = scarlett(Fs,nChan,recTime,firstChan)
            if nargin < 1 || isempty(Fs)
                obj.Fs = 48000;
            else
                obj.Fs = Fs;
            end
            if nargin < 2 || isempty(nChan) || nChan > obj.nChanMax
                obj.nChan = 4;
            else
                obj.nChan = nChan;
            end
            if nargin < 3 || isempty(recTime)
                obj.RecTime = 10/1000;
            else
                obj.RecTime = recTime;
            end
            if nargin < 4 || isempty(firstChan) || firstChan+obj.nChan > obj.nChanMax
                obj.FirstChan = 1;
            else
                obj.FirstChan = firstChan;
            end
        end
        %% Record all channels obj.RecTime seconds
        function r = rec(obj,recTime)
            if nargin > 1 
                if ~isempty(recTime)
                    obj.RecTime = recTime;
                end
            end
            r = pa_wavrecord(obj.FirstChan, obj.FirstChan+obj.nChan-1, round(obj.Fs*obj.RecTime));
        end
        %% Plot recording
        function plot(obj,r)
            figure;
            x = (1:size(r,1))/obj.Fs;
            legStr = {'Ch 1'};
            plot(x,r(:,1));
            hold on
            for ii = 2:size(r,2)
                plot(x,r(:,ii));
                legStr{end+1} = sprintf('Ch %d',ii); %#ok<AGROW>
            end
            legend(legStr);
        end
    end
end