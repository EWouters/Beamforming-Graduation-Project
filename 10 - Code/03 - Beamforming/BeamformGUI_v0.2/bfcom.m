classdef bfcom < handle
%% bfcom class
% Class to answer calls from Man in the Middle.
%% Example 1
%   s = bfcom;
%   s.orientationChange('phoneID', 'azimuth', 'elevation');
%   s.phones(2) = s.phones(1); s.phones(3) = s.phones(1);
%   s.phones(2).phoneID = 'ID2';
%   s.phones(3).phoneID = 'ID3';
%   disp({s.phones.phoneID});
%   locs = {s.phones.location};
%   disp(locs{1});
%% Example 2
%   s = bfcom;s.phones(2) = s.phones(1); s.phones(3) = s.phones(1);s.phones(2).phoneID = 'ID2';s.phones(3).phoneID = 'ID3';s.ID2phone('ID2')
%   s.newSamplesAvailable([[1 2 3 4];[9 8 7 6]], {'ID1' 'ID2'})
%   s.newConnection('ID99',1,2*pi)
%   s.orientationChange('ID99', pi, pi/2)
%   s.lostConnection('ID99')

    %% Properties
    properties
        defaults    % default phone properties
        phones      % array of phone properties
        buffer
        Tag = 'bfcom1'
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = bfcom
            obj.phones(1).phoneID = 'ID1';        % Identification string for Phone
            obj.phones(1).location = [0,0,0];     % (x,y,z) coordinates of Phone
            obj.phones(1).azimuth = 0;            % Angle of microphone relative to magnetic north (counter-clockwise positive)
            obj.phones(1).elevation = 0;          % Angle with respect to horizon (upward positive)
            obj.phones(1).faceUp = 1;             % Screen of phone is on the top if faceUp = 1
            obj.phones(1).isMoving = 0;           % 1 if phone is moving
            obj.phones(1).samples = [];           % Array of samples. samples(end,:) gives most recent sample frame
            obj.defaults = obj.phones(1);         % Store defaults for when a new phone is added
        end
        
        
        %% New Samples Available Function
        function newSamplesAvailable(obj, samples, phoneIDs)
        % Function to input samples
        %   samples: matrix of samples dim = (numberOfPhones,numberOfSamples)
        %   phoneIDs: cell of strings
        % Example (continued)
        %   s.newSamplesAvailable([[1 2 3 4];[9 8 7 6]], {'ID1' 'ID2'})
%             disp(samples);
%             disp(phoneIDs);
            for ii = 1:length(phoneIDs)
                obj.phones(obj.ID2phone(phoneIDs{ii})).samples(end+1,:) = samples(ii,:);
            end
            
            % Might be handy to do some sanity checks here
            % And find a way to better structure the data
            
        end

        %% New Connection Function
        function newConnection(obj, phoneID, azimuth, elevation)
        % Function to add phone to array
%             disp(phoneID);
%             disp(azimuth);
%             disp(elevation);
            if ~obj.ID2phone(phoneID)
                obj.phones(end+1) = obj.defaults;
                obj.phones(end).phoneID = phoneID;
                obj.phones(end).azimuth = azimuth;
                obj.phones(end).elevation = elevation;
            else
                warning('connection ID %i is already taken',phoneID);
            end
        end

        %% Lost Connection Function
        function lostConnection(obj, phoneID)
        % Function to remove phone from array
%             disp(phoneID);
            phNum = obj.ID2phone(phoneID);
            if phNum
                obj.phones(phNum) = [];
            else
                warning('Connection ID ''%s'' does not exist so it cannot be closed',phoneID);
            end
        end

        %% Face Up Function
        function faceUp(obj, phoneID, faceUp)
        % Function to let algorithm know whether the phone is screen-up
            obj.phones(obj.ID2phone(phoneID)).faceUp = faceUp;
        end

        %% Is Moving Function
        function isMoving(obj, phoneID, isMoving)
        % Function to let algorithm know that phone not stationary
            obj.phones(obj.ID2phone(phoneID)).isMoving = isMoving;
        end

        %% Orientation Change Function
        function orientationChange(obj, phoneID, azimuth, elevation)
        % Function to update orientation
            obj.phones(obj.ID2phone(phoneID)).azimuth = azimuth;
            obj.phones(obj.ID2phone(phoneID)).elevation = elevation;
        end

        %% ID2phone Function
        function num = ID2phone(obj, phoneID)
        % Function to find the right phone number for a phoneID
            for ii = 1:length(obj.phones)
                if strcmp(phoneID,obj.phones(ii).phoneID)
                    num = ii;
                    return
                else
                    num = 0;
                end
            end
%             if ~exist('num')
%                 error(sprintf('PhoneID ''%s'' could not be matched to phone',phoneID));
%             end
        end
    end
end