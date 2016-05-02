% Load File Settings Selection UI Class.
%  Example1
%   obj = load_file_settings_ui
%  Example2
%   Parent = figure
%   obj = load_file_settings_ui(Parent)

%   Copyright 2015 BabForming.

classdef load_file_settings_ui < handle
%% Source Settings Selection UI Class
    %  This class holds the gui elements for the source settings selection panel
    %% Properties
    properties
        Parent              % Handle of parent
        Name = 'Load File'; % Name of UI
        FilePath
        FileName
        Info
        Data
        UI                  % Cell UIs for the options
        Tag = 'load_file';
    end
    %% Methods
    methods
        %% UI Constuctor
        function obj = load_file_settings_ui(varargin)
            % Set defaults
            obj.FilePath = [pwd,'\files'];
            obj.FileName = 'Source1.wav';
            
            %% Parse Input
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
            else
                if ishandle(varargin{1})
                    obj.Parent = varargin{1};
                else
                    warning(['First argument needs to be a handle,'...
                        'new figure created.']);
                    obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
                end
            end
            
            %% File UI panel
            n=5;m=7;
            obj.UI{1} = uicontrol(obj.Parent,'Style','text',...
                'String','File Name','Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, m,n]));
            obj.UI{2} = uicontrol(obj.Parent,'Style','edit',...
                'String','Select a file...','Units','Normalized',...
                'Position',grid2pos([2,1, 5,1, m,n]));
            obj.UI{3} = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Add','Callback',@obj.pbFilePath_Callback,...
                'Units','normalized','Position',grid2pos([7,1, 1,1, m,n]));
            obj.UI{4} = uicontrol(obj.Parent,'Style','listbox',...
                'Units','Normalized','Position',grid2pos([1,2, 1,4, 1,n]),...
                'String',{'File header:','not loaded'});
        end
        %% FilePath Add function
        function pbFilePath_Callback(obj,~,~)
            file1 = bf_file;
            obj.Data = file1.load;
            obj.Info = audioinfo(fullfile(file1.FilePath,file1.FileName));
            obj.UI{2}.String = file1.FileName;
            obj.UI{4}.String = sprintf(['File loaded'...
                '\nTitle:\t', obj.Info.Title,...
                '\nNumChannels:\t', mat2str(obj.Info.NumChannels),...
                '\nSampleRate:\t', mat2str(obj.Info.SampleRate),...
                '\nTotalSamples:\t', mat2str(obj.Info.TotalSamples),...
                '\nDuration:\t', mat2str(obj.Info.Duration),...
                '\nCompression:\t', obj.Info.CompressionMethod,...
                '\nComment:\t', obj.Info.Comment,...
                '\nArtist:\t', obj.Info.Artist,...
                '\nBitsPerSample:\t', mat2str(obj.Info.BitsPerSample)]);
        end
        
    end
end