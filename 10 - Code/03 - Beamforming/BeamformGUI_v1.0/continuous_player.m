classdef continuous_player < handle
    % STD_PROCESSOR Standard processing unit. This file is a template to
    % make a processing unit like a beamformer or a intelligibility measure
    %
    %   BF_DATA(OBJ) create empty file object
    %   BF_DATA(OBJ, SOURCEID) create empty file object and set SourceID
    %   BF_DATA(OBJ, SOURCEID, FILENAME) add file named fileName to object
    %   BF_DATA(OBJ, SOURCEID, FILENAME, LOCATIONS) add file with locations
    %   BF_DATA(OBJ, SOURCEID, FILENAME, LOCATIONS, CHANNAMES) add file with
    %   locations and channel names
    %
    
    % Properties
    properties
        MainObj
        Name          = 'player';
        ChanNames     = {};                 % Channel names
        CurrentSample = 1;                  % Current sample for each channel, can be used to store sample offset
        WindowSize    = 2048;
        FftData       = [];                 % Audio Data matrix size = [TotalSamples NChan]
        Tag           = 'continuous_player';    % Tag to find object
        dspPlayer
%         win = repmat(win,1,Nmics);
    end
    methods
        function obj = continuous_player(mainObj, chanNames)
            if nargin == 0
                obj.MainObj.OutputFile = bf_data;
            elseif nargin >= 1
                obj.MainObj = mainObj;
            end
            if nargin >= 2
%                 obj.ChanNames = obj.MainObj.OutputFile.ChanNames(obj.MainObj.OutputFile.names2inds(chanNames));
                obj.ChanNames = chanNames;
            end
            obj.dspPlayer = dsp.AudioPlayer('SampleRate',obj.MainObj.OutputFile.Fs);
        end
        
        function value = update(obj)
            disp('Update recieved')
            value = 0;
            while obj.CurrentSample + obj.WindowSize*2 <= min(obj.MainObj.OutputFile.CurrentSample(obj.MainObj.OutputFile.names2inds(obj.ChanNames)))
                value = value + 1;
                % Load data from buffer
                dataIn = obj.MainObj.OutputFile.getAudioData(obj.ChanNames,obj.CurrentSample,obj.CurrentSample+obj.WindowSize*2-1);
                
                step(obj.dspPlayer,dataIn);
                obj.CurrentSample = obj.CurrentSample + obj.WindowSize;
            end
        end
    end
end