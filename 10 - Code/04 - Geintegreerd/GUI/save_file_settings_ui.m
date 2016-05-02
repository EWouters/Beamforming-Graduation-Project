classdef save_file_settings_ui < handle
    % SAVE_FILE_SETTINGS_UI Holds the gui elements for the save file settings panel
    %
    %   SAVE_FILE_SETTINGS_UI() create ui in new figure
    %   SAVE_FILE_SETTINGS_UI(PARENT) create ui in parent panel
    %   SAVE_FILE_SETTINGS_UI(PARENT, MAINOBJ) create ui with handle to main object
    %
    % Example 1:
    %   obj = save_file_settings_ui
    %
    % Example 2:
    %   Parent = figure
    %   obj = save_file_settings_ui(Parent)
    %
    % SAVE_FILE_SETTINGS_UI Methods:
    %   pbUpdate_Callback - PushButton Update channel names Callback
    %   pbAdd_Callback    - PushButton Add Callback
    %   pbRemove_Callback - PushButton Remove Callback
    %
    % SAVE_FILE_SETTINGS_UI Properties:
    %   Parent    - Handle of panel to place ui in
    %   MainObj   - Handle of main object
    %   Name      - Name of UI
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
        Parent              % Handle of parent
        MainObj
        Name = 'Load File'; % Name of UI
        UI                  % Cell UIs for the options
        Tag = 'save_file';
    end
    %% Methods
    methods
        %% UI Constuctor
        function obj = save_file_settings_ui(parent, mainObj)
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
                obj.MainObj.DataBuffer = bf_data(obj.MainObj);
                obj.MainObj.UI.PlotSettings = std_selector_ui(figure,obj.MainObj);
                obj.MainObj.DataBuffer.setNChan(1);
                obj.MainObj.DataBuffer.setTotalSamples(48000);
                obj.MainObj.UI.PlotWindow.Axes{1}.XLim = [0,100];
            end
            
            % Graphics Code
            obj.UI = obj.graphicsCode();
            
            % Debug
%             assignin('base','obj',obj)
        end
        
        %% Save Work callback function
        function pb_Callback(obj,src,~)
            switch src.String
                case 'Save in Workspace'
                    assignin('base','DataBuffer',obj.MainObj.DataBuffer);
                case 'Save as .mat'
%                     if ~isempty(strfind(obj.MainObj.DataBuffer.FileName,'.mat'))
%                         obj.MainObj.DataBuffer.FileName = 'Source1.mat';
%                     end
                    obj.MainObj.DataBuffer.FileName = [];
                    obj.MainObj.DataBuffer.save(obj.UI.Selector.ChanNames);
                case 'Save as .wav'
%                     if ~isempty(strfind(obj.MainObj.DataBuffer.FileName,'.wav'))
%                         obj.MainObj.DataBuffer.FileName = 'Source1.wav';
%                     end
                    obj.MainObj.DataBuffer.save(obj.UI.Selector.ChanNames);
                case 'Clear Channels'
                    obj.MainObj.DataBuffer.setNChan(0);
                    obj.MainObj.DataBuffer.setTotalSamples(0);
                case 'Save Plot Data as .mat'
                    obj.MainObj.DataBuffer.FileName = [];
                    firstSample = ceil(max(1,obj.MainObj.UI.PlotAudio.Axes{1}.XLim(1)*obj.MainObj.DataBuffer.Fs));
                    lastSample = floor(min(obj.MainObj.DataBuffer.TotalSamples,obj.MainObj.UI.PlotAudio.Axes{1}.XLim(2)*obj.MainObj.DataBuffer.Fs));
                    obj.MainObj.DataBuffer.save(obj.MainObj.UI.PlotSettings.ChanNames, firstSample, lastSample);
                case 'Save Plot Data as .wav'
                    obj.MainObj.DataBuffer.FileName = [];
                    firstSample = ceil(max(1,obj.MainObj.UI.PlotAudio.Axes{1}.XLim(1)*obj.MainObj.DataBuffer.Fs));
                    lastSample = floor(min(obj.MainObj.DataBuffer.TotalSamples,obj.MainObj.UI.PlotAudio.Axes{1}.XLim(2)*obj.MainObj.DataBuffer.Fs));
                    obj.MainObj.DataBuffer.save(obj.MainObj.UI.PlotSettings.ChanNames, firstSample, lastSample);
                otherwise
            end
        end
        
        %% Save File Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % Save File UI panel
            m=3;n=7;
            UI.PanSelector = uipanel('Parent',obj.Parent,'Position', grid2pos([1,1,m,n-2,m,n]));
            UI.Selector = std_selector_ui(UI.PanSelector,obj.MainObj,'Save File Channels');
            obj.UI.pbSaveWork = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Save in Workspace','Callback',@obj.pb_Callback,...
                'Units','normalized','Position',grid2pos([1,n-1,1,1,m,n]));
            obj.UI.pbSaveMat = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Save as .mat','Callback',@obj.pb_Callback,...
                'Units','normalized','Position',grid2pos([2,n-1,1,1,m,n]));
            obj.UI.pbSaveWav = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Save as .wav','Callback',@obj.pb_Callback,...
                'Units','normalized','Position',grid2pos([3,n-1,1,1,m,n]));
            obj.UI.pbClear = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Clear Channels','Callback',@obj.pb_Callback,...
                'Units','normalized','Position',grid2pos([1,n,1,1,m,n]));
            obj.UI.pbSaveWindowMat = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Save Plot Data as .mat','Callback',@obj.pb_Callback,...
                'Units','normalized','Position',grid2pos([2,n,1,1,m,n]));
            obj.UI.pbSaveWindowWav = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Save Plot Data as .wav','Callback',@obj.pb_Callback,...
                'Units','normalized','Position',grid2pos([3,n,1,1,m,n]));
        end
        
    end
end