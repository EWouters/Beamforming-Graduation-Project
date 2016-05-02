classdef bfsave
    %% bfsave Class
    %  Class to save audio samples to file as .mat or .wav (or others)
    %  Other data can be stored in the wav comment
    %  Locations and phone IDs can easily be retrieved later
    %%  Example:
    %   obj1 = bfsave
    %   obj1.save([1,2,3,4],1)
    %%  Example 2
    %   obj = bfsave
    %   obj.NChan = 4
    %   obj.ChanNames = {'ID1','ID2','ID3','ID4'}
    %   obj.Locations = [ones(obj.NChan,1), zeros(obj.NChan,5), ones(obj.NChan,1)]
    %   obj.vars2str(obj.ChanNames, obj.Locations)
    %%

    %% Properties
    properties
        FileName       % Name of the audio file to save including extention
        FilePath       % Path of the audio file to save
        Title          % Title of recording
        Comment        % The Comment can be used to hold the locations
        BitsPerSample = 16;
        Fs
        NChan
        Locations
        ChanNames
    end
    %% Methods
    methods
        function save(obj,samples,fs,varargin)
            % Function to save data to file
            %% Set Title
            if isempty(obj.Title)
                obj.Title = sprintf('Recorded on %s',datestr(now));
            end
            %% Load file name if empty
            if isempty([obj.FileName obj.FilePath])
                [name1,path1] = uiputfile(...
                    {'*.wav','Waveform Audio File Format (*.wav)';...
                    '*.mat','MAT-files (*.mat)';...
                    '*.*',  'All Files (*.*)'},...
                    'Save File',fullfile(pwd, '\files', sprintf('Recording %s',datestr(now))));
                if ~ischar(name1) || ~ischar(path1)
                    warning('Invalid file selected.');
                    return
                else
                    obj.FileName = name1;
                    obj.FilePath = path1;
                end
            end
            %% Parse varargin
            nargin
            
            %% Write to file
            if isempty(strfind(obj.FileName,'.mat'))
                audiowrite(fullfile(obj.FilePath,obj.FileName),samples,fs,...
                    'BitsPerSample',16,'Comment',obj.Comment,...
                    'Title',obj.Title,'Artist','TU Delft Beamforming BSc Graduation Project EE');
            else
                audio.y = samples;
                audio.Fs = fs;
                audio.BitsPerSample = 16;
                audio.Comment = mat2str(locations);
                save(fullfile(obj.FilePath,obj.FileName),'audio');
            end
        end
        
        %% Function to convert variables to string
        function comment = vars2str(obj, varargin)
            % input like vars2str(ChanNames,Locations,'Comment')
            if nargin >= 2
                if ischar(varargin{1})
                    comment = ['Channel Names:\n' mat2str(varargin{1}{:}) ':\n']; % add names
                end
            end
            if nargin >= 3
                if ischar(varargin{2})
                    comment = [comment varargin{2} ':\n']; % add comment
                else isnumeric(varargin{2})
                    comment = [comment 'Channel Locations:\n' mat2str(varargin{2}) ':\n']; % add locations
                end
            end
            for ii = 4:nargin %#ok<*AGROW>
                if ischar(varargin{ii})
                    comment = [comment varargin{ii} ':\n']; % add comment
                else isnumeric(varargin{2})
                    comment = [comment mat2str(varargin{ii}) ':\n']; % add other variable
                end
            end
        end
        %% Function to get locations from comment string
        function locations = str2vars(comment)
            commentCell = strsplit(comment, ':');
            locations = str2num(commentCell{4}(3:end-2));
        end
    end
end