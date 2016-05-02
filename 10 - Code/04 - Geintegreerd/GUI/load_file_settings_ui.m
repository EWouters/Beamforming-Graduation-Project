classdef load_file_settings_ui < handle
    % LOAD_FILE_SETTINGS_UI Holds the gui elements for the load file settings panel
    %
    %   LOAD_FILE_SETTINGS_UI() create ui in new figure
    %   LOAD_FILE_SETTINGS_UI(PARENT) create ui in parent panel
    %   LOAD_FILE_SETTINGS_UI(PARENT, MAINOBJ) create ui with handle to main object
    %
    % Example 1:
    %   obj = load_file_settings_ui
    %
    % Example 2:
    %   Parent = figure
    %   obj = load_file_settings_ui(Parent)
    %
    % LOAD_FILE_SETTINGS_UI Methods:
    %   load_file_settings_ui - Constructor
    %   pbFilePath_Callback   - Add selectec file to dat buffer
    %   graphicsCode          - Graphics Generation Code
    %
    % LOAD_FILE_SETTINGS_UI Properties:
    %   Parent    - Handle of panel to place ui in
    %   MainObj   - Handle of main object
    %   Name      - Name of UI
    %   FilePath  - File Path
    %   FileName  - File name
    %   Info      - Audio info struct
    %   UI        - Cell UIs for the options
    %   Tag       - Tag to find object
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
    %   See also BF_DATA, MAIN_WINDOW
    
    %% Properties
    properties
        Parent              % Handle of panel to place ui in
        MainObj             % Handle of main object
        Name = 'Load File'; % Name of UI
        FilePath = [pwd filesep 'files']; % File Path
        FileName = 'Source1.wav'; % File name
        Info                % Audio info struct
        UI                  % Cell UIs for the options
        Tag = 'load_file';  % Tag to find object
    end
    %% Methods
    methods
        function obj = load_file_settings_ui(parent, mainObj)
            % Parse Input
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
            elseif nargin >= 1
                if ishandle(parent)
                    obj.Parent = parent;
                else
                    warning(['First argument needs to be a handle,'...
                        'new figure created.']);
                    obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
                end
            end
            if nargin >= 2
                obj.MainObj = mainObj;
            else
                obj.MainObj.DataBuffer = bf_data;
            end
            
            % Graphics Code
            obj.UI = obj.graphicsCode();
            
            % Debug
%             assignin('base','obj',obj)
        end
        
        %% FilePath Add function
        function pbFilePath_Callback(obj,~,~)
            file1 = bf_data;
            file1.load([]);
            obj.UI.edFileName.String = file1.FileName;
            if file1.IsInitialized
                if isempty(strfind(file1.FileName,'.mat'))
                    obj.Info = audioinfo(fullfile(file1.FilePath,file1.FileName));
                    obj.UI.lbHeader.String = sprintf(['Audio file loaded'...
                        '\nTitle:\t', obj.Info.Title,...
                        '\nNumChannels:\t', mat2str(obj.Info.NumChannels),...
                        '\nSampleRate:\t', mat2str(obj.Info.SampleRate),...
                        '\nTotalSamples:\t', mat2str(obj.Info.TotalSamples),...
                        '\nDuration:\t', mat2str(obj.Info.Duration),...
                        '\nCompression:\t', obj.Info.CompressionMethod,...
                        '\nComment:\t', obj.Info.Comment,...
                        '\nArtist:\t', obj.Info.Artist,...
                        '\nBitsPerSample:\t', mat2str(obj.Info.BitsPerSample)]);
                else
                    obj.UI.lbHeader.String = sprintf(['.mat file loaded'...
                        '\nTitle:\t', file1.SourceID,...
                        '\nNumChannels:\t', mat2str(file1.NChan),...
                        '\nSampleRate:\t', mat2str(file1.Fs),...
                        '\nTotalSamples:\t', mat2str(file1.TotalSamples),...
                        '\nDuration:\t', mat2str(file1.TotalSamples/file1.Fs),...
                        '\nCompression:\tbf_data',...
                        '\nComment:\t', file1.Comment,...
                        '\nArtist:\t', '-',...
                        '\nBitsPerSample:\t', mat2str(file1.BitsPerSample)]);
                end
                obj.MainObj.DataBuffer.addSamples(file1.AudioData,file1.ChanNames,1);
                obj.MainObj.DataBuffer.setLocations(file1.Locations,file1.ChanNames);
            else
                obj.UI.lbHeader.String = 'No file selected';
            end
            clear file1
        end
        
        %% Load File Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % Load File UI panel
            m=7;n=5;
            UI.txFileName = uicontrol(obj.Parent,'Style','text',...
                'String','File Name','Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, m,n]));
            UI.edFileName = uicontrol(obj.Parent,'Style','edit',...
                'String','Select a file...','Units','Normalized',...
                'Position',grid2pos([2,1, 5,1, m,n]));
            UI.pbAdd = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Add','Callback',@obj.pbFilePath_Callback,...
                'Units','normalized','Position',grid2pos([7,1, 1,1, m,n]));
            UI.lbHeader = uicontrol(obj.Parent,'Style','listbox',...
                'Units','Normalized','Position',grid2pos([1,2, 1,4, 1,n]),...
                'String',{'File header:','not loaded'});
        end
        
    end
end