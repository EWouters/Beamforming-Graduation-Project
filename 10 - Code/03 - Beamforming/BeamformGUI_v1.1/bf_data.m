classdef bf_data < handle
    % BF_DATA Beamformer Audio Buffer. Has many functions to label the
    %   channels and add data from different sources. The time indices of the 
    %   data in the buffer can be kept in sync using different methods.
    %
    %   BF_DATA(OBJ) create empty file object
    %   BF_DATA(OBJ, MAINOBJ) create file object and add handle to main object
    %   BF_DATA(OBJ, MAINOBJ, SOURCEID) create empty file object and set SourceID
    %   BF_DATA(OBJ, MAINOBJ, SOURCEID, FILENAME) add file named fileName to object
    %   BF_DATA(OBJ, MAINOBJ, SOURCEID, FILENAME, LOCATIONS) add file with locations
    %   BF_DATA(OBJ, MAINOBJ, SOURCEID, FILENAME, LOCATIONS, CHANNAMES) add file with
    %   locations and channel names
    %
    % Example 1:
    %   obj = bf_data
    %   obj.setChanNames({'S1','S2','S3','S4'})
    %   obj.setTotalSamples(100)
    %   obj.addSamples([1;2;3;4;[5:100]'],'S3')
    %   obj.getAudioData({'S3','S1'})
    %
    % Example 2:
    %   obj = bf_data
    %   obj.setChanNames({'S1','S2','S3','S4'})
    %   obj.addSamples([1;2;3;4;[5:100]'],'S1',1,25)
    %
    % Example 3:
    %   obj = bf_data
    %   obj.setChanNames({'S1','S2','S3','S4'})
    %   obj.setDelays(5,{'S2'})
    %   obj.addSamples([1;2;3;4;[5:100]'],'S3',1)
    %
    % BF_DATA Methods:
    %   load            - Load data from audio or matlab file.
    %   save            - Save data to audio or matlab file.
    %   play            - Play the data using an audio device.
    %   setNChan        - Set number of channels.
    %   setTotalSamples - Set total number of samples.
    %   setLocations    - Set Channel Locations.
    %   setChanNames    - Set Channel Names.
    %   setDelays       - Set Delay Times.
    %   addSamples      - Add samples to the data.
    %   getAudioData    - Get samples out of buffer (time axes of channels agree).
    %   resampleData    - Resample data using matlab resample function
    %   delayData       - Delay data so when data is loaded the time axes agree.
    %   names2inds      - Get index of channel(s) in audiodata matrix
    %
    % BF_DATA Properties:
    %   FileName      - Name of the audio file to save including extention
    %   FilePath      - Path of the audio file to save
    %   SourceID      - Identifier for source device or file in use.
    %   Fs            - Sampling Frequency in Hz
    %   BitsPerSample - Number of Bits per audio Sample
    %   NChan         - Number of audio channels in File
    %   Comment       - Comment of audio file
    %   Locations     - Channel locations [x y z az el up]
    %   ChanNames     - Channel names
    %   DelaySamples  - Delays in samples for each channel
    %   CurrentSample - Current sample for each channel. Used when adding
    %   samples to the channel.
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
    %   See also BF_DATA/LOAD, BF_DATA/SAVE, BF_DATA/PLAY, BF_DATA/ADDSAMPLES,
    %   BF_DATA/SETNCHAN, BF_DATA/SETTOTALSAMPLES, BF_DATA/SETLOCATIONS, 
    %   BF_DATA/SETCHANNAMES, BF_DATA/SETDELAYS, BF_DATA/ADDSAMPLES, 
    %   BF_DATA/GETAUDIODATA, BF_DATA/RESAMPLEDATA, BF_DATA/DELAYDATA,
    %   BF_DATA/NAMES2INDS, MITM, SITM, AUDIOREAD, AUDIOWRITE, SAVE, LOAD

    % Properties
    properties
        MainObj                      % Handle of main object
        FileName      = '';          % Name of the audio file to save including extention
        FilePath      = '';          % Path of the audio file to save
        SourceID      = '';          % Identifier for source device or file in use.
        Tag           = 'bf_data';   % Tag to find object
    end
    % Properties
    properties %(Access = private)
        AudioData     = [];          % Audio Data matrix size = [TotalSamples NChan]
    end
    % Observable Properties
    properties (SetObservable)
        Fs            = 48000;       % Sampling Frequency in Hz
        BitsPerSample = 32;          % Number of Bits per audio Sample
        NChan         = 0;           % Number of audio channels in File
        Comment       = '';          % Comment of audio file
        Locations     = [];          % Channel locations [x y z az el up]'
        ChanNames     = {};          % Channel names
        DelaySamples  = [];          % Delay in samples for each channel
        CurrentSample = [];          % Current sample for each channel, can be used to store sample offset
        TotalSamples  = 0;           % Total length of the audio data in samples
        IsInitialized = false;       % Has the source been correctly initialized
        SpeedSound    = 342;
    end
    properties (Constant)
        DefaultLoc = [0 0 0 0 pi 1]; % [x y z az el up]
    end
    
    % Events
    %   ListenerObject = addlistener(obj,'LocationsChanged',@() disp('Locations Changed'))
    %   ListenerObject = addlistener(obj.MainObj.DataBuffer,'LocationsChanged',@obj.Update);
    %   ListenerObject = addlistener(obj.MainObj.DataBuffer,'ChannelsChanged',@obj.Update);
    %   ListenerObject = addlistener(obj.MainObj.DataBuffer,'DataChanged',@obj.Update);
   events
      LocationsChanged
      ChannelsChanged
      DataChanged
   end
   
    % Methods
    methods
        
        %------------------------------------------------------------------
        %% Constructor Function
        %------------------------------------------------------------------
        
        function obj = bf_data(mainObj, sourceID, fileName, locations, chanNames, totalSamples)
            narginchk(0,6)
            if nargin >= 1
                obj.MainObj = mainObj;
            else
                help bf_data
                obj.MainObj.Update = @() disp([]);
            end
            if nargin < 2
                obj.SourceID = 'untitled source';
            elseif ischar(sourceID)
                obj.SourceID = sourceID;
            else
                error('bf_data:%s: SourceID argument rejected',obj.SourceID)
            end
            if nargin < 3
                obj.FileName = '';
            elseif ischar(fileName)
                if exist(fileName, 'file') == 2
                    obj.FileName = fileName;
                else
                    error('bf_data:%s: fileName argument rejected, file not found',obj.SourceID)
                end
            end
            if nargin < 4
                obj.setNChan(0);
            elseif isnumeric(locations) && (size(locations,2) == 6 || size(locations,2) == 3)
                obj.setNChan(size(locations,1));
            else
                error('bf_data:%s: Locations argument rejected',obj.SourceID)
            end
            if nargin < 5
                obj.setChanNames;
            else
                obj.setChanNames(chanNames);
            end
            if nargin >= 6
                obj.setTotalSamples(totalSamples);
            end
            
            % Debug
%             assignin('base','obj',obj);
        end
        
        %------------------------------------------------------------------
        %% Load Function
        %------------------------------------------------------------------
        
        function obj = load(obj,fileName)
            % LOAD Load data from audio or matlab file.
            %
            %   LOAD(OBJ) Load file
            %   LOAD(OBJ,fileName) Load file
            
            % Get file name if empty
            if nargin >= 2
                if isempty(fileName)
                    [name1,path1] = uigetfile(...
                        {'*.*',  'All Files (*.*)';...
                        '*.mat','MAT-files (*.mat)';...
                        '*.wav','Waveform Audio File Format (*.wav)'},...
                        'Save File',fullfile(pwd, '\files'));
                    if ~ischar(name1) || ~ischar(path1)
                        warning('bf_data:%s:load: Invalid file selected',obj.SourceID)
                        return
                    else
                        obj.FileName = name1;
                        obj.FilePath = path1;
                    end
                end
            end
            % Load file
            if ~isempty([obj.FilePath obj.FileName])
                if isempty(strfind(obj.FileName,'.mat'))
                    [y, Fs] = audioread(fullfile(obj.FilePath,obj.FileName));
                    info = audioinfo(fullfile(obj.FilePath,obj.FileName));
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
                        Locations = locs;
                    end
                else
                    load(fullfile(obj.FilePath,obj.FileName));
                end
                if exist('AudioData','var')
                    y = AudioData; %#ok<CPROP>
                end
                if exist('y','var') && exist('Fs','var')
                    [nSamples, nChan] = size(y);
                    fprintf('File %s loaded, %i channels with %i samples.\n',obj.FileName, nChan, nSamples);
                    if Fs ~= obj.Fs
                        y = resampleAudioData(y, obj.Fs,Fs,obj.audioDataType);
                    end
                    if ~exist('ChanNames','var')
                        if nChan == 1
                            ChanNames{1} = obj.FileName;
                        else
                            for ii = 1:nChan
                                ChanNames{ii} = [obj.FileName sprintf(' Ch %i',ii)];
                            end
                        end
                    end
                    obj.addSamples(y,ChanNames,true); % Add the channels
                    if exist('Locations','var')
                        obj.setLocations(Locations,ChanNames);
                    end
                    if exist('DelaySamples','var')
                        obj.setDelays(DelaySamples,ChanNames); %#ok<CPROP>
                    end
                elseif exist('Fs','var')
                    error('bf_data:%s:load: File does not contain ''y'' variable',obj.SourceID)
                else
                    error('bf_data:%s:load: File does not contain ''Fs'' variable',obj.SourceID)
                end
            end
        end
        
        %------------------------------------------------------------------
        %% Save Function
        %------------------------------------------------------------------
        
        function save(obj, varargin)
            % SAVE Save data to audio or matlab file.
            %
            %   SAVE(OBJ) Save file.
            %   SAVE(OBJ, CHANNAMES) Save specific channels to file.
            %   SAVE(OBJ, CHANNAMES, FIRSTSAMPLE, LASTSAMPLE) Save part of 
            %   specific channels to file.
            %   SAVE(OBJ, Y, FS) save file with samples y and sample rate Fs.
            %   SAVE(OBJ, Y, FS, LOCATIONS) add file with samples y, 
            %   sample rate Fs and locations.
            %   SAVE(OBJ, Y, FS, LOCATIONS, CHANNAMES) add file with 
            %   samples y, sample rate Fs, locations and channel names.
            %
            % SAVE Arguments option 1:
            %   y         - Matrix of samples
            %   Fs        - Sampling Frequency in Hz
            %   locations - Channel locations [x y z az el up]
            %   chanNames - Channel names cellstr
            %
            % SAVE Arguments option 2:
            %   chanNames - Channel names cellstr
            narginchk(1,5)
            if nargin == 3
%                 obj.Fs = varargin{3};
                Fs = varargin{3};
%                 obj.setNChan(size(varargin{2},2));
%                 obj.setTotalSamples(size(varargin{2},1));
%                 obj.AudioData = varargin{2};  % Store audio data in object
                y = varargin{2};
%                 obj.CurrentSample = zeros(obj.NChan,1);
            elseif nargin == 1 && obj.IsInitialized
                y = obj.AudioData;  % Load samples from object
                Fs = obj.Fs;
            elseif (nargin == 2 || nargin == 4) && obj.IsInitialized
                Fs = obj.Fs;
                if iscellstr(varargin{1}) || ischar(varargin{1})
                    chanNames = varargin{1};
                    if nargin == 2
                        y = obj.getAudioData(chanNames);  % Load samples from object
                    else
                        y = obj.getAudioData(chanNames,varargin{2:3});  % Load samples from object
                    end
                else
                    error(['bf_data:%s:save:ChanNamesRejected: ',...
                        'The file could not be saved because the channel'...
                        'names were rejected.'],obj.SourceID);
                end
            else
                warning(['bf_data:%s:save:NotInitialized: ',...
                    'The file could not be saved because the object was',...
                    ' not initialized.'],obj.SourceID);
                return;
            end
            if nargin >= 4
                if ~iscellstr(varargin{1}) && ~ischar(varargin{1})
                    obj.setLocations(varargin{4});
                end
            end
            if nargin >= 5
                obj.setChanNames(varargin{5});
            end
            % Get file name if empty
            if isempty(obj.FileName)
                [name1,path1] = uiputfile(...
                    {'*.*',  'All Files (*.*)';...
                    '*.mat','MAT-files (*.mat)';...
                    '*.wav','Waveform Audio File Format (*.wav)'},...
                    'Save File',fullfile(pwd, '\files', sprintf('Recording %s',datestr(now, 'yyyy-mm-dd hhuMM'))));
                if ~ischar(name1) || ~ischar(path1)
                    warning('bf_data:%s:save: Invalid file selected',obj.SourceID)
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
                NChan         = size(chanNames,1);
                SourceID      = obj.SourceID;
                Locations     = obj.Locations(obj.names2inds(chanNames),:);
                Comment       = mat2str(Locations);
                ChanNames     = chanNames;
                DelaySamples  = obj.DelaySamples(obj.names2inds(chanNames));
                CurrentSample = obj.CurrentSample(obj.names2inds(chanNames));
                TotalSamples  = obj.TotalSamples;
                save(fullfile(obj.FilePath,obj.FileName),'y','Fs','BitsPerSample','NChan',...
                    'Comment','Locations','ChanNames','DelaySamples','CurrentSample','TotalSamples');
            end
            fprintf('File %s saved, %i channels with %i samples.\n',obj.FileName, nChan, nSamples);
        end
        
        %----------------------------------------------------------------------
        %% Play Function
        %----------------------------------------------------------------------
        
        function player = play(obj, chanNames, firstSample, lastSample, deviceID)
            % PLAY Play the data using an audio device.
            %
            %   PLAY(OBJ) Play all audio data on default device.
            %   PLAY(OBJ, DEVICEID) Play all audio data on specified device.
            %   PLAY(OBJ, DEVICEID, CHANNAMES) Play audio from specified channels.
            %   PLAY(OBJ, DEVICEID, CHANNAMES, FIRSTSAMPLE, LASTSAMPLE) Play 
            %   part of audio.
            %   player = PLAY(obj,___) Returns audioplayer object.
            narginchk(1,5)
            if nargin < 2
                chanNames = obj.ChanNames;
            end
            if nargin < 3
                firstSample = 1;
                lastSample = obj.TotalSamples;
            elseif isnumeric(firstSample) && numel(firstSample) == 1 && ...
                    isnumeric(lastSample) && numel(lastSample) == 1
                if firstSample > lastSample || lastSample > obj.TotalSamples
                    warning(['bf_data:%s:play: Cannot play from %i to %i. Total',...
                        'samples is %i'], obj.SourceID, firstSample, lastSample, obj.TotalSamples)
                    firstSample = 1;
                    lastSample = obj.TotalSamples;
                end
            else
                firstSample = 1;
                lastSample = obj.TotalSamples;
            end
            if nargin < 5
                info1 = audiodevinfo;
                deviceID = info1.output(1).ID;
            end
            % Play signal
            if obj.IsInitialized && obj.TotalSamples && lastSample >= firstSample
                fprintf('Playing signal(s) for %0.2f seconds\n',(lastSample-firstSample)/obj.Fs);
                nChan = length(obj.names2inds(chanNames));
                y = audiovideo.internal.audio.Converter.('toInt16')(obj.getAudioData(chanNames,firstSample,lastSample));
                fs = obj.Fs;
                if nChan <= 2
                    player = audioplayer(y,fs, 16, deviceID);
                    playblocking(player);
                else
                    for ii = 1:nChan
                        player(ii) = audioplayer(y(:,ii),fs, 16, deviceID);
                    end
                    for ii = 1:nChan-1
                        play(player(ii));
                    end
                    playblocking(player(nChan));
                end
            else
                warning('bf_data:%s:play: Object is not initialized or there are no samples available',obj.SourceID)
            end
        end
        
        % Check if object is initialized
        function value = checkInitialized(obj)
            % Check dependent variables
            obj.checkAudioData;
            obj.checkLocations;
            obj.checkChanNames;
            obj.DelaySamples = [obj.DelaySamples(1:min(end,obj.NChan)) zeros(1,max(0,obj.NChan-length(obj.DelaySamples)))];
            obj.CurrentSample = [obj.CurrentSample(1:min(end,obj.NChan)) ones(1,max(0,obj.NChan-length(obj.CurrentSample)))];
            if obj.NChan %&& obj.TotalSamples
                obj.IsInitialized = true;
            else
                obj.IsInitialized = false;
            end
            value = obj.IsInitialized;
        end
        
        function Update(obj,~,~)
%             disp('Update recieved')
            obj.MainObj.Update();
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
            if isnumeric(nChan) && numel(nChan) == 1 && nChan(1) >= 0
                obj.NChan = nChan;
            else
                error('bf_data:%s:setNChan: nChan argument rejected',obj.SourceID)
            end
            % Check dependent variables
            obj.checkInitialized();
        end
        
        % Set Number of Channels function
        function obj = removeChan(obj, chanNames)
            % REMOVECHAN Remove channel(s) from buffer.
            %
            %   REMOVECHAN(OBJ, CHANNAMES) Remove channels from buffer.
            %
            %   Audio data, name, location, delay time and current sample.
            inds = obj.names2inds(chanNames);
            if ~isempty(inds)
                obj.AudioData(:,inds)   = [];
                obj.ChanNames(inds)     = [];
                obj.Locations(inds,:)   = [];
                obj.DelaySamples(inds)  = [];
                obj.CurrentSample(inds) = [];
                obj.setNChan(obj.NChan - length(inds))
            else
                error('bf_data:%s:removeChan: chanNames argument rejected',obj.SourceID)
            end
            % Check dependent variables
            obj.checkInitialized();
        end
        
        % Set Total Samples function
        function obj = setTotalSamples(obj, totalSamples)
            % SETTOTALSAMPLES Set total number of samples.
            %
            %   SETTOTALSAMPLES(OBJ, TOTALSAMPLES) Set Total Samples value
            %   to object. Makes sure size of AudioData is correct.
            %
            %   totalSamples must be a non-negative scalar.
            if isnumeric(totalSamples) && numel(totalSamples) == 1 && totalSamples >= 0
                obj.TotalSamples = totalSamples;
            else
                error('bf_data:%s:setTotalSamples: totalSamples argument rejected',obj.SourceID)
            end
            obj.checkInitialized();
        end
        
        %------------------------------------------------------------------
        %% Names and Locations Functions
        %------------------------------------------------------------------
        
        % Get Locations function
        function locations = getLocations(obj,chanNames)
            % GETLOCATIONS Returns Locations as rows per channel with on
            % each collumn [x y z az el up].
            % x,y and z are in meters [m].
            % az and el are in radians [rad].
            % up is true if the (micro)phone is faced up.
            %
            %   GETLOCATIONS(OBJ) Get Locations of all channels.
            %   GETLOCATIONS(OBJ, CHANNAMES) Get Locations from specific channels.
            if nargin == 2
                locations = obj.Locations(obj.names2inds(chanNames));
            else
                locations = obj.Locations;
            end
        end
        
        % Set Locations function
        function locations = setLocations(obj, locations, chanNames, addNew)
            % SETLOCATIONS Set Channel Locations.
            %
            %   SETLOCATIONS(OBJ) Set Locations of channels to defaults.
            %   SETLOCATIONS(OBJ, LOCATIONS) Set Locations of channels.
            %   SETLOCATIONS(OBJ, LOCATIONS, CHANNAMES) Set Locations
            %   specific channels.
            %   SETLOCATIONS(OBJ, LOCATIONS, CHANNAMES, ADDNEW) Set Locations
            %   specific channels and append if they dont exist.
            %
            %   Locations must be a NChan by 3 or NChan by 6 numeric array
            narginchk(1,4)
            if nargin == 1
                obj.Locations = repmat(obj.DefaultLoc,obj.NChan,1);
            elseif isnumeric(locations) && size(locations,2) ==  6
                obj.Locations = locations;
            elseif isnumeric(locations) && size(locations,2) ==  3
                obj.Locations = [locations, repmat(obj.DefaultLoc(4:6),size(locations,1),1)];
            elseif ~isempty(obj.Locations)
                warning('bf_data:setLocations:%s: Locations argument rejected',obj.SourceID)
            end
            if nargin < 4
                addNew = false;
            end
            if nargin >= 3
                chanInds = obj.names2inds(chanNames, addNew);
                if length(chanInds) == size(locations,1)
                    obj.Locations(chanInds,:) = locations;
                else
                    warning('bf_data:%s:setLocations: Channel locations could not be replaced',obj.SourceID)
                end
            end
            obj.checkLocations;
            locations = obj.Locations;
            
            % Notify listening objects
            notify(obj,'LocationsChanged');
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
%                 warning('bf_data:%s:checkLocations: Locations argument too short',obj.SourceID)
            elseif size(obj.Locations,1) > obj.NChan
                obj.Locations = obj.Locations(1:obj.NChan,:);
%                 warning('bf_data:%s:checkLocations: Locations argument too long',obj.SourceID)
            else
%                 fprintf('bf_data:%s:checkLocations: Locations set correctly\n',obj.SourceID)
%                 disp(obj.Locations)
            end
        end
        
        % Set Channel Names function
        function chanNames = setChanNames(obj, varargin)
            % SETCHANNAMES Set Channel Names.
            %
            %   SETCHANNAMES(OBJ) Return channel names
            %   SETCHANNAMES(OBJ, CHANNAMES) Set Channel Names of source.
            %   SETCHANNAMES(OBJ, CHANNAMES, ADDNEW) Append channels to
            %   object if addNew is true. Call this to add channels.
            %   SETCHANNAMES(OBJ, OLDNAMES, NEWNAMES) Replace channel names.
            %
            %   ChanNames must be a cellstr with NChan names.
            %   AddNew must be a true or false value
            %   OldNames must be a cellstr with existing names.
            %   NewNames must be a cellstr with the new names.
            narginchk(1,3)
            if nargin == 1
                if isempty(obj.ChanNames)
                    for ii = 1:obj.NChan
                        obj.ChanNames{ii} = sprintf('Ch %i',ii);
                    end
                end
            elseif nargin == 2
                if iscellstr(varargin{1})
                    obj.ChanNames = varargin{1};
                    obj.setNChan(length(varargin{1}));
                end
            elseif nargin >= 3
                if isnumeric(varargin{2})
                    obj.names2inds(varargin{1:2});
                else
                    if ischar(varargin{2})
                        varargin{2} = {varargin{2}}; %#ok<CCAT1>
                    end
                    chanInds = obj.names2inds(varargin{1});
                    if length(chanInds) == length(varargin{2})
                        obj.ChanNames(chanInds) = varargin{2};
                    else
                        warning(['bf_data:%s:setChanNames: Channel names ',...
                            'could not be replaced because the number of ',...
                            'the old and the new channel names disagree.'],obj.SourceID)
                    end
                end
            end
            obj.checkChanNames;
            chanNames = obj.ChanNames;
            
            % Notify listening objects
            notify(obj,'ChannelsChanged');
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
%                 warning('bf_data:%s:checkChanNames: ChanNames argument has too few names',obj.SourceID)
            elseif length(obj.ChanNames) > obj.NChan
                obj.ChanNames = obj.ChanNames(1:obj.NChan);
%                 warning('bf_data:%s:checkChanNames: ChanNames argument has too many names',obj.SourceID)
            else
%                 fprintf('bf_data:%s:checkChanNames: Names set correctly\n',obj.SourceID)
%                 disp(obj.ChanNames)
            end
        end
        
        % Set Delays function
        function obj = setDelays(obj, delaySamples, chanNames)
            % SETDELAYS Set Delay Time in samples.
            %
            %   SETDELAYS(OBJ) Set Delay Time to defaults.
            %   SETDELAYS(OBJ, DELAYSAMPLES) Set Delay Time of all channels.
            %   SETDELAYS(OBJ, DELAYSAMPLES, CHANNAMES) Set Delay Time of 
            %   specific channels.
            %
            narginchk(1,3)
            allChans = false;
            if nargin == 1
                obj.DelaySamples = zeros(1,obj.NChan);
                return;
            end
            if nargin < 3
                chanNames = obj.ChanNames;
                allChans = true;
            end
            chanInds = obj.names2inds(chanNames);
            if length(delaySamples) == 1 && ~allChans
                delaySamples = repmat(delaySamples,1,length(chanInds));
            end
            if  length(delaySamples) ~= length(chanInds)
                error(['bf_data:%s:setDelays: Number of elements in ', ...
                       'delayTimes and chanNames do not agree'],obj.SourceID)
            end
            if allChans
                obj.delayData(delaySamples);
            else
                obj.delayData(delaySamples,chanNames);
            end
        end
        
        %------------------------------------------------------------------
        %% Audio Data Functions
        %------------------------------------------------------------------
        
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
            %
            % NOTE: delaySamples has to be added - DONE
            narginchk(2,5)
            if ~obj.IsInitialized && nargin < 4
                error('bf_data:%s:addSamples: Cannot add samples when object is not initialized and addNew is false',obj.SourceID)
%     %% TODO        elseif ~varargin{2}
                
%                 warning('bf_data:%s:addSamples: Cannot add samples when object is not initialized and addNew is false',obj.SourceID)
            end
%             sampleInds = ones(1,size(y,2));
            sampleInds = obj.CurrentSample;
            chanInds = 1:obj.NChan;
            if nargin >= 3
                if isnumeric(varargin{1})
                    if length(varargin{1}) == 1 || length(varargin{1}) == obj.NChan
                        sampleInds = varargin{1};
                    else
                        error('bf_data:%s:addSamples: Third argument rejected, expected SampleInds',obj.SourceID)
                    end
                elseif ischar(varargin{1}) || iscellstr(varargin{1})
                    if nargin < 4
                        addNew = false;
                    else
                        addNew = varargin{2};
                    end
                    chanInds = obj.names2inds(varargin{1}, addNew);
                    sampleInds = obj.CurrentSample(chanInds);
                else
                    error('bf_data:%s:addSamples: Third argument rejected, expected ChanNames',obj.SourceID)
                end
            end
            if nargin >= 5
                if isnumeric(varargin{3})
                    if length(varargin{3}) == 1 || length(varargin{3}) == length(chanInds)
                        sampleInds = varargin{3};
                    else
                        error('bf_data:%s:addSamples: SampleInds has wrong number of elements',obj.SourceID)
                    end
                else
                    error('bf_data:%s:addSamples: Fifth argument rejected, expected SampleInds',obj.SourceID)
                end
            end
            
            % Convert to correct datatype
            if ~isa(y,obj.audioDataType)
                % Convert data to new data type
                convertMethod = strcmp(obj.audioDataType,{'double','int16','uint8'});
                if convertMethod(2)
                    y = audiovideo.internal.audio.Converter.('toInt16')(y);
                elseif convertMethod(3)
                    y = audiovideo.internal.audio.Converter.('toUint8')(y);
                elseif ~convertMethod(1)
                    y = audiovideo.internal.audio.Converter.('toDouble')(y);
                end
            end

            nSamples = size(y,1);
            if obj.TotalSamples < max(sampleInds)+nSamples-1
                obj.setTotalSamples(max(sampleInds)+nSamples-1);
            end
            if size(y,2) == length(chanInds)
                % add the data
%                 if length(chanInds) == 1 || length(chanInds) == obj.NChan
                    obj.AudioData(sampleInds:sampleInds+nSamples-1,chanInds) = y; % Add y to AudioData at correct channel and correct index
%                 else
%                     for ii = 1:length(sampleInds)
%                         obj.AudioData(sampleInds(ii):sampleInds(ii)+nSamples,chanInds(ii)) = y(:,ii); % Add y to AudioData at correct channel and correct indices
%                     end
%                 end
                % Set current samples
                obj.CurrentSample(chanInds) = sampleInds + nSamples;

            else
                error('bf_data:%s:addSamples: size of y does not correspond to other inputs',obj.SourceID)
            end
            
            % Notify listening objects
            notify(obj,'DataChanged');
        end
        
        % Get Audio Data function
        function [y, totalSamples] = getAudioData(obj,varargin)
            % GETAUDIODATA Gets Audio Data.
            %
            %   y = GETAUDIODATA(OBJ) Returns all audiodata
            %   y = GETAUDIODATA(OBJ, CHANNAMES) Returns auiodata for
            %   specified channels
            %   y = GETAUDIODATA(OBJ, CHANNAMES) Returns auiodata for
            %   specified channels
            %   y = GETAUDIODATA(OBJ, FIRSTSAMPLE, LASTSAMPLE) Returns 
            %   audiodata in range for specified channels
            %   y = GETAUDIODATA(OBJ, CHANNAMES, FIRSTSAMPLE, LASTSAMPLE)
            %   Returns audiodata in range for specified channels
            %   y = GETAUDIODATA(___, DATATYPE) returns data in specified
            %   type
            narginchk(1,5)
            dataType = obj.audioDataType;
            convertMethod = [0,0,0];
            if obj.IsInitialized
                narginNew = nargin;
                if nargin >= 2
                    if ischar(varargin{end})
                        convertMethod = strcmp(varargin{end},{'double','int16','uint8'});
                        if any(convertMethod)
                            dataType = varargin{end};
                            varargin(end) = [];
                            narginNew = nargin - 1;
                        end
                    end
                end
                if narginNew == 1
                    y = obj.AudioData;
                elseif narginNew == 2
                    y = obj.AudioData(:,obj.names2inds(varargin{1}));
                elseif narginNew == 3
                    if isnumeric(varargin{1}) && numel(varargin{1}) == 1 && ...
                            isnemeric(varargin{2}) && numel(varargin{2}) == 1 && ...
                            varargin{1} > 0 && varargin{2} <= obj.TotalSamples && ...
                            varargin{1} <= varargin{2}
                        y = obj.AudioData(varargin{1:2},:);
                    else
                        error('bf_data:%s:getAudioData: Invalid call to y = GETAUDIODATA(OBJ, FIRSTSAMPLE, LASTSAMPLE)',obj.SourceID)
                    end
                elseif narginNew == 4
                    if isnumeric(varargin{2}) && numel(varargin{2}) == 1 && ...
                            isnumeric(varargin{3}) && numel(varargin{3}) == 1 && ...
                            (ischar(varargin{1}) || iscellstr(varargin{1}))
                        if varargin{2} > 0 && varargin{3} <= obj.TotalSamples && varargin{2} <= varargin{3}
                            y = obj.AudioData(varargin{2}:varargin{3},obj.names2inds(varargin{1}));
                        else
                            y = [];
                            warning('bf_data:%s:getAudioData: Not enough data available',obj.SourceID);
                        end
                    else
                        error('bf_data:%s:getAudioData: Invalid call to y = GETAUDIODATA(OBJ, CHANNAMES, FIRSTSAMPLE, LASTSAMPLE)',obj.SourceID)
                    end
                end
            else
                warning('bf_data:%s:getAudioData: Object is not initialized',obj.SourceID)
                y = [];
            end
            totalSamples = obj.TotalSamples;
            
            % Convert to right type
            convertMethod = strcmp(dataType,{'double','int16','uint8'});
            if convertMethod(2)
                y = audiovideo.internal.audio.Converter.('toInt16')(y);
            elseif convertMethod(3)
                y = audiovideo.internal.audio.Converter.('toUint8')(y);
            elseif ~convertMethod(1)
                y = cast(y,outType);
            end
        end
        
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
        
        % Delay Data in Time function
        function y = delayData(obj, delaySamples, chanNames)
            % DELAYDATA Set Channel Delay Time in samples for each channel.
            %
            %   DELAYDATA(OBJ) Set Delay of channels into value(s)
            %   specified in obj.DelaySamples.
            %   DELAYDATA(OBJ, DELAYSAMPLES) Delay all channels by the
            %   number of samples specified in delaySamples.
            %   DELAYDATA(OBJ, DELAYSAMPLES, CHANNAMES) Delay the channels
            %   corresponding to the list of names in chanNames.
            %   
            %   If delaySamples is a vector of length NChan the delays are
            %   set to every channel individually.
            %
            %   delaySamples has units samples
            %
            %   See also BF_DATA/SETDELAYS
            
            %   See also BF_DATA/RESAMPLEDATA, RESAMPLE, TIMESERIES
            narginchk(2,3)
            if nargin >= 2
                if ~isnumeric(delaySamples) || (~numel(delaySamples) == obj.NChan && ~numel(delaySamples) == 1)
                    error('bf_data:%s:delayData: delaySamples should have length 1 or length nChan',obj.SourceID)
                end
            end
            if nargin < 3
                chanNames = obj.ChanNames;
            end
            y = obj.getAudioData(chanNames);
            chanInds = obj.names2inds(chanNames);
            if numel(delaySamples) == 1
                delaySamples = repmat(delaySamples,1,length(chanInds));
            end
            extraSampleLength = max(delaySamples);
%             y = [zeros(min(extraSampleLength-delaySamples),length(chanInds)); ...
%                      obj.getAudioData(chanNames); ...
%                      zeros(extraSampleLength-delaySamples,length(chanInds))];
                                                                                    %             delaySamples = round(delaySamples.*obj.Fs);
                                                                                    %             extraSampleLength = - min(delaySamples) + max(delaySamples);
                                                                                    %             delaySamples = delaySamples - min(delaySamples); % to correct for negative delay times

                                                                                    %             if length(delaySamples) == 1
                                                                                    %                 delaySamples = repmat(delaySamples,1,nChan);
                                                                                    %             elseif length(delaySamples) ~= nChan
                                                                                    %                 error('bf_data:%s:delayData: delaySamples should have length 1 or length nChan',obj.SourceID)
                                                                                    %             end
            
            
            if length(delaySamples) == 1 %|| all(chanInds == 1:obj.NChan)
                y = [zeros(delaySamples,length(chanInds),obj.audioDataType); ...
                     y; ...
                     zeros(extraSampleLength-delaySamples,length(chanInds),obj.audioDataType)];
            else
                y = [y; zeros(extraSampleLength,length(chanInds),obj.audioDataType)]; % First add extra zeros to end, then move samples to correct index
                dataType = obj.audioDataType;
                for ii = 1:length(chanInds)
                    y(:,ii) = [zeros(delaySamples(ii),1,dataType); ...
                               y(1:end-extraSampleLength,ii); ...
                               zeros(extraSampleLength-delaySamples(ii),1,dataType)];
                end
            end
%             obj.AudioData = [obj.AudioData; zeros(extraSampleLength,obj.NChan)];
            obj.setTotalSamples(obj.TotalSamples + extraSampleLength);
%             disp(size(obj.AudioData));disp(size(y));
            obj.AudioData(:,chanInds) = y;   % Save the data to the channels
            
            % Set current samples
%             obj.CurrentSample = obj.CurrentSample + extraSampleLength;
            obj.CurrentSample(chanInds) = obj.CurrentSample(chanInds) + delaySamples;
        end
        
        %------------------------------------------------------------------
        % Helper Functions
        %------------------------------------------------------------------
    
        
        % Names to indices function
        function chanInds = names2inds(obj, chanNames, addNew)
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
            %   chanInds = names2inds(chanNames);
            %   y = obj.AudioData(chanInds);
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
            chanInds = zeros(size(chanNames));
            if iscellstr(chanNames)
                for ii = 1:length(chanInds)
                    res = strcmp(chanNames{ii},obj.ChanNames);
                    if sum(res) == 1
                        chanInds(ii) = find(res~=0, 1, 'first');
                    elseif addNew && sum(res) == 0
                        obj.setNChan(obj.NChan+1);
                        obj.ChanNames{end} = chanNames{ii};
                        chanInds(ii) = obj.NChan;
                    else
                        error('bf_data:%s:names2inds: Channel Name not recognized: %s',obj.SourceID,chanNames{ii})
                    end
                end
            else
                error('bf_data:%s:names2inds: chanNames argument should be a string or a cellstring',obj.SourceID)
            end
            if length(unique(chanInds)) ~= length(chanInds)
                error('bf_data:%s:names2inds: chanNames contains non-unique channels',obj.SourceID)
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


        
% Resample Data function
function y = resampleAudioData(y,fsNew,fsOld,dataType, varargin)
    fprintf('Resampling data from %i to %i Hz.\n',fsOld,fsNew);
    if ~isa(y,'double')
        y = audiovideo.internal.audio.Converter.('toDouble')(y); % y = cast(y,'double'); is slower and less reliable
    end

    % Do resampling using matlab resample function. Extra arguments are passed to resample function
    if length(fsNew) == 1 && length(fsOld) == 1
        y = resample(y,fsNew,fsOld, varargin{5:end}); % resample matrix
    else
        if numel(fsNew) == 1
            fsNew = repmat(fsNew,1,nChan);
        end
        if numel(fsOld) == 1
            fsOld = repmat(fsOld,1,nChan);
        end
        if nargin >= 5
            props = varargin{5:end};
        else
            props = {};
        end
        for ii = 1:nChan
            y(:,ii) = resample(y(:,ii),fsNew(ii),fsOld(ii), props); % resample channels one by one
        end
    end

    % Convert data to new data type
    convertMethod = strcmp(dataType,{'double','int16','uint8'});
    if convertMethod(2)
        y = audiovideo.internal.audio.Converter.('toInt16')(y);
    elseif convertMethod(3)
        y = audiovideo.internal.audio.Converter.('toUint8')(y);
    elseif ~convertMethod(1)
        y = cast(y,oldType);
    end
end