classdef rec_play_ui < handle
    %% Computer audio Interface Class 
    %  This class will hold the Recording and Playbeck elements
    %% Constants
    properties (Constant)
        Name = 'Recording and Playback';
    end
    %% Properties
    properties
        Parent              % Handle of parent
        Channels
        PanPlayRec
        Tabs
    end
    %% Methods
    methods
        %% Scarlett Constuctor
        function obj = rec_play_ui(varargin)
            %% Parse Input
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
                obj.PanPlayRec = std_panel(obj.Parent, grid2pos([]),3);
                obj.PanPlayRec.Name = 'Playback and Recording';
                obj.PanPlayRec.Panel.Title = 'Playback and Recording';
                % Set tab titles
                obj.PanPlayRec.Tabs{1}.Title = 'Recording';
                obj.PanPlayRec.Tabs{2}.Title = 'Playback';
                obj.PanPlayRec.Tabs{3}.Title = 'Processing';
            elseif length(varargin{1}.PanPlayRec.Tabs) == 3
                obj.Parent = varargin{1};
                obj.Channels = obj.Parent.Channels;
            end
            
            %% Create Rec Play Panel
%             obj.PanPlayRec = std_panel(obj.Parent, grid2pos([]),3);
            % Add panels
%             obj.PanPlayRec.PanRec.CbChan = ;
            
            % Playback from: 
                % Recording source
                % Beamformers
                % File
                
            % Recording From:
                % Smartphones
                % USB
                % Mic
                
            % Processing:
                % File
            
                
%             %% Graphics Code
%             n=9;m=3;
%             obj.UI.TextInterface = uicontrol(obj.Parent,'Style','text',...
%                 'String','Audio Interface','Units','Normalized',...
%                 'Position',grid2pos([1,1, 1,1, m,n]));
%             obj.UI.PopupInterface = uicontrol(obj.Parent,'Style','popup',...
%                 'String',{obj.Info.input.Name},'Units','Normalized',...
%                 'Position',grid2pos([2,1, 2,1, m,n]),'Tag','I',...
%                 'Callback',@obj.recChanged_Callback);
%             obj.UI.TextNumChan = uicontrol(obj.Parent,'Style','text',...
%                 'String','Number of channels','Units','Normalized',...
%                 'Position',grid2pos([1,2, 1,1, m,n]));
%             obj.UI.PopupNumChan = uicontrol(obj.Parent,'Style','popup',...
%                 'String',{'1','2'},'Units','Normalized','Tag','N',...
%                 'Position',grid2pos([2,2, 1,1, m,n]),...
%                 'Callback',@obj.recChanged_Callback);
%             obj.UI.TextFs = uicontrol(obj.Parent,'Style','text',...
%                 'String','Fs [hz]','Units','Normalized',...
%                 'Position',grid2pos([1,3, 1,1, m,n]));
%             obj.UI.PopupFs = uicontrol(obj.Parent,'Style','popup',...
%                 'String',obj.FsOptions,'Units','Normalized',...
%                 'Position',grid2pos([2,3, 1,1, m,n]),'Tag','Fs',...
%                 'Callback',@obj.recChanged_Callback);
%             obj.UI.PbCreate = uicontrol(obj.Parent,'Style','pushbutton',...
%                 'String','Create','Units','Normalized',...
%                 'Position',grid2pos([3,3, 1,1, m,n]),'Callback',@obj.pbCreate_Callback);
%             obj.UI.TextRecHeader = uicontrol(obj.Parent,'Style','listbox',...
%                 'Units','Normalized','Position',grid2pos([1,4, 3,n-3, m,n]),...
%                 'String',{'Audio Recorder header','not loaded'});
%             obj.UI.PopupNumChan.Value = 2;
%             obj.UI.PopupFs.Value = 5;
            
        end
        
%         %% Popup Changed function
%         function recChanged_Callback(obj,~,~)
%             obj.Fs = str2double(obj.FsOptions{obj.UI.PopupFs.Value});
%             obj.Info = audiodevinfo;
%             obj.ID = obj.Info.input(obj.UI.PopupInterface.Value).ID;
%             obj.NChan = obj.UI.PopupNumChan.Value;
%             obj.UI.PbCreate.String = 'Update';
%         end
%         %% Create function
%         function pbCreate_Callback(obj,~,~)
%             if strcmp(obj.UI.PbCreate.String,'Update')
%                 obj.RecObj = [];
%             end
%             if isempty(obj.RecObj)
%                 obj.Fs = str2double(obj.FsOptions{obj.UI.PopupFs.Value});
%                 obj.Info = audiodevinfo;
%                 obj.ID = obj.Info.input(obj.UI.PopupInterface.Value).ID;
%                 obj.NChan = obj.UI.PopupNumChan.Value;
%                 obj.RecObj = audiorecorder(obj.Fs, obj.BitsPS, obj.NChan,obj.ID);
%                 obj.UI.PbCreate.String = 'Delete';
%                 header = {'Audio Recorder header',...
%                     sprintf('SampleRate: %i',obj.RecObj.SampleRate),...
%                     sprintf('BitsPerSample: %i',obj.RecObj.BitsPerSample),...
%                     sprintf('NumberOfChannels: %i',obj.RecObj.NumberOfChannels),...
%                     sprintf('DeviceID: %i',obj.RecObj.DeviceID),...
%                     sprintf('CurrentSample: %i',obj.RecObj.CurrentSample),...
%                     sprintf('TotalSamples: %i',obj.RecObj.TotalSamples),...
%                     ['Running: ',obj.RecObj.Running],...
%                     sprintf('TimerPeriod: %d',obj.RecObj.TimerPeriod)};
%             else
%                 obj.UI.PbCreate.String = 'Create';
%                 header = {'Audio Recorder header','not loaded'};
%                 obj.RecObj = [];
%             end
%             obj.UI.TextRecHeader.String = header;
%         end
    end
end