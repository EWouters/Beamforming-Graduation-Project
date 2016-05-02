classdef bfcom < handle
%% bfcom class
% Class to answer calls from Man in the Middle.
%% Example 1
%   s = bfcom;
%   s.orientationChange('phoneID', 'azimuth', 'elevation');
%   s.Phones[2] = s.Defaults; s.Phones[3] = s.Defaults;
%   s.Phones[2].phoneID = 'ID2';
%   s.Phones[3].phoneID = 'ID3';
%   disp([s.Phones.phoneID]);
%   locs = [s.Phones.location];
%   disp(locs[1]);
%% Example 2
%   s = bfcom;s.Phones[2] = s.Defaults; s.Phones[3] = s.Defaults;s.Phones[2].phoneID = 'ID2';s.Phones[3].phoneID = 'ID3';s.ID2phone('ID2')
%   s.newSamplesAvailable([[1 2 3 4];[9 8 7 6]], ['ID1' 'ID2'])
%   s.newConnection('ID99',1,2*pi)
%   s.orientationChange('ID99', pi, pi/2)
%   s.lostConnection('ID99')

    %% Properties
    properties
        Defaults    % default phone properties
        Phones      % array of phone properties
        Fs = 48000; % sample frequency [Hz]
%         CircularBuffer % Might use a circular buffer to store incomming samples in. Maybe 2 seconds
        % then put frames of desired length in buffer and store them until
        % they are removed by other class. Frames ready can be plotted.
        BufferIDs = {}; % id's of phones keep in buffer.
        BufferLength = 200; % length of buffer in [ms]  samples/frame = round(obj.BufferLength/1000*obj.Fs)
        FramesReady = 0; % frames ready in buffer
        Buffer
        Tag = 'bfcom1'
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = bfcom
            obj.Defaults.phoneID = 'Default';    % Identification string for Phone
            obj.Defaults.location = [0,0,0];     % (x,y,z) coordinates of Phone
            obj.Defaults.azimuth = 0;            % Angle of microphone relative to magnetic north (counter-clockwise positive)
            obj.Defaults.elevation = 0;          % Angle with respect to horizon (upward positive)
            obj.Defaults.faceUp = 1;             % Screen of phone is on the top if faceUp = 1
            obj.Defaults.isMoving = 0;           % 1 if phone is moving
            obj.Defaults.isStreaming = 0;        % 1 if phone is streaming
            obj.Defaults.samples = {};           % Array of samples. samples(end,:) gives most recent sample frame
        end
        

        %% New Connection Function
        function newConnection(obj, phoneID, azimuth, elevation)
            % Function to add phone to array
            num = obj.ID2phone(phoneID);
            if ~num
                obj.Phones = [obj.Phones, obj.Defaults];
                obj.Phones(end).phoneID = phoneID;
                obj.Phones(end).azimuth = azimuth;
                obj.Phones(end).elevation = elevation;
                obj.Buffer = zeros(1,length(obj.Phones));   % Reset buffer
            else
                warning('connection ID ''%s'' is already taken',phoneID);
                % Update orientations anyway
                obj.Phones(num).azimuth = azimuth;
                obj.Phones(num).elevation = elevation;
             end
        end

        %% New Phone Function
        function newPhone(obj, phoneID)
            % Function to add phone to array
            if ~obj.ID2phone(phoneID)
                obj.Phones = [obj.Phones, obj.Defaults];
                obj.Phones(end).phoneID = phoneID;
            else
                warning('connection ID ''%s'' is already taken',phoneID);
            end
        end

        %% Lost Connection Function
        function lostConnection(obj, phoneID)
            % Function to remove phone from array
%             disp(phoneID);
            num = obj.ID2phone(phoneID);
            if num
                obj.Phones(num) = [];
                obj.Buffer = zeros(1,length(obj.Phones));   % Reset buffer
                warning('Connection with ID ''%s'' was closed',phoneID);
            else
                warning('Connection ID ''%s'' does not exist so it cannot be closed',phoneID);
            end
            
            %%
            % Callback to stop recording ?
            %%
            
        end
        
        %% New Samples Available Function
        function newSamplesAvailable(obj, samples, phoneIDs)
            % Function to input samples
            %   samples: matrix of samples dim = (numberOfPhones,numberOfSamples)
            %   phoneIDs: cell of strings
            % Example (continued)
            %   s.newSamplesAvailable([[1 2 3 4];[9 8 7 6]], ['ID1' 'ID2'])
%             disp(samples);
%             disp(phoneIDs);
            for ii = 1:length(phoneIDs)
                phoneID = obj.ID2phone(phoneIDs{ii});
                obj.Buffer(:,phoneID) = [obj.Buffer(:,phoneID) samples(ii,:)];
            end
            
            % Might be handy to do some sanity checks here
            % And find a way to better structure the data
            
            %%
            % Call Update framesReady buffer
%             if ~isempty{buffer
%                 min(length())

%             SamplesPerFrame = round(obj.BufferLength/1000*obj.Fs);
%             if length(obj.Phones(1).samples) > SamplesPerFrame
%                 obj.updateBuffer();
%             end
            %%
            
        end

        %% Update Buffer Function
        function updateBuffer(obj)
            % Function update buffer
            SamplesPerFrame = round(obj.BufferLength/1000*obj.Fs);
            l = length(obj.Phones);
            dataFrame = zeros(l,SamplesPerFrame);
            for ii = 1:l
                dataFrame(ii) = obj.Buffer(1:SamplesPerFrame);
                obj.Phones(ii).samples(1:SamplesPerFrame) = [];
            end
            obj.Buffer(:,end+1:end+SamplesPerFrame) = dataFrame;
        end

        %% Read Buffer Function
        function data = readBuffer(obj, numFrames)
            % Function read buffer
            obj.FramesReady = length(obj.Buffer(1));
            if numFrames <= obj.FramesReady
                data = obj.Buffer(1:numFrames,:);
            elseif nargin
                warning('Not enough frames in buffer')
            end
        end
        
        %% Face Up Function
        function faceUp(obj, phoneID, faceUp)
            % Function set face up state of phone
            if ~isempty(obj.Phones)
                num = ID2phone(phoneID);
                if num
                    obj.Phones(num).faceUp = faceUp;
                else
                    warning('Phone %s is not stationary',phoneID);
                end
            else
                warning('Unknown phone id %s, Face Up, no phones connected', phoneID)
            end
        end

        %% Is Moving Function
        function isMoving(obj, phoneID, isMoving)
            % Function to set isMoving state
            if ~isempty(obj.Phones)
                num = ID2phone(phoneID);
                if num
                    obj.Phones(num).isMoving = isMoving;
                else
                    warning('Phone %s is not stationary',phoneID);
                end
            else
                warning('Unknown phone id %s, Moving, no phones connected', phoneID)
            end
        end

        %% Orientation Change Function
        function orientationChange(obj, phoneID, azimuth, elevation)
            % Function to set orientation
            if ~isempty(obj.Phones)
                num = ID2phone(phoneID);
                if num
                    obj.Phones(num).azimuth = azimuth;
                    obj.Phones(num).elevation = elevation;
                else
                    warning('Unknown phone id %s, Orientation', phoneID)
                end
            else
                warning('Unknown phone id %s, Orientation, no phones connected', phoneID)
            end
        end

        %% Get Phone IDs Function
        function phoneIDs = getPhoneIDs(obj)
            % Function to get phone IDs
            if ~isempty(obj.Phones)
                phoneIDs = {obj.Phones.phoneID};
            else
                phoneIDs = {};
            end
        end

        %% Get Locations Function
        function locations = getLocations(obj)
            % Function to get phone Locations
            
            % Return nStreaming-by-7 array. First colom means is streaming?
            
            if ~isempty(obj.Phones)
%                 locations = obj.Phones.location;
                locations = [ones(length(obj.Phones),1), zeros(length(obj.Phones),5), ones(length(obj.Phones),1)];
            else
                locations = {};
            end
        end

        %% ID2phone Function
        function num = ID2phone(obj, phoneID)
            % Function to find the right phone number for a phoneID
            num = 0;
            for ii = 1:length(obj.Phones)
                if strcmp(phoneID,obj.Phones(ii).phoneID)
                    num = ii;
                    return
                end
            end
%             if ~exist('num'); error(sprintf('PhoneID ''%s'' could not be matched to phone',phoneID)); end
        end
    end
end