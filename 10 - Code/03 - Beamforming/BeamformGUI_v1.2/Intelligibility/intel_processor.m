classdef intel_processor < handle
    % SNR_PROCESSOR Standard processing object. This file is a template to
    % make a processing object like a beamformer or an intelligibility measure
    %
    %   SNR_PROCESSOR() create processing object
    %   SNR_PROCESSOR(MAINOBJ) create processing object with handle to main object
    %
    % SNR_PROCESSOR Methods:
    %   update  - Function to get a data window and call process function if
    %   there is data available to process
    %   process - Function where processing is done
    %
    % SNR_PROCESSOR Properties:
    %   MainObj       - Handle of main object
    %   Name          - Name of Processor
    %   ChanNames     - Channel names
    %   CurrentSample - Current sample
    %   WindowSize    - Size of window to process, twice this length is
    %   taken and multiplied by the window
    %   FftData       - Fft Data matrix
    %   Tag           - Tag to find object
    %   Win           - Window to use on audio signal standard the sqrt(hanning(2*WindowSize)) is used
    %
    %   Written for the BSc graduation project Acoustic Enhancement via
    %   Beamforming Using Smartphones.
    %
    %   Team:       S. Bosma                R. Brinkman
    %               T. de Rooij             R. Smeding
    %               N. van Wijngaarden      E. Wouters
    %
    %   Supervisor: Jorge Martínez Castañeda
    %
    %   Contact: E.H.Wouters@student.tudelft.nl
    %
    %   See also SNR_PROCESSOR, MAIN_WINDOW
    
    %% Properties
    properties
        MainObj                           % Handle of main object
        Name           = 'Intel Processor'; % Name of Processor
        ChanNameClean  = {};              % Channel names
        ChanNamesNoisy = {};              % Channel names
        CurrentSample  = 1;               % Current sample
        WindowSize     = 2048;            % Size of window to process, twice this length is taken and multiplied by the window
        Fseval = 16000;
        Stoi
        Pesq
        MicNames
        SourceNames
        x_m
        x_s
        IsInitialized
        Tag            = 'intel_processor'; % Tag to find object
    end
    methods
        function obj = intel_processor(mainObj)
            if nargin == 0
                obj.MainObj.DataBuffer = bf_data(obj.MainObj);
                obj.MainObj.UI.PlotSettings = std_selector_ui(figure,obj.MainObj);
                obj.MainObj.DataBuffer.setNChan(1);
                obj.MainObj.DataBuffer.setTotalSamples(48000);
                obj.MainObj.IntelProcessor.SigalignOpt = 'gp';
                help snr_processor
            elseif nargin >= 1
                obj.MainObj = mainObj;
            end
        end
        
        function obj = Initialize(obj)
            obj.MainObj.UI.IntelChannels.Update();
            fs = obj.MainObj.DataBuffer.Fs;
            fseval=obj.Fseval;
            
            chanNames = obj.MainObj.UI.IntelChannels.ChanNames;
            
            typeStr = {'Mic','Source','Noise'};
            micNames = [];
            sourceNames = [];
            noiseNames = [];
            for ii = 1:length(chanNames)
                if ~isempty(strfind(chanNames{ii},':')) || ...
                        ~isempty(strfind(chanNames{ii},'Mic')) || ...
                        ~isempty(strfind(chanNames{ii},'Beamformer'))
                    micNames = [micNames ii];
                elseif strfind(chanNames{ii},'Source')
                    sourceNames = [sourceNames ii];
                elseif strfind(chanNames{ii},'Noise')
                    noiseNames = [noiseNames ii];
                end
            end
            obj.MicNames = chanNames(micNames);
            obj.SourceNames = chanNames(sourceNames);
            noiseNames = chanNames(noiseNames);
            
            if isempty(obj.MicNames)
                warning('No mics')
                obj.IsInitialized = 0;
                return;
            end
            if isempty(obj.SourceNames)
                warning('No sources')
                obj.IsInitialized = 0;
                return;
            end
            
            obj.x_m = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),1:3);
            obj.x_s = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);
            
            obj.IsInitialized = 1;
            
            s = obj.MainObj.DataBuffer.getAudioData(obj.MicNames);
            r = obj.MainObj.DataBuffer.getAudioData(obj.SourceNames);
            
            if fs ~= fseval
                r = resample(r,fseval,fs);
                for ii = 1:size(obj.MicNames,2)
                    ssss(:,ii) = resample(s(:,ii),fseval,fs);
                end
                s = ssss;
            end
            sigalignOpt = obj.MainObj.SNRProcessor.SigalignOpt;
            for ii = 1:size(obj.MicNames,2)
                [~,~,rr,ss] = sigalign(s(:,ii),r,1/4,sigalignOpt,fseval);
                Stoi(ii) = stoi(rr,ss,fseval);
                audiowrite([pwd filesep 'files' filesep 'tmp' filesep 'rr.wav'],rr,fseval,'BitsPerSample',16);
                audiowrite([pwd filesep 'files' filesep 'tmp' filesep 'ss.wav'],ss,fseval,'BitsPerSample',16);
                Pesq(ii) = pesq_itu(fseval,[pwd filesep 'files' filesep 'tmp' filesep 'rr.wav'],[pwd filesep 'files' filesep 'tmp' filesep 'ss.wav']);
            end
            
            obj.Stoi = Stoi;
            obj.Pesq = Pesq;
        end
        
    end
end
