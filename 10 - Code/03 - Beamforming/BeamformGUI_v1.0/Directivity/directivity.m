classdef directivity < handle
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
        Buffer
        Tag = 'bfcom1'
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = directivity
%             v = load('data.mat')
%             
%             v.y
            
            obj.Defaults.phoneID = 'Default';    % Identification string for Phone
            obj.Defaults.location = [0,0,0];     % (x,y,z) coordinates of Phone
            obj.Defaults.azimuth = 0;            % Angle of microphone relative to magnetic north (counter-clockwise positive)
            obj.Defaults.elevation = 0;          % Angle with respect to horizon (upward positive)
            obj.Defaults.faceUp = 1;             % Screen of phone is on the top if faceUp = 1
            obj.Defaults.isMoving = 0;           % 1 if phone is moving
            obj.Defaults.isStreaming = 0;        % 1 if phone is streaming
            obj.Defaults.samples = {};           % Array of samples. samples(end,:) gives most recent sample frame
        end
        
        %% Other functions can come here
        function example1(obj)
            disp('example1 called')
            obj.Tag = 'tag changed';
        end
    end
end