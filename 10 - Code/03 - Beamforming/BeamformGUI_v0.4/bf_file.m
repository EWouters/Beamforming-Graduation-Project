classdef bf_file < handle
    % BF_FILE Beamformer Audio File
    %
    %   BF_FILE(OBJ) create empty file object
    %   BF_FILE(OBJ, SOURCEID) create empty file object and set SourceID
    %   BF_FILE(OBJ, SOURCEID, FILENAME) add file named fileName to object
    %   BF_FILE(OBJ, SOURCEID, FILENAME, LOCATIONS) add file with locations
    %   BF_FILE(OBJ, SOURCEID, FILENAME, LOCATIONS, CHANNAMES) add file with
    %   locations and channel names
    %
    % BF_FILE Methods:
    %   load            - Load data from audio or matlab file.
    %   save            - Save data to audio or matlab file
    %   play            - Play the data using an audio device.
    %   setNChan        - Set number of channels.
    %   setTotalSamples - Set total number of samples.
    %   addSamples      - Add samples to the data.
    %   setOffset       - Set of channels in samples. TODO
    %   setLocations    - Set Channel Locations.
    %   setChanNames    - Set Channel Names.
    %
    % BF_FILE Properties:
    %   FileName      - Name of the audio file to save including extention
    %   FilePath      - Path of the audio file to save
    %   SourceID      - Identifier for source device or file in use.
    %   Fs            - Sampling Frequency in Hz
    %   BitsPerSample - Number of Bits per audio Sample
    %   NChan         - Number of audio channels in File
    %   Comment       - Comment of audio file
    %   Locations     - Channel locations [x y z az el up]
    %   ChanNames     - Channel names
    %   DelayTimes     - Delay in seconds for each channel
    %   CurrentSample - Current sample for each channel, can be used to
    %                   store sample offset TODO
    %   TotalSamples  - Total length of the audio data in samples
    %   IsInitialized - Has the source been correctly initialized
    %   AudioData     - Audio Data matrix size = [TotalSamples NChan]
    %   Tag           - Tag to find object
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
    %   See also BF_FILE/LOAD, BF_FILE/SAVE, BF_FILE/PLAY, BF_FILE/ADDSAMPLES,
    %   BF_FILE/SETLOCATIONS, BF_FILE/SETCHANNAMES, BF_FILE/SETTOTALSAMPLES, 
    %   BF_FILE/NCHAN, BF_FILE/SETOFFSET, AUDIO_BUFFER, AUDIO_BUFFER/ADDFILE, 
    %   AUDIOREAD, AUDIOWRITE, SAVE, LOAD

    % Properties
    properties
        FileName      = '';          % Name of the audio file to save including extention
        FilePath      = '';          % Path of the audio file to save
        SourceID      = 'Title';     % Identifier for source device or file in use.
        Fs            = 48000;       % Sampling Frequency in Hz
        BitsPerSample = 16;          % Number of Bits per audio Sample
        NChan         = 0;           % Number of audio channels in File
        Comment       = '';          % Comment of audio file
        Locations     = [];          % Channel locations [x y z az el up]'
        ChanNames     = {};          % Channel names
        DelayTimes     = [];          % Delay in seconds for each channel
        CurrentSample = [];          % Current sample for each channel, can be used to store sample offset
        TotalSamples  = 0;           % Total length of the audio data in samples
        IsInitialized = false;       % Has the source been correctly initialized
        AudioData     = [];          % Audio Data matrix size = [TotalSamples NChan]
        Tag           = 'bf_file';   % Tag to find object
    end
    properties (Constant)
        DefaultLoc = [0 0 0 0 pi 0]; % [x y z az el up]
    end
    % Methods
    methods
        
        %------------------------------------------------------------------
        %% Constructor Function
        %------------------------------------------------------------------
        
        function obj = bf_file(sourceID, fileName, locations, chanNames, totalSamples)
            narginchk(0,5)
            if nargin < 1
                obj.SourceID = 'untitled source';
            elseif ischar(sourceID)
                obj.SourceID = sourceID;
            else
                error('bf_file:%s: SourceID argument rejected',obj.SourceID)
            end
            if nargin < 2
                fileName = '';
            elseif ischar(fileName)
                if exist(fileName, 'file') == 2
                    obj.FileName = fileName;
                else
                    error('bf_file:%s: fileName argument rejected, file not found',obj.SourceID)
                end
            end
            if nargin < 3
                obj.setNChan(0);
            elseif isnumeric(locations) && (size(locations,2) == 6 || size(locations,2) == 3)
                obj.setNChan(size(locations,1));
            else
                error('bf_file:%s: Locations argument rejected',obj.SourceID)
            end
            if nargin < 4
                obj.setChanNames;
            else
                obj.setChanNames(chanNames);
            end
            if nargin >= 5
                obj.setTotalSamples(totalSamples);
            end
            
            % Debug
            assignin('base','obj',obj);
        end
        
        %------------------------------------------------------------------
        %% Load Function
        %------------------------------------------------------------------
        
        function obj = load(obj)
            % LOAD Load data from audio or matlab file.
            %
            %   LOAD(OBJ) Load file
            
            % Get file name if empty
            if isempty([obj.FileName obj.FilePath])
                [name1,path1] = uigetfile(...
                    {'*.mat','MAT-files (*.mat)';...
                    '*.wav','Waveform Audio File Format (*.wav)';...
                    '*.*',  'All Files (*.*)'},...
                    'Save File',fullfile(pwd, '\files'));
                if ~ischar(name1) || ~ischar(path1)
                    warning('bf_file:%s:load: Invalid file selected',obj.SourceID)
                    return
                else
                    obj.FileName = name1;
                    obj.FilePath = path1;
                end
            end
            % Load file
            if ~isempty([obj.FilePath obj.FileName])
                if isempty(strfind(obj.FileName,'.mat'))
                    [obj.AudioData, obj.Fs] = audioread(fullfile(obj.FilePath,obj.FileName));
                    info = audioinfo(fullfile(obj.FilePath,obj.FileName));
                    obj.BitsPerSample = info.BitsPerSample;
                    obj.Fs = info.SampleRate;
                    obj.setNChan(info.NumChannels);
                    obj.setTotalSamples(info.TotalSamples);
                    if ischar(info.Title)
                        obj.SourceID = info.Title;
                    end
                    if ischar(info.Comment)
                        obj.Comment = info.Comment;
                    end
                    locs = [];
                    if ~isempty(info.Comment)
                        locs = str2num(info.Comment); %#ok<ST2NM>
                    end
                    if ~isempty(locs)
                        obj.setLocations(locs);
                    else
                        obj.setLocations(obj.Locations);
                    end
                else
                    load(fullfile(obj.FilePath,obj.FileName));
                    if exist('y','var')
                        obj.AudioData = y;
                        obj.setNChan(size(y,2));
                        obj.setTotalSamples(size(y,1));
                        disp('Samples loaded')
                    else
                        error('bf_file:%s:load: File does not contain ''y'' variable',obj.SourceID)
                    end
                    if exist('Fs','var')
                        obj.Fs = Fs; %#ok<*CPROP>
                    elseif exist('fs','var')
                        obj.Fs = fs;
                    else
                        error('bf_file:%s:load: File does not contain ''Fs'' variable',obj.SourceID)
                    end
                    if exist('BitsPerSample','var')
                        obj.BitsPerSample = BitsPerSample;
                    else
                        obj.BitsPerSample = 16;
                    end
                    if exist('Comment','var')
                        obj.Comment = Comment;
                    elseif isempty(obj.Comment) || ~ischar(obj.Comment)
                        obj.Comment = '';
                    end
                    if exist('SourceID','var')
                        obj.SourceID = SourceID;
                    elseif exist('Title','var')
                        obj.SourceID = Title;
                    elseif isempty(obj.SourceID) || ~ischar(obj.SourceID)
                        obj.SourceID = 'Title';
                    end
                    if exist('Locations','var')
                        obj.setLocations(Locations);
                    end
                    if exist('ChanNames','var')
                        obj.setChanNames(ChanNames);
                    end
                    if exist('DelayTimes','var')
                        obj.setDelayTimes(DelayTimes);
                    end
                    if exist('CurrentSample','var')
                        obj.CurrentSample = CurrentSample;
                    end
                    if exist('TotalSamples','var')
                        obj.setTotalSamples(TotalSamples);
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        %% Save Function
        %------------------------------------------------------------------
        
        function save(obj,y,Fs, locations, chanNames)
            % SAVE Save data to audio or matlab file.
            %
            %   SAVE(OBJ) Save file.
            %   SAVE(OBJ, Y, FS) save file with samples y and sample rate Fs
            %   SAVE(OBJ, Y, FS, LOCATIONS) add file with samples y, 
            %   sample rate Fs and locations
            %   SAVE(OBJ, Y, FS, LOCATIONS, CHANNAMES) add file with 
            %   samples y, sample rate Fs, locations and channel names
            %
            % SAVE Arguments:
            %   y         - Matrix of samples
            %   Fs        - Sampling Frequency in Hz
            %   locations - Channel locations [x y z az el up]
            %   chanNames - Channel names cellstr
            narginchk(1,5)
            if nargin >= 3
                obj.AudioData = y;  % Store audio data in object
                obj.Fs = Fs;
                obj.setNChan(size(y,2));
                obj.setTotalSamples(size(y,1));
                obj.CurrentSample = 0;
                obj.IsInitialized = true;
            elseif obj.IsInitialized
                y = obj.AudioData;  % Load samples from object
                Fs = obj.Fs;
            else
                error(['bf_file:%s:save:NotInitialized: ',...
                    'The file could not be saved because the object was',...
                    ' not initialized.'],obj.SourceID);
            end
            if nargin >= 4
                obj.setLocations(locations);
            end
            if nargin >= 5
                obj.setLocations(chanNames);
            end
            % Get file name if empty
            if isempty([obj.FileName obj.FilePath])
                [name1,path1] = uiputfile(...
                    {'*.wav','Waveform Audio File Format (*.wav)';...
                    '*.mat','MAT-files (*.mat)';...
                    '*.*',  'All Files (*.*)'},...
                    'Save File',fullfile(pwd, '\files', sprintf('Recording %s',datestr(now, 'yyyy-mm-dd hhuMM'))));
                if ~ischar(name1) || ~ischar(path1)
                    warning('bf_file:%s:save: Invalid file selected',obj.SourceID)
                    return
                else
                    obj.FileName = name1;
                    obj.FilePath = path1;
                end
            end
            obj.Comment = mat2str(obj.Locations);
            % Write to file
            if isempty(strfind(obj.FileName,'.mat'))
                % Save as audio file
                audiowrite(fullfile(obj.FilePath,obj.FileName),y,Fs,...
                    'BitsPerSample',obj.BitsPerSample,'Comment',obj.Comment,...
                    'Title',obj.SourceID,'Artist','TU Delft Beamforming BSc Graduation Project EE');
            else
                % Save as mat file
                BitsPerSample = obj.BitsPerSample; %#ok<*PROP,*NASGU>
                NChan         = obj.NChan;
                SourceID      = obj.SourceID;
                Comment       = obj.Comment;
                Locations     = obj.Locations;
                ChanNames     = obj.ChanNames;
                DelayTimes     = obj.DelayTimes;
                CurrentSample = obj.CurrentSample;
                TotalSamples  = obj.TotalSamples;
                save(fullfile(obj.FilePath,obj.FileName),'y','Fs','BitsPerSample','NChan',...
                    'Comment','Locations','ChanNames','DelayTimes','CurrentSample','TotalSamples');
            end
        end
        
        %----------------------------------------------------------------------
        %% Play Function
        %----------------------------------------------------------------------
        
        function player = play(obj, deviceID, firstSample, lastSample)
            % PLAY Play the data using an audio device.
            %
            %   PLAY(OBJ) Play audio on default device.
            %   PLAY(OBJ, DEVICEID) Play audio specified device.
            %   PLAY(OBJ, DEVICEID, FIRSTSAMPLE, LASTSAMPLE) Play part of 
            %   audio on specified device.
            %   player = PLAY(obj,___) Returns audioplayer object.
            narginchk(1,4)
            if nargin < 2
                info1 = audiodevinfo;
                deviceID = info1.output(1).ID;
            end
            if nargin < 4
                firstSample = 1;
                lastSample = obj.TotalSamples;
            elseif isscalar(firstSample) && isscalar(lastSample)
                if firstSample > lastSample || lastSample > obj.TotalSamples
                    warning(['bf_file:%s:play: Cannot play from %i to %i. Total',...
                        'samples is %i'], obj.SourceID, firstSample, lastSample, obj.TotalSamples)
                    firstSample = 1;
                    lastSample = obj.TotalSamples;
                end
            else
                firstSample = 1;
                lastSample = obj.TotalSamples;
            end
            % Play signal
            if obj.IsInitialized
                if obj.NChan <= 2
                    player = audioplayer(obj.AudioData,obj.Fs, obj.BitsPerSample, deviceID);
                else
                    player = audioplayer(mean(obj.AudioData,2),obj.Fs, obj.BitsPerSample, deviceID);
                end
                play(player);
            else
                warning('bf_file:%s:play: Object is not initialized',obj.SourceID)
            end
        end
        
        %------------------------------------------------------------------
        %% AudioData Functions
        %------------------------------------------------------------------
        
        % Set Number of Channels function
        function obj = setNChan(obj, nChan)
            % SETNCHAN Set number of Channels.
            %
            %   SETNCHAN(OBJ, NCHAN) Set the number of channels to object. 
            %   Makes sure size of AudioData, locations and chanNames are correct.
            %
            %   nChan must be a non-negative scalar.
            if isscalar(nChan) && nChan >= 0
                obj.NChan = nChan;
            else
                error('bf_file:%s:setNChan: nChan argument rejected',obj.SourceID)
            end
            % Check dependent variables
            obj.checkAudioData;
            obj.checkLocations;
            obj.checkChanNames;
            if obj.NChan
                obj.IsInitialized = true;
            else
                obj.IsInitialized = false;
            end
        end
        
        % Set Total Samples function
        function obj = setTotalSamples(obj, totalSamples)
            % SETTOTALSAMPLES Set total number of samples.
            %
            %   SETTOTALSAMPLES(OBJ, TOTALSAMPLES) Set Total Samples value
            %   to object. Makes sure size of AudioData is correct.
            %
            %   totalSamples must be a non-negative scalar.
            if isscalar(totalSamples) && totalSamples >= 0
                obj.TotalSamples = totalSamples;
            else
                error('bf_file:%s:setTotalSamples: totalSamples argument rejected',obj.SourceID)
            end
            obj.checkAudioData;
        end
        
        %------------------------------------------------------------------
        %% Names and Locations Functions
        %------------------------------------------------------------------
        
        % Set Locations function
        function obj = setLocations(obj, locations, chanNames)
            % SETLOCATIONS Set Channel Locations.
            %
            %   SETLOCATIONS(OBJ) Set Locations of channels to defaults.
            %   SETLOCATIONS(OBJ, LOCATIONS) Set Locations of channels.
            %   SETLOCATIONS(OBJ, LOCATIONS, CHANNAMES) Set Locations
            %   specific channels.
            %
            %   Locations must be a NChan by 3 or NChan by 6 numeric array
            narginchk(1,3)
            if nargin == 1
                obj.Locations = repmat(obj.DefaultLoc,obj.NChan,1);
            elseif isnumeric(locations) && size(locations,2) ==  6
                obj.Locations = locations;
            elseif isnumeric(locations) && size(locations,2) ==  3
                obj.Locations = [locations, repmat(obj.DefaultLoc(4:6),size(locations,1),1)];
            elseif ~isempty(obj.Locations)
                warning('bf_file:setLocations:%s: Locations argument rejected',obj.SourceID)
            end
            if nargin >= 3
                channelInds = obj.names2inds(chanNames);
                if length(channelInds) == length(locations)
                    obj.Locations(channelInds) = locations;
                else
                    warning('bf_file:%s:setLocations: Channel locations could not be replaced',obj.SourceID)
                end
            end
            obj.checkLocations;
        end
        % Check Locations function
        function obj = checkLocations(obj)
            % CHECKLOCATIONS Check Channel Locations and add or remove 
            % incorrect ones.
            if isempty(obj.Locations)
                obj.Locations = repmat(obj.DefaultLoc,obj.NChan,1);
            elseif size(obj.Locations,1) < obj.NChan
                locs = repmat(obj.DefaultLoc,obj.NChan,1);
                locs(1:size(obj.Locations,1),:) = obj.Locations;
                obj.Locations = locs;
%                 warning('bf_file:%s:checkLocations: Locations argument too short',obj.SourceID)
            elseif size(obj.Locations,1) > obj.NChan
                obj.Locations = obj.Locations(1:obj.NChan,:);
%                 warning('bf_file:%s:checkLocations: Locations argument too long',obj.SourceID)
            else
%                 fprintf('bf_file:%s:checkLocations: Locations set correctly\n',obj.SourceID)
%                 disp(obj.Locations)
            end
        end
        
        % Set Channel Names function
        function obj = setChanNames(obj, varargin)
            % SETCHANNAMES Set Channel Names.
            %
            %   SETCHANNAMES(OBJ) Set Channel Names to defaults.
            %   SETCHANNAMES(OBJ, CHANNAMES) Set Channel Names of source.
            %   SETCHANNAMES(OBJ, OLDNAMES, NEWNAMES) Replace channel names.
            %
            %   ChanNames must be a cellstr with NChan names.
            %   OldNames must be a cellstr with existing names.
            %   NewNames must be a cellstr with the new names.
            narginchk(1,3)
            if nargin == 1
                for ii = 1:obj.NChan
                    obj.ChanNames{ii} = sprintf('Ch %i',ii);
                end
            elseif nargin == 2
                if iscellstr(varargin{1})
                    obj.ChanNames = varargin{1};
                end
            elseif nargin >= 3
                assignin('base','varargin',varargin)
                if ischar(varargin{2})
                    varargin{2} = {varargin{2}}; %#ok<CCAT1>
                end
                channelInds = obj.names2inds(varargin{1});
%                 if length(channelInds) == 1 && length(varargin{2}) == 1
%                     obj.ChanNames{channelInds} = varargin{2}{:};
%                 else
                if length(channelInds) == length(varargin{2})
                    obj.ChanNames(channelInds) = varargin{2};
                else
                    warning(['bf_file:%s:setChanNames: Channel names ',...
                        'could not be replaced because the number of ',...
                        'the old and the new channel names disagree.'],obj.SourceID)
                end
            end
            obj.checkChanNames;
        end
        % Check Channel Names function
        function obj = checkChanNames(obj)
            % CHECKCHANNAMES Check Channel Names and add or remove 
            % incorrect ones.
            if isempty(obj.ChanNames)
                for ii = 1:obj.NChan
                    obj.ChanNames{ii} = sprintf('Ch %i',ii);
                end
            elseif length(obj.ChanNames) < obj.NChan
                for ii = length(obj.ChanNames)+1:obj.NChan
                    obj.ChanNames{ii} = sprintf('Ch %i',ii);
                end
%                 warning('bf_file:%s:checkChanNames: ChanNames argument has too few names',obj.SourceID)
            elseif length(obj.ChanNames) > obj.NChan
                obj.ChanNames = obj.ChanNames(1:obj.NChan);
%                 warning('bf_file:%s:checkChanNames: ChanNames argument has too many names',obj.SourceID)
            else
%                 fprintf('bf_file:%s:checkChanNames: Names set correctly\n',obj.SourceID)
%                 disp(obj.ChanNames)
            end
        end
        
        
        % Set Delay Time function
        function obj = setDelayTimes(obj, varargin)
            % SETDELAYTIME Set Delay Time.
            %
            %   SETDELAYTIME(OBJ) Set Delay Time to defaults.
            %   SETDELAYTIME(OBJ, CHANNAMES) Set Delay Time of source.
            %   SETDELAYTIME(OBJ, OLDNAMES, NEWNAMES) Replace channel names.
            %
            %   DelayTimes must be a cellstr with NChan names.
            %   OldNames must be a cellstr with existing names.
            %   NewNames must be a cellstr with the new names.
            narginchk(1,3)
            if nargin == 1
                for ii = 1:obj.NChan
                    obj.ChanNames{ii} = sprintf('Ch %i',ii);
                end
            elseif nargin == 2
                if iscellstr(varargin{1})
                    obj.ChanNames = varargin{1};
                end
            elseif nargin >= 3
                assignin('base','varargin',varargin)
                if ischar(varargin{2})
                    varargin{2} = {varargin{2}}; %#ok<CCAT1>
                end
                channelInds = obj.names2inds(varargin{1});
%                 if length(channelInds) == 1 && length(varargin{2}) == 1
%                     obj.ChanNames{channelInds} = varargin{2}{:};
%                 else
                if length(channelInds) == length(varargin{2})
                    obj.ChanNames(channelInds) = varargin{2};
                else
                    warning(['bf_file:%s:setChanNames: Channel names ',...
                        'could not be replaced because the number of ',...
                        'the old and the new channel names disagree.'],obj.SourceID)
                end
            end
            obj.delayData;
        end
        
        %------------------------------------------------------------------
        %% Audio Data Functions
        %------------------------------------------------------------------
        
        % Check Audio Data function
        function obj = checkAudioData(obj)
            % CHECKAUDIODATA Check Audio Data and add or remove 
            % incorrect streams.
            
            % Check number of Channels
            nChanDifference = obj.NChan - size(obj.AudioData,2);
            if isempty(obj.AudioData)
                obj.AudioData = zeros(obj.TotalSamples,obj.NChan,obj.audioDataType); % Create empty audio data
            elseif nChanDifference > 0
                obj.AudioData(:,end+1:end+nChanDifference) = zeros(obj.TotalSamples,nChanDifference,obj.audioDataType); % Add extra channels (zeros)
            elseif nChanDifference < 0
                obj.AudioData(:,obj.NChan+1:end) = []; % Remove extra channels
            end
            % Check number of Samples
            totalSamplesDifference = obj.TotalSamples - length(obj.AudioData);
            if isempty(obj.AudioData)
                obj.AudioData = zeros(obj.TotalSamples,obj.NChan,obj.audioDataType); % Create empty audio data
            elseif totalSamplesDifference > 0
                obj.AudioData(end+1:end+totalSamplesDifference,:) = zeros(totalSamplesDifference,obj.NChan,obj.audioDataType); % Add extra samples (zeros)
            elseif totalSamplesDifference < 0
                obj.AudioData(obj.TotalSamples+1:end,:) = []; % Remove extra samples
            end
        end
        
        % Add Samples function
        function obj = addSamples(obj,y, varargin)
            % ADDSAMPLES Add samples to the data.
            %
            %   ADDSAMPLES(OBJ, Y) Add samples at end of data.
            %   ADDSAMPLES(OBJ, Y, SAMPLEINDS) Add samples at index or indices.
            %   ADDSAMPLES(OBJ, Y, CHANNAMES) Add data to specified
            %   channels.
            %   ADDSAMPLES(OBJ, Y, CHANNAMES, ADDNEW) add data to specified
            %   channels and create channels if they are not matched and
            %   addNew is true.
            %   ADDSAMPLES(OBJ, Y, CHANNAMES, ADDNEW, SAMPLEINDS) add 
            %   data to specified channels at index or indices and create 
            %   channels if they are not matched and addNew is true.
            narginchk(2,5)
            if ~obj.IsInitialized
                error('bf_file:%s:addSamples: Cannot add samples when object is not initialized',obj.SourceID)
            end
            sampleInds = ones(1,size(y,2));
            channelInds = 1:obj.NChan;
            if nargin >= 3
                if isnumeric(varargin{1})
                    if length(varargin{1}) == 1 || length(varargin{1}) == obj.NChan
                        sampleInds = varargin{1};
                    else
                        error('bf_file:%s:addSamples: Third argument rejected, expected SampleInds',obj.SourceID)
                    end
                elseif ischar(varargin{1}) || iscellstr(varargin{1})
                    if nargin < 4
                        addNew = false;
                    else
                        addNew = varargin{2};
                    end
                    channelInds = obj.names2inds(varargin{1}, addNew);
                else
                    error('bf_file:%s:addSamples: Third argument rejected, expected ChanNames',obj.SourceID)
                end
            end
            if nargin >= 5
                if isnumeric(varargin{3})
                    if length(varargin{3}) == 1 || length(varargin{3}) == length(channelInds)
                        sampleInds = varargin{3};
                    else
                        error('bf_file:%s:addSamples: SampleInds has wrong number of elements',obj.SourceID)
                    end
                else
                    error('bf_file:%s:addSamples: Fifth argument rejected, expected SampleInds',obj.SourceID)
                end
            end
            nSamples = size(y,1);
            if obj.TotalSamples < max(sampleInds)+nSamples-1
                obj.setTotalSamples(max(sampleInds)+nSamples-1);
            end
            if size(y,2) == length(channelInds)
                if length(sampleInds) == 1
                    obj.AudioData(sampleInds:sampleInds+nSamples-1,channelInds) = y; % Add y to AudioData at correct channel and correct index
                else
                    for ii = 1:length(sampleInds)
                        obj.AudioData(sampleInds(ii):sampleInds(ii)+nSamples-1,channelInds(ii)) = y(:,ii); % Add y to AudioData at correct channel and correct indices
                    end
                end
            else
                error('bf_file:%s:addSamples: size of y does not correspond to other inputs',obj.SourceID)
            end
        end
        
        % Get Audio Data function
        function y = getaudiodata(obj,varargin)
            % GETAUDIODATA Gets Audio Data.
            %
            %   y = GETAUDIODATA(OBJ) Returns all audiodata
            %   y = GETAUDIODATA(OBJ, CHANNAMES) Returns auiodata for
            %   specified channels
            %   y = GETAUDIODATA(OBJ, FIRSTSAMPLE, LASTSAMPLE) Returns 
            %   audiodata in range for specified channels
            %   y = GETAUDIODATA(OBJ, CHANNAMES, FIRSTSAMPLE, LASTSAMPLE)
            %   Returns audiodata in range for specified channels
            narginchk(1,4)
            if obj.IsInitialized
                if nargin == 1
                    y = obj.AudioData;
                elseif nargin == 2
                    y = obj.AudioData(:,obj.names2inds(varargin{1}));
                elseif nargin == 3
                    if isscalar(varargin{2}) && isscalar(varargin{3}) && ...
                            varargin{2} > 0 && varargin{3} <= obj.TotalSamples && ...
                            varargin{2} >= varargin{3}
                        y = obj.AudioData(varargin{2:3},:);
                    else
                        error('bf_file:%s:getaudiodata: Invalid call to y = GETAUDIODATA(OBJ, FIRSTSAMPLE, LASTSAMPLE)',obj.SourceID)
                    end
                elseif nargin == 4
                    if isscalar(varargin{3}) && isscalar(varargin{4}) && ...
                            varargin{3} > 0 && varargin{4} <= obj.TotalSamples && ...
                            varargin{3} >= varargin{4}
                        y = obj.AudioData(varargin{3:4},obj.names2inds(varargin{2}));
                    else
                        error('bf_file:%s:getaudiodata: Invalid call to y = GETAUDIODATA(OBJ, CHANNAMES, FIRSTSAMPLE, LASTSAMPLE)',obj.SourceID)
                    end
                end
            else
                error('bf_file:%s:getaudiodata: Object is not initialized',obj.SourceID)
            end
                
%             outType = class(y);
%             convertMethod = strcmp(oldType,{'double','int16','uint8'});
%             if convertMethod(2)
%                 y = audiovideo.internal.audio.Converter.('toInt16')(y);
%             elseif convertMethod(3)
%                 y = audiovideo.internal.audio.Converter.('toUint8')(y);
%             elseif ~convertMethod(1)
%                 y = cast(y,outType);
%             end
        end
        
        % Resample function
        function y = resampleData(obj, varargin)
            % RESAMPLEDATA find indices in audiodata of list of channel names.
            %
            %   RESAMPLEDATA(OBJ, FS) Resample all channels to sample rate fs [Hz].
            %   y = RESAMPLEDATA(OBJ, Y, FSNEW, FSOLD) resample y and
            %   return the new samples
            %   RESAMPLEDATA(OBJ, FSNEW, FSOLD, CHANNAMES) Resample the
            %   channels corresponding to the list of names in chanNames
            %   RESAMPLEDATA(OBJ, FSNEW, FSOLD, CHANNAMES, n, beta) 
            %   Resample the channels corresponding to the list of names in
            %   chanNames and passes the extra arguments to the resample
            %   function from matlab
            %   
            %   If fs is a vector of length NChan the sample rate is
            %   set to each channel individually.
            %
            %   fs has units per second [Hz]
            %
            %   Resample using a polyphase filter TODO: add reference to
            %   paper about polyphase filter
            %
            %   resample performs a FIR design using firls, followed by 
            %   rate changing implemented with upfirdn.
            %
            %   See also BF_FILE/DELAYDATA, RESAMPLE, TIMESERIES, FIRLS,
            %   UPFIRDN
            narginchk(2,Inf)
            if nargin == 2                      % RESAMPLEDATA(OBJ, FS)
                nChan = obj.NChan;
                saveInObj = true;
                if isnumeric(varargin{1}) && (length(varargin{1}) == 1 || length(varargin{1}) == nChan)
                    y = obj.AudioData;          % Get audio data from object
                    fsNew = varargin{1};        % Get new sample rate from input argument
                    fsOld = obj.Fs;             % Get old sample rate from object
                else
                    error('bf_file:%s:resampleData: First argument needs to be sample rate when using one argument',obj.SourceID)
                end
            elseif nargin >= 4
                if isnumeric(varargin{3})       % RESAMPLEDATA(OBJ, Y, FSNEW, FSOLD)
                    nChan = size(varargin{1},2);
                    saveInObj = false;
                    if isnumeric(varargin{1}) && isnumeric(varargin{2}) && ...
                            (length(varargin{2}) == 1 || length(varargin{2}) == nChan) && ...
                            (length(varargin{3}) == 1 || length(varargin{3}) == nChan)
                        y = varargin{1};        % Get audio data from input argument
                        fsNew = varargin{2};    % Get new sample rate from input argument
                        fsOld = varargin{3};    % Get old sample rate from input argument
                    else
                        error('bf_file:%s:resampleData: Some arguments were rejected in call RESAMPLEDATA(OBJ, Y, FSNEW, FSOLD)',obj.SourceID)
                    end
                else                            % RESAMPLEDATA(OBJ, FSNEW, FSOLD, CHANNAMES)
                    nChan = length(chanNames);
                    saveInObj = true;
                    if isnumeric(varargin{1}) && isnumeric(varargin{2}) && ...
                            (ischar(varargin{3}) || iscellstr(varargin{3})) && ...
                            (length(varargin{1}) == 1 || length(varargin{1}) == nChan) && ...
                            (length(varargin{2}) == 1 || length(varargin{2}) == nChan)
                        y = obj.AudioData(names2inds(varargin{3})); % Get audio data corresponding to channel names from object
                        fsNew = varargin{1};    % Get new sample rate from input argument
                        fsOld = varargin{2};    % Get old sample rate from input argument
                    else
                        error('bf_file:%s:resampleData: Some arguments were rejected in call RESAMPLEDATA(OBJ, FSNEW, FSOLD, CHANNAMES)',obj.SourceID)
                    end
                end
            else
                error('bf_file:%s:resampleData: Function does not support using 2 arguments',obj.SourceID)
            end
            
            % Convert audio data to double and save original type because
            % resampling is done with double precision
            oldType = class(y);
            convertMethod = strcmp(oldType,{'double','int16','uint8'});
            if ~convertMethod(1)
                y = audiovideo.internal.audio.Converter.('toDouble')(y);
    %             y = cast(y,'double'); is slower and less reliable
            end
            
            % Do resampling using matlab resample function. Extra arguments are passed to resample function
            if length(fsNew) == 1 && length(fsOld) == 1
                y = resample(y,fsNew,fsOld, varargin{4:end}); % resample matrix
            else
                if length(fsNew) == 1
                    fsNew = repmat(fsNew,1,nChan);
                end
                if length(fsOld) == 1
                    fsOld = repmat(fsOld,1,nChan);
                end
                for ii = 1:nChan
                    y(:,ii) = resample(y(:,ii),fsNew(ii),fsOld(ii), varargin{4:end}); % resample channels one by one
                end
            end
            
            % Convert data back to original data type
            if convertMethod(2)
                y = audiovideo.internal.audio.Converter.('toInt16')(y);
            elseif convertMethod(3)
                y = audiovideo.internal.audio.Converter.('toUint8')(y);
            elseif ~convertMethod(1)
                y = cast(y,oldType);
            end
            
            % Save result
            if saveInObj
                obj.AudioData = y;
                obj.setTotalSamples(size(y,1));
                if length(fsNew) == 1
                    obj.Fs = fsNew;
                else
                    warning('bf_file:%s:resampleData: New sample rates can not be saved in object when using a vector argument for fsNew',obj.SourceID)
                end
            end
        end
        
        % Delay Data in Time function
        function y = delayData(obj, y, delayTimes)
            % DELAYDATA Set Channel Delay Time in seconds for each channel.
            %
            %   DELAYDATA(OBJ) Set Delay of channels into value(s)
            %   specified in obj.DelayTimes
            %   DELAYDATA(OBJ, DELAYTIME) Delay all channels by the
            %   number of seconds specified in delayTimes
            %   DELAYDATA(OBJ, DELAYTIME, CHANNAMES) Delay the channels
            %   corresponding to the list of names in chanNames
            %   
            %   If delayTimes is a vector of length NChan the sample rate is
            %   set to each channel individually.
            %
            %   delayTimes has units seconds [s]
            %
            %   Currently the delayTime is rounded off to the nearest whole
            %   sample
            %
            %   See also BF_FILE/RESAMPLEDATA, RESAMPLE, TIMESERIES
            narginchk(3,3)
            
            numberOfSamplesDelay = round(delayTimes.*obj.Fs);
            extraSampleLength = - min(numberOfSamplesDelay) + max(numberOfSamplesDelay);
            numberOfSamplesDelay = numberOfSamplesDelay - min(numberOfSamplesDelay);
            nChan = size(y,2);
            if length(numberOfSamplesDelay) == 1
                numberOfSamplesDelay = repmat(numberOfSamplesDelay,1,nChan);
            elseif length(numberOfSamplesDelay) ~= nChan
                error('bf_file:%s:delayData: delayTimes should have length 1 or length nChan',obj.SourceID)
            end
            
            y = [y; zeros(extraSampleLength,nChan)];
            for ii = 1:nChan
                y(:,ii) = [zeros(numberOfSamplesDelay(ii),1); y(:,ii); zeros(extraSampleLength-numberOfSamplesDelay(ii),1)];
            end
        end
        
        %------------------------------------------------------------------
        % Helper Functions
        %------------------------------------------------------------------
    
        
        % Names to indices function
        function channelInds = names2inds(obj, chanNames, addNew)
            % NAMES2INDS find indices in audiodata of list of channel names.
            %
            %   chanInds = NAMES2INDS(OBJ, CHANNAMES) returns indices in
            %   AudioData for string or cellstring of channel names
            %   chanInds = NAMES2INDS(OBJ, CHANNAMES, ADDNEW) Add
            %   unrecognized channel names to AudioData
            %
            %   chanNames - string or cellstring of channel names
            %   addNew    - if true unrecognized channels will be added
            %
            % Example:
            %   channelInds = names2inds(chanNames);
            %   y = obj.AudioData(channelInds);
            % 
            narginchk(2,3)
            if nargin < 3
                addNew = false;
            elseif addNew
                addNew = true;
            else
                addNew = false;
            end
            if ischar(chanNames)
                chanNames = {chanNames};
            end
            channelInds = zeros(size(chanNames));
            if iscellstr(chanNames)
                for ii = 1:length(chanNames)
                    res = strcmp(chanNames{ii},obj.ChanNames);
                    if sum(res) == 1
                        channelInds(ii) = find(res~=0, 1, 'first');
                    elseif addNew && sum(res) == 0
                        obj.setNChan(obj.NChan+1);
                        obj.ChanNames{end} = chanNames{ii};
                        channelInds(ii) = obj.NChan;
                    else
                        error('bf_file:%s:names2inds: Channel Name not recognized: %s',obj.SourceID,chanNames{ii})
                    end
                end
            else
                error('bf_file:%s:names2inds: chanNames argument should be a string or a cellstring',obj.SourceID)
            end
            if length(unique(channelInds)) ~= length(channelInds)
                error('bf_file:%s:names2inds: chanNames contains non-unique channels',obj.SourceID)
            end
        end
        
        % Audio Data Type function
        function value = audioDataType(obj)
            % 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'
            switch obj.BitsPerSample
                case 8
                    value = 'uint8';
                case 16
                    value = 'int16';
                otherwise
                    value = 'double';
            end                    
        end
        
    end
end