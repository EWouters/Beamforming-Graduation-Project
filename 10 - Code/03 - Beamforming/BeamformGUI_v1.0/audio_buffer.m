classdef audio_buffer < handle
% AUDIO_BUFFER  Audio Buffer.
%   obj = AUDIO_BUFFER Create audio buffer object.
%   a = PBUPDATE(a,b,c)
%
%   This class is an audio buffer which holds the data and can be used to:
%   - organize audio data in memory to avoid having more copies than
%     necessary.
%   - load files in memory from the disk.
%   - recieve streaming data in windows and store them a matrix.
%   - hold an index offset for how far along the each channel the 
%     current index of the buffer is.
%   - return the time available until the end of the signal.
%   - return the time between the first sample and the index.
%   
%   
%   Written for the BSc graduation project Acoustic Enhancement via
%   Beamforming Using Smartphones.  
%
%   Team:           S. Bosma                R. Brinkman
%                   T. de Rooij             R. Smeding
%                   N. van Wijngaarden      E. Wouters
%
%   Supervisor:     Jorge Martínez Castañeda
%
%   Contact: E.H.Wouters@student.tudelft.nl
%
%audiorecorder Audio recorder object.
%   audiorecorder creates an 8000 Hz, 8-bit, 1 channel audiorecorder object.
%   A handle to the object is returned.
%
%   audiorecorder(Fs, NBITS, NCHANS) creates an audiorecorder object with 
%   sample rate Fs in Hertz, number of bits NBITS, and number of channels NCHANS. 
%   Common sample rates are 8000, 11025, 22050, 44100, 48000, and 96000 Hz.
%   The number of bits must be 8, 16, or 24. The number of channels must
%   be 1 or 2 (mono or stereo).
%
%   audiorecorder(Fs, NBITS, NCHANS, ID) creates an audiorecorder object using 
%   audio device identifier ID for input.  If ID equals -1 the default input 
%   device will be used.
%   
% audiorecorder Methods:
%   get            - Query properties of audiorecorder object.
%   getaudiodata   - Create an array that stores the recorded signal values.
%   getplayer      - Create an audioplayer object.
%   isrecording    - Query whether recording is in progress: returns true or false.
%   pause          - Pause recording.
%   play           - Play recorded audio. This method returns an audioplayer object.
%   record         - Start recording.
%   recordblocking - Record, and do not return control until recording completes. 
%                    This method requires a second input for the length of the recording in seconds:
%                    recordblocking(recorder,length)
%   resume         - Restart recording from paused position.
%   set            - Set properties of audiorecorder object.
%   stop           - Stop recording.
%
% audiorecorder Properties:
%   BitsPerSample    - Number of bits per sample. (Read-only)
%   CurrentSample    - Current sample that the audio input device is recording. 
%                      If the device is not recording, CurrentSample is the next 
%                      sample to record with record or resume. (Read-only)
%   DeviceID         - Identifier for audio device. (Read-only)
%   NumberOfChannels - Number of audio channels. (Read-only)
%   Running          - Status of the audio recorder: 'on' or 'off'. (Read-only)
%   SampleRate       - Sampling frequency in Hz. (Read-only)
%   TotalSamples     - Total length of the audio data in samples. (Read-only)
%   Tag              - String that labels the object.
%   Type             - Name of the class: 'audiorecorder'. (Read-only)
%   UserData         - Any type of additional data to store with the object.
%   StartFcn         - Function to execute one time when recording starts.
%   StopFcn          - Function to execute one time when recording stops.
%   TimerFcn         - Function to execute repeatedly during recording. To specify 
%                      time intervals for the repetitions, use the TimerPeriod property.
%   TimerPeriod      - Time in seconds between TimerFcn callbacks.
%
%    The functionality of the timer and the structure of this file were 
%    inspired by the audiorecorder.m file from matlab.
%    Author(s): BJW, JCS, NCH
%    Copyright 1984-2013 The MathWorks, Inc.
%
%   See also MAIN_WINDOW, BF_FILE, MITM, BFCOM, SMARTPHONE_SETTINGS_UI,
%   FIREFACE_UI, SIMULATION_UI, COMP_MIC_UI,AUDIOPLAYER, AUDIODEVINFO,  
%   AUDIORECORDER/GET, AUDIORECORDER/SET. 

    %% Properties
    properties (Constant)
        Name = 'Audio Buffer';
    end
    properties
        Fs                     % Sample rate of all the data
        NChan                  % Total number of channels
        EmptyFile   = struct;  % Template for new file
        EmptyStream = struct;  % Template for new stream
        File        = struct;  % Data from file
        Simulation  = struct;  % Data from Simulation
        Smartphones = struct;  % Data from smartphones
        Fireface    = struct;  % Data from Fireface
        ComputerMic = struct;  % Data from Computer Microphone
        Processed   = struct;  % Processed data from beamformers
                
        IsInitialized = false; % Has the buffer been correctly initialized
        
        CurrentSample   % Current sample for each channel
        SamplesToRead   % Number of samples to read during record
        TotalSamples    % Total length of the audio data in samples
        Timer           % Timer object created by the user
        TimerListener   % listen to the Timers ExecuteFcn event
        TimerPeriod = 0.05;   % Time, in seconds, between TimerFcn callbacks
        Running = 'off'
        Tag
        % should be removed:
        AudioDataType  
    end
 
    % --------------------------------------------------------------------
    % Constants
    % --------------------------------------------------------------------
    properties(GetAccess='private', Constant)
        MinimumSampleRate    = 80;
        MaximumSampleRate    = 1e6;
        MinimumTimerPeriod   = .001;
        DesiredLatency       = 0.025;            % The Desired Latency (in seconds) we want the audio device to run at.
        MaxSamplesToRead     = intmax('uint64'); % The maximum number of samples that can be read in a given recording session
        DefaultBitsPerSample = 16;
    end    
 


    % --------------------------------------------------------------------
    % Lifetime
    % --------------------------------------------------------------------
    methods(Access='public')
        %%  Audio Buffer Constuctor
        function obj = audio_buffer(fs)
            narginchk(0,1);
            if nargin == 1
                obj.Fs = fs;
            else
                obj.Fs = 48000;
            end
            obj.NChan = 0;
            
            % --------------------------------------------------------------------
            % Empty file properties 
            % --------------------------------------------------------------------
            
            obj.EmptyFile.FileName      = 0;           % Name of the audio file to save including extention
            obj.EmptyFile.FilePath      = 0;           % Path of the audio file to save
            obj.EmptyFile.SourceID      = 'emptyFile'; % Identifier for source device or file in use.
            obj.EmptyFile.Fs            = obj.Fs;      % Sampling Frequency in Hz
            obj.EmptyFile.BitsPerSample = 16;          % Number of Bits per audio Sample
            obj.EmptyFile.NChan         = 1;           % Number of audio channels in File
            obj.EmptyFile.Locations     = [];          % Channel locations [x y z az el up]'
            obj.EmptyFile.ChanNames     = {};          % Channel names
            obj.EmptyFile.CurrentSample = [];          % Current sample for each channel, can be used to 
            obj.EmptyFile.TotalSamples  = 0;           % Total length of the audio data in samples
            obj.EmptyFile.IsInitialized = false;       % Has the source been correctly initialized
            obj.EmptyFile.AudioData     = [];          % Audio Data matrix size = [TotalSamples NChan]
            
            % --------------------------------------------------------------------
            % Empty stream properties 
            % --------------------------------------------------------------------
            
            obj.EmptyStream                 = obj.EmptyFile; % Base on file structure
            obj.EmptyStream.Running         = 'off';         % Status of the audio recorder: 'on' or 'off'
            obj.EmptyStream.Channel         = [];            % Source for the audiostream
            obj.EmptyStream.ChannelListener = [];            % Listener for Channel events
            obj.EmptyStream.SamplesToRead   = 0;             % Number of samples to read during record
            obj.EmptyStream.StopCalled      = true;          % Has stopped been called
            obj.EmptyStream.StartFcn        = [];            % Handle to start callback function
            obj.EmptyStream.StopFcn         = [];            % Handle to stop callback function
            
            % --------------------------------------------------------------------
            % Create Empty Sources
            % --------------------------------------------------------------------
        
            obj.File        = obj.EmptyFile;
            obj.Simulation  = obj.EmptyFile;
            obj.Smartphones = obj.EmptyStream;
            obj.Fireface    = obj.EmptyStream;
            obj.ComputerMic = obj.EmptyStream;
            obj.Processed   = obj.EmptyFile;    % Processed data channels
            
%             obj.initialize();
            
            assignin('base','obj',obj)
        end
%         function delete(obj)
% %             stop(obj.Smartphones);
% %             stop(obj.Fireface);
% %             stop(obj.ComputerMic);
% %             obj.uninitialize_Smartphones();
% %             obj.Fireface.uninitialize();
% %             obj.ComputerMic.uninitialize();
%             disp('delete called')
%         end
        
        function initialize(obj)
            % Initialize other un-documented properties.
            obj.SamplesToRead = obj.MaxSamplesToRead;

            % Grab the default device.
            
            % Create Channel object and give it
%                 obj.Channel = asyncio.Channel( ...
%                     fullfile(pluginDir, 'audiodeviceplugin'),...
%                     fullfile(pluginDir, 'audiomlconverter'),...
%                     obj.Options, [Inf, 0]);
            obj.Smartphones.Channel = [];
            
%             
%             obj.Smartphones.ChannelListener = event.listener(obj.Smartphones.Channel,'Custom', ...
%                  @(src,event)(obj.onCustomEvent(event)));
            
            obj.initializeTimer();

            obj.IsInitialized = true;
        end
        
        function uninitialize(obj)
            obj.uninitializeTimer();    
            
            delete(obj.Smartphones.ChannelListener);
            delete(obj.Fireface.ChannelListener);
            delete(obj.ComputerMic.ChannelListener);
%             obj.Smartphones.Channel.close();
%             obj.Fireface.Channel.close();
%             obj.ComputerMic.Channel.close();

            obj.Smartphones.IsInitialized = false;
            obj.Fireface.IsInitialized = false;
            obj.ComputerMic.IsInitialized = false;
        end
        
        
        %----------------------------------------------------------------------
        % Methods to add and remove channels
        %----------------------------------------------------------------------
        
%         % addFile function
%         function addFile(obj, y, fs, infoStructIn)
%             % ADDFILE  Add data from file to buffer
%             %
%             %   ADDFILE(OBJ, Y, FS) add file
%             %   ADDFILE(OBJ, Y, FS, BF_FILE) add file
%             %
%             %   - y                 % Matrix of samples with size = [numberOfSamples NChan]
%             %   - fs                % Sampling Frequency in Hz
%             %   - infoStruct        % Struct with optional fields:
%             %       - BitsPerSample % Number of Bits per audio Sample
%             %       - Fs            % Sampling Frequency in Hz
%             %       - NChan         % Number of audio channels in File
%             %       - Locations     % Channel locations [x y z az el up]'
%             %       - ChanNames     % Channel names
%             %
%             %   See also AUDIO_BUFFER, AUDIO_BUFFER/REMOVEFILE, BF_FILE,
%             %   AUDIOREAD
%             narginchk(3,4)
%             if nargin >= 3
%                 infoStruct = infoStructIn;
%             end
%             % Find uninitialized file
%             fNum = 1;
%             while 1
%                 if fNum == length(obj.File)
%                     fNum = fNum+1;
%                     break;
%                 end
%                 if obj.File(fNum).IsInitialized
%                     fNum = fNum+1;
%                 else
%                     break;
%                 end
%             end
%             obj.File(fNum) = obj.EmptyFile;
%             obj.File(fNum).Fs = fs;
%             
%             % Load Audio Data matrix, size = [TotalSamples NChan]
%             if isempty(findobj(infoStruct,'Tag', 'bf_file'))
%                 obj.File(fNum).AudioData = y; % Get data from function argument
%             else
%                 obj.File(fNum).AudioData = infoStruct.load; % Get data from bf_file
%             end
%             if isstruct(infoStruct) || ~isempty(findobj(infoStruct,'Tag', 'bf_file'))
%                 % Anonymous function to check if field or property exists in infoStruct
%                 isFieldProp = @(StrProp,String) isfield(StrProp,String) || isprop(StrProp,String);
%                 
%                 % Set BitsPerSample
%                 if isFieldProp(infoStruct,'BitsPerSample')
%                     obj.File(fNum).BitsPerSample = infoStruct.BitsPerSample;
%                 else
%                     obj.File(fNum).BitsPerSample = obj.DefaultBitsPerSample;
%                 end
%                 % Set Number of Channels
%                 if isFieldProp(infoStruct,'NChan')
%                     obj.File(fNum).NChan = infoStruct.NChan;
%                 elseif isFieldProp(infoStruct,'NumberOfChannels')
%                     obj.File(fNum).NChan = infoStruct.NumberOfChannels;
%                 else
%                     obj.File(fNum).NChan = size(y,2);
%                 end
%                 % Set Locations
%                 if isFieldProp(infoStruct,'Locations')
%                     obj.File(fNum).Locations = infoStruct.Locations;
%                 end
%                 if ~all(size(obj.File(fNum).Locations) == [obj.File(fNum).NChan, 6])
%                     obj.File(fNum).Locations = [zeros(obj.File(fNum).NChan,4),...
%                                                 repmat([pi, 1],obj.File(fNum).NChan,1)]; 
%                 end
%                 % Set Channel Names
%                 if isFieldProp(infoStruct,'ChanNames')
%                     if iscellstr(infoStruct.ChanNames)
%                         obj.File(fNum).ChanNames = infoStruct.ChanNames;
%                     end
%                 end
%                 if length(obj.File(fNum).ChanNames) < obj.File(fNum).NChan
%                     for ii = (length(obj.File(fNum).ChanNames)+1):obj.File(fNum).NChan
%                         obj.File(fNum).ChanNames{ii} = sprintf('Ch %i',ii);
%                     end
%                 else
%                     obj.File(fNum).ChanNames = obj.File(fNum).ChanNames{1:obj.File(fNum).NChan};
%                 end
%                 % Set other properties:
%                 obj.File(fNum).CurrentSample = ones(obj.File(fNum).NChan,1);	% Current sample for each channel
%                 obj.File(fNum).TotalSamples  = size(y,1);                       % Total length of the audio data in samples
%                 obj.File(fNum).IsInitialized = true;                            % Has the source been correctly initialized
%              else
%                 error('audio_buffer:addFile:Invalid infoStruct')
%             end
%         end
        
        % addFile function
        function addFile(obj, fileName, locations, chanNames)
            % ADDFILE  Add data from file to buffer
            %
            %   ADDFILE(OBJ) add file to buffer
            %   ADDFILE(OBJ, BF_FILE) add file using BF_FILE to buffer
            %   ADDFILE(OBJ, 'fileName') add file named fileName to buffer
            %   ADDFILE(OBJ, 'fileName', LOCATIONS) add file named fileName to buffer
            %   ADDFILE(OBJ, 'fileName', LOCATIONS, CHANNAMES) add file named fileName to buffer
            %   
            %   BF_FILE   - BF_FILE object
            %   FileName  - File name
            %   Locations - Channel locations [x y z az el up]
            %   ChanNames - Channel names
            %
            %   See also AUDIO_BUFFER, AUDIO_BUFFER/REMOVEFILE, BF_FILE,
            %   AUDIOREAD
            narginchk(1,4)
            
            % Find uninitialized file
            fNum = 1;
            while 1
                if fNum == length(obj.File)
                    fNum = fNum+1;
                    break;
                end
                if obj.File(fNum).IsInitialized
                    fNum = fNum+1;
                else
                    break;
                end
            end
            obj.File(fNum) = obj.EmptyFile;
            
            % Check input
            if nargin >= 2
                if ischar(fileName)
                    if esist
                end
                fileName_1 = 
            else
                fileName_1
            end
            if nargin >= 3
                infoStruct = infoStructIn;
            end
            
                if isstr
                isempty(findobj(infoStruct,'Tag', 'bf_file'))
                exist name
                obj.File(fNum).FileName
            obj.File(fNum).Fs = fs;
            
            % Load Audio Data matrix, size = [TotalSamples NChan]
            if isempty(findobj(infoStruct,'Tag', 'bf_file'))
                obj.File(fNum).AudioData = y; % Get data from function argument
            else
                obj.File(fNum).AudioData = infoStruct.load; % Get data from bf_file
            end
            if isstruct(infoStruct) || ~isempty(findobj(infoStruct,'Tag', 'bf_file'))
                % Anonymous function to check if field or property exists in infoStruct
                isFieldProp = @(StrProp,String) isfield(StrProp,String) || isprop(StrProp,String);
                
                % Set BitsPerSample
                if isFieldProp(infoStruct,'BitsPerSample')
                    obj.File(fNum).BitsPerSample = infoStruct.BitsPerSample;
                else
                    obj.File(fNum).BitsPerSample = obj.DefaultBitsPerSample;
                end
                % Set Number of Channels
                if isFieldProp(infoStruct,'NChan')
                    obj.File(fNum).NChan = infoStruct.NChan;
                elseif isFieldProp(infoStruct,'NumberOfChannels')
                    obj.File(fNum).NChan = infoStruct.NumberOfChannels;
                else
                    obj.File(fNum).NChan = size(y,2);
                end
                % Set Locations
                if isFieldProp(infoStruct,'Locations')
                    obj.File(fNum).Locations = infoStruct.Locations;
                end
                if ~all(size(obj.File(fNum).Locations) == [obj.File(fNum).NChan, 6])
                    obj.File(fNum).Locations = [zeros(obj.File(fNum).NChan,4),...
                                                repmat([pi, 1],obj.File(fNum).NChan,1)]; 
                end
                % Set Channel Names
                if isFieldProp(infoStruct,'ChanNames')
                    if iscellstr(infoStruct.ChanNames)
                        obj.File(fNum).ChanNames = infoStruct.ChanNames;
                    end
                end
                if length(obj.File(fNum).ChanNames) < obj.File(fNum).NChan
                    for ii = (length(obj.File(fNum).ChanNames)+1):obj.File(fNum).NChan
                        obj.File(fNum).ChanNames{ii} = sprintf('Ch %i',ii);
                    end
                else
                    obj.File(fNum).ChanNames = obj.File(fNum).ChanNames{1:obj.File(fNum).NChan};
                end
                % Set other properties:
                obj.File(fNum).CurrentSample = ones(obj.File(fNum).NChan,1);	% Current sample for each channel
                obj.File(fNum).TotalSamples  = size(y,1);                       % Total length of the audio data in samples
                obj.File(fNum).IsInitialized = true;                            % Has the source been correctly initialized
             else
                error('audio_buffer:addFile:Invalid infoStruct')
            end
        end        
        
        function removeFile(obj, fNum)
            % REMOVEFILE  Add data from file to buffer
            %
            %   REMOVEFILE(OBJ) removes first file from Audio Buffer
            %   REMOVEFILE(OBJ, FNUM) removes specific file from Audio Buffer
            %   
            %   fNum - Index of file to remove 
            %
            %   See also AUDIO_BUFFER, AUDIO_BUFFER/ADDFILE
        
            narginchk(1,2)
            if nargin == 1
                fNum = 1;                   % fNum is 1 if not specified
            end
            if ~isscalar(fNum)
                fNum = 1;                   % fNum is 1 if not scalar
            end
            if length(obj.File) < fNum
                warning('audio_buffer:removeFile:File index larger than number of files in buffer')
                return;                     % return if fNum is not a file index
            end
            if obj.File(fNum).IsInitialized
                obj.File(fNum) = [];        % remove the file
            end
            if isempty(obj.File)
                obj.File(1) = obj.EmptyFile;% add empty file if no files are left
            end
        end
        
    end

    %----------------------------------------------------------------------
    % Custom Getters/Setters
    %----------------------------------------------------------------------
    methods
            
%             % Get the list of input devices
%             devices = multimedia.internal.audio.device.DeviceInfo.getDevicesForDefaultHostApi;
%             inputs = devices([devices.NumberOfInputs] > 0);
            
            

        function set.Fs(obj, value)
            if value <= obj.MinimumSampleRate || value > obj.MaximumSampleRate
                error('Audio buffer: invalidSampleRate');
            end

            if ~(isscalar(value) && ~isinf(value))
                error('Audio buffer: NonscalarSampleRate');
            end

            obj.Fs = value;
        end
        
        function value  = get.CurrentSample(obj)
            if ~obj.isrecording() && obj.StopCalled 
                % stop(obj) was called, reset the current sample
                value = 1; 
            else
                % pause(obj) was called, set to the next sample
                value = obj.TotalSamples + 1;
            end
        end
        
        function value = get.TotalSamples(obj)
            if isempty(obj.Channel)
                value = 0;
            else
                % Initial samples are the total acquired so far
                % plus what is in the Channel's input stream
                value = size(obj.AudioData, 1) + obj.Channel.InputStream.DataAvailable; 

                % If the user has requested a certain number of samples, return the 
                % up to that value (SamplesToRead)
                value = min(value, obj.SamplesToRead);

                value = double(value);
            end
        end
        
        function value = get.AudioDataType(obj)
            switch obj.BitsPerSample
                case 8
                    value = 'uint8';
                case 16
                    value = 'int16';
                case 24
                    value = 'double';
                otherwise
                    error(message('MATLAB:audiovideo:audiorecorder:bitsupport'));
            end                    
        end
        
        function value = get.Running(obj)
            if obj.isrecording()
                value = 'on';
            else
                value = 'off';
            end
        end
        
        function set.TimerPeriod(obj, value)
            validateattributes(value, {'numeric'}, {'positive', 'scalar'});
            if(value < obj.MinimumTimerPeriod) 
                 error(message('MATLAB:audiovideo:audiorecorder:invalidtimerperiod'));
            end
            
            obj.TimerPeriod = value;
            obj.Timer.Period = value; %#ok<MCSUP>
         end
        
        function set.Tag(obj, value)
            if ~(ischar(value))
                error(message('MATLAB:audiovideo:audiorecorder:TagMustBeString'));
            end
            obj.Tag = value;
        end
    end
    
    %----------------------------------------------------------------------
    % Function Callbacks/Helper Functions
    %----------------------------------------------------------------------
    methods(Access='private')  
        
        function executeTimerCallback(obj, ~, ~)  
            internal.Callback.execute(obj.TimerFcn, obj);
        end
        
        function onCustomEvent(obj, event)
            % Process any custom events from the Channel
            switch event.Type
                case 'StartEvent'
                    obj.startTimer();
                case 'DoneEvent'
                    stop(obj); % stop if we are done
            end
        end
        
    end
    
    
    %----------------------------------------------------------------------
    % Timer related functionality
    %----------------------------------------------------------------------
    methods(Access='private')  
        function initializeTimer(obj)
            obj.Timer = internal.IntervalTimer(obj.TimerPeriod);

            obj.TimerListener = event.listener(obj.Timer, 'Executing', ...
                @obj.executeTimerCallback);
        end
        
        function uninitializeTimer(obj)
            if(isempty(obj.Timer) || ~isvalid(obj.Timer))
                return;
            end
            
            delete(obj.TimerListener);
        end
        
        function startTimer(obj)
            if isempty(obj.TimerFcn)
                return;
            end
            
            start(obj.Timer);
        end
        
        function stopTimer(obj)
            if isempty(obj.TimerFcn)
                return;
            end
            
            stop(obj.Timer);
        end
        
        function timerFcn(obj)
            disp('buffer timer callback')
        end
    end
    
    %----------------------------------------------------------------------        
    % audiorecorder Functions
    %----------------------------------------------------------------------
    methods(Access='public')
        
        function status = isrecording(obj)
            %ISRECORDING Indicates if recording is in progress.
            %
            %    STATUS = ISRECORDING(OBJ) returns true or false, indicating
            %    whether recording is or is not in progress.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET,
            %             AUDIORECORDER/SET.

            status = ~isempty(obj.Channel) && obj.Channel.isOpen();
        end
        
        function stop(obj)
            %STOP Stops recording in progress.
            %
            %    STOP(OBJ) stops the current recording.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET,
            %             AUDIORECORDER/SET, AUDIORECORDER/RECORD,
            %             AUDIORECORDER/RECORDBLOCKING, AUDIORECORDER/PAUSE,
            %             AUDIORECORDER/RESUME

            obj.StopCalled = true;
            pause(obj);
        end
        
        function pause(obj)
            %PAUSE Pauses recording in progress.
            %
            %    PAUSE(OBJ) pauses recording.  Use RESUME or RECORD to resume
            %    recording.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET,
            %             AUDIORECORDER/SET, AUDIORECORDER/RESUME,
            %             AUDIORECORDER/RECORD.
            
            %    JCS
            %    Copyright 2003 The MathWorks, Inc.
            
            
            if ~isrecording(obj)
                return;
            end
            
            obj.Channel.close();
            obj.stopTimer();
            
            internal.Callback.execute(obj.StopFcn, obj);
        end
        
        function resume(obj)
            %RESUME Resumes paused recording.
            %
            %    RESUME(OBJ) continues recording from paused location.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET,
            %             AUDIORECORDER/SET, AUDIORECORDER/PAUSE.
            
            if (obj.isrecording())
                return;
            end

            if (obj.StopCalled)
                obj.StopCalled = false;
                
                % Remove any buffered data from a previous call to record
                obj.AudioData = [];
                obj.Channel.InputStream.flush();
            end
            
            %Execute StartFcn
            internal.Callback.execute(obj.StartFcn, obj);
            
            try
                obj.Channel.open(obj.Options);
            catch exception
                throw(obj.createDeviceException(exception));
            end
        end
        
        function record(obj, numSeconds)
            %RECORD Record from audio device.
            %
            %    RECORD(OBJ) begins recording from the audio input device.
            %
            %    RECORD(OBJ, T) records for length of time, T, in seconds.
            %
            %    Use the RECORDBLOCKING method for synchronous recording.
            %
            %    Example:  Record your voice on-the-fly.  Use a sample rate of 22050 Hz,
            %              16 bits, and one channel.  Speak into the microphone, then
            %              stop the recording.  Play back what you've recorded so far.
            %
            %       r = audiorecorder(22050, 16, 1);
            %       record(r);     % speak into microphone...
            %       stop(r);
            %       p = play(r);   % listen to complete recording
            %
            %    See also AUDIORECORDER, AUDIORECORDER/PAUSE,
            %             AUDIORECORDER/STOP, AUDIORECORDER/RECORDBLOCKING.
            %             AUDIORECORDER/PLAY, AUDIORECORDER/RESUME.
            
            if isrecording(obj)
                return;
            end
            
            narginchk(1,2);

            if nargin == 2
                if isempty(numSeconds) || ~isnumeric(numSeconds) || (numSeconds <= 0)
                       error(message('MATLAB:audiovideo:audiorecorder:recordTimeInvalid'));
                end
                obj.SamplesToRead = uint64(numSeconds * obj.SampleRate);
                if (~obj.StopCalled)
                     obj.SamplesToRead = obj.SamplesToRead + obj.TotalSamples;
                end
            else
                obj.SamplesToRead = obj.MaxSamplesToRead;
            end
         
            resume(obj);
        end
        
        function recordblocking(obj, numSeconds)
            %RECORDBLOCKING Synchronous recording from audio device.
            %
            %    RECORDBLOCKING(OBJ, T) records for length of time, T, in seconds;
            %                           does not return until recording is finished.
            %
            %    Use the RECORD method for asynchronous recording.
            %
            %    Example:  Record your voice on-the-fly.  Use a sample rate of 22050 Hz,
            %              16 bits, and one channel.  Speak into the microphone, then
            %              stop the recording.  Play back what you've recorded so far.
            %
            %       r = audiorecorder(22050, 16, 1);
            %       recordblocking(r, 5);     % speak into microphone...
            %       p = play(r);   % listen to complete recording
            %
            %    See also AUDIORECORDER, AUDIORECORDER/PAUSE,
            %             AUDIORECORDER/STOP, AUDIORECORDER/RECORD.
            %             AUDIORECORDER/PLAY, AUDIORECORDER/RESUME.
            
            %    Copyright 2003-2006 The MathWorks, Inc.
            %      
            
            % Error checking.
            if ~isa(obj, 'audiorecorder')
                error(message('MATLAB:audiovideo:audiorecorder:noAudiorecorderObj'));
            end
            
            narginchk(2,2);
            
            try
                record(obj, numSeconds);
            catch exception
                throwAsCaller(exception);
            end
            
            pause(numSeconds);
            
            % Wait until recorder is really stopped
            while obj.isrecording()
                pause(0.01);
            end    
        end
        
        function data = getaudiodata(obj, dataType)
            %GETAUDIODATA Gets recorded audio data in audiorecorder object.
            %
            %    GETAUDIODATA(OBJ) returns the recorded audio data as a double array
            %
            %    GETAUDIODATA(OBJ, DATATYPE) returns the recorded audio data in
            %    the data type as requested in string DATATYPE.  Valid data types
            %    are 'double', 'single', 'int16', 'uint8', and 'int8'.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/RECORD.
            
            narginchk(1,2);
            
            if nargin == 1
                dataType = 'double';
            end
            
            if ~ischar(dataType)
                error(message('MATLAB:audiovideo:audiorecorder:unsupportedtype'));
            end
            
            % First, check to see that the datatype requested is supported.
            if ~any(strcmp(dataType, {'double', 'single', 'int16', 'uint8', 'int8'}))
                error(message('MATLAB:audiovideo:audiorecorder:unsupportedtype'));        
            end
            
            % Read all data from the input stream and append it to
            % obj.AudioData
            [newData, countRead, err] = obj.Channel.InputStream.read();
            if ~isempty(err)
                error(message('MATLAB:audiovideo:audiorecorder:ChannelReadError'));
            end
            
            if (countRead~=0)
                % Append new data to our internal data array
                obj.AudioData = [obj.AudioData; newData];
            end
            
            if size(obj.AudioData, 1) > obj.SamplesToRead
                % More data has come in than requested
                % Truncate the data to the size requested
                obj.AudioData = obj.AudioData(1:double(obj.SamplesToRead), :);
            end
            
            if (isempty(obj.AudioData))
                error(message('MATLAB:audiovideo:audiorecorder:recorderempty'));
            end
            
            % Convert data to requested dataType.
            % Conversion function is the capitalized datatype ('Double','Single',etc)
            % prepended by 'to'.
            % Example: 'double' becomes 'toDouble'
            convertFcn = ['to' upper(dataType(1)) dataType(2:end)];
            
            data = audiovideo.internal.audio.Converter.(convertFcn)(obj.AudioData);
        end
        
        function ap = getplayer(obj)
            %GETPLAYER Gets associated audioplayer object.
            %
            %    GETPLAYER(OBJ) returns the audioplayer object associated with
            %    this audiorecorder object.
            %
            %    See also AUDIORECORDER, AUDIOPLAYER.

            ap = audioplayer(obj);
        end

        function player = play(obj, varargin)
        %PLAY Plays recorded audio samples in audiorecorder object.
        %
        %    P = PLAY(OBJ) plays the recorded audio samples at the beginning and
        %    returns an audioplayer object.
        %
        %    P = PLAY(OBJ, START) plays the audio samples from the START sample and
        %    returns an audioplayer object.
        %
        %    P = PLAY(OBJ, [START STOP]) plays the audio samples from the START
        %    sample until the STOP sample and returns an audioplayer object.
        %
        %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET, 
        %             AUDIORECORDER/SET, AUDIORECORDER/RECORD.

            narginchk(1,2);
            
            player = obj.getplayer();
            play(player, varargin{:})
        end
        
    end
end