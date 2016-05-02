classdef bf_file < handle
    %% bf_file Class
    %  Class to save and load audio samples in files as .mat or .wav or
    %  other audio formats
    %  Other data can be stored in the wav comment
    %  Locations and phone IDs can easily be retrieved later
    %%  Example:
    %   obj = bf_file
    %   obj.save([1,2,3,4],1)
    %%  Example 2
    %   obj = bf_file
    %   obj.NChan = 4
    %   obj.ChanNames = {'ID1','ID2','ID3','ID4'}
    %   obj.Locations = [ones(obj.NChan,1), rand(obj.NChan,5), ones(obj.NChan,1)]
    %   obj.save([1,2,3,4],1,obj.Locations)
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
        %% Constructor
        function obj = bf_file
            obj.Title = sprintf('Recorded on %s',datestr(now));
            obj.NChan = 1;
            obj.Locations = [0,0,0,0,0,0,0];
            obj.ChanNames = 'Name 1';
            obj.Fs = 48000;
        end
        
        %% Save function
        function save(obj,y,Fs,varargin)
            % Function to save data to file
            % Get file name if empty
            if isempty([obj.FileName obj.FilePath])
                [name1,path1] = uiputfile(...
                    {'*.wav','Waveform Audio File Format (*.wav)';...
                    '*.mat','MAT-files (*.mat)';...
                    '*.*',  'All Files (*.*)'},...
                    'Save File',fullfile(pwd, '\files', sprintf('Recording %s',datestr(now, 'yyyy-mm-dd hhuMM'))));
                if ~ischar(name1) || ~ischar(path1)
                    warning('Invalid file selected.');
                    return
                else
                    obj.FileName = name1;
                    obj.FilePath = path1;
                end
            end
            % Parse varargin (only locations for now)
            if nargin == 1
                obj.Locations = varargin{1};
            end
            obj.Comment = mat2str(obj.Locations);
            obj.Fs = Fs;
            %% Write to file
            if isempty(strfind(obj.FileName,'.mat'))
                % Save as audio file
                audiowrite(fullfile(obj.FilePath,obj.FileName),y,obj.Fs,...
                    'BitsPerSample',16,'Comment',obj.Comment,...
                    'Title',obj.Title,'Artist','TU Delft Beamforming BSc Graduation Project EE');
            else
                % Save as mat file
                obj.NChan = size(y,2);
                obj.Fs = Fs;
                BitsPerSample = obj.BitsPerSample; %#ok<*PROP,*NASGU>
                Comment = obj.Comment;
                Locations = obj.Locations;
                save(fullfile(obj.FilePath,obj.FileName),'y','Fs','BitsPerSample','Comment','Locations');
            end
        end
        
        %% Load function
        function y = load(obj)
            % Function to load data from file
            % Get file name if empty
            if isempty([obj.FileName obj.FilePath])
                [name1,path1] = uigetfile(...
                    {'*.wav','Waveform Audio File Format (*.wav)';...
                    '*.mat','MAT-files (*.mat)';...
                    '*.*',  'All Files (*.*)'},...
                    'Save File',fullfile(pwd, '\files'));
                if ~ischar(name1) || ~ischar(path1)
                    warning('Invalid file selected.');
                    return
                else
                    obj.FileName = name1;
                    obj.FilePath = path1;
                end
            end
            % Load file
            obj.Locations = mat2str(obj.Locations);
            if ~isempty([obj.FilePath obj.FileName])
                if isempty(strfind(obj.FileName,'.mat'))
                    [y, obj.Fs] = audioread(fullfile(obj.FilePath,obj.FileName));
                    info = audioinfo(fullfile(obj.FilePath,obj.FileName));
                    obj.NChan = info.NumChannels;
                    obj.Fs = info.SampleRate;
                    obj.Title = info.Title;
                    obj.BitsPerSample = info.BitsPerSample;
                    locs = str2num(info.Comment); %#ok<ST2NM>
                    if isempty(locs) || size(locs,1) ~= obj.NChan || size(locs,2) ~= 7
                        obj.Comment = info.Comment;
                    else
                        obj.Locations = locs;
                    end
                else
                    load(fullfile(obj.FilePath,obj.FileName));
                    if exist('y','var')
                        disp('Samples loaded')
                    end
                    if exist('Fs','var')
                        obj.Fs = Fs; %#ok<*CPROP>
                    end
                    if exist('BitsPerSample','var')
                        obj.BitsPerSample = BitsPerSample;
                    end
                    if exist('Comment','var')
                        obj.Comment = Comment;
                    end
                    if exist('Locations','var')
                        obj.Locations = Locations;
                    end
                end
            end
        end
    end
end