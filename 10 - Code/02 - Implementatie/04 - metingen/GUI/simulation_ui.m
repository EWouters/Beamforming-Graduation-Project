classdef simulation_ui < handle
    %% Computer audio Interface Class 
    %  This class will handle the simulation
    %% Constants
    properties (Constant)
        Name = 'Simulation Parameters';
    end
    %% Properties
    properties
        MainObj
        Parent              % Handle of parent
        UI                  % Property with all graphics handles
        Fs = 48000;         % Sample Frequency
        NChanIn = 0;        % Number of Sources
        NChanOut = 0;       % Number of Mics
        MicNames
        SourceNames
        SourcePos           % Signal positions [x y z]
        MicPos              % Microphone positions [x y z az el up]
        StartTime = 0;      % Start time with respect to beginning of wav file
        EndTime = 5;        % End time with respect to beginning of wav file
        Update
        Info = 'Simulation description and other parameters'
    end
    %% Methods
    methods
        %% Simulation Constuctor
        function obj = simulation_ui(parent, mainObj)
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
                obj.MainObj.DataBuffer.load([]);
                help simulation_ui
            end
            
            % Graphics Code
            obj.UI = graphicsCode(obj);
            
%             obj.updateSources();
            
            % Link handle of update callback
%             obj.Update = @selectionChanged_Callback;
            
            % Debug
            assignin('base','obj',obj)
        end
        
        %% Process Simulation Data
        function propSim1(obj,~,~)
            % Update data in object
            obj.MicNames = obj.UI.MicSelector.ChanNames;
            obj.NChanOut = size(obj.UI.MicSelector.ChanNames,1);
            obj.SourceNames = obj.UI.SourceSelector.ChanNames;
            obj.NChanIn = size(obj.UI.SourceSelector.ChanNames,1);
            obj.MicPos = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),1:3);
            obj.SourcePos =  obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);
            
            if obj.NChanIn && obj.NChanOut
                % Run simulation
                tTrim = [obj.StartTime obj.EndTime];    % Set the time interval to trim down to
                sigIn = trimSig(obj.MainObj.DataBuffer.getAudioData(obj.SourceNames), obj.Fs, tTrim);
                sigOut = simRec(sigIn, obj.SourcePos', obj.MicPos', obj.Fs, obj.SpeedSound);

                % Generate output names
                for ii = 1:obj.NChanOut %#ok<FORFLG>
                    micOutNames{ii} = ['Sim ' obj.MicNames{ii}]; %#ok<PFBNS>
                end

                % Write to data buffer
                obj.MainObj.DataBuffer.addSamples(sigOut,micOutNames,1,1);
            end
        end
        
        function selectionChanged_Callback(obj,~,~)
            obj.StartTime = max(1,str2double(obj.UI.edStartTime.String));
            obj.EndTime = min(obj.MainObj.DataBuffer.TotalSamples,str2double(obj.UI.edEndTime.String));
            obj.MainObj.DataBuffer.SpeedSound = str2double(obj.UI.edSpeedSound.String);
            obj.UI.edStartTime.String = mat2str(obj.StartTime); % Write back verified data
            obj.UI.edEndTime.String =  mat2str(obj.EndTime); % Write back verified data
            obj.UI.edSpeedSound.String =  mat2str(obj.MainObj.DataBuffer.SpeedSound); % Write back verified data
        end
        
        %% Simulation Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % Simulation UI panel
            % Tabs
            UI.Panel = std_panel(obj.Parent, grid2pos([]),obj.Name,{'Run','Microphone Channels','Source Channels'});
            UI.MicSelector = std_selector_ui(UI.Panel.Tabs{2},obj.MainObj,'Microphone Channels');
            UI.SourceSelector = std_selector_ui(UI.Panel.Tabs{3},obj.MainObj,'Source Channels');
            % Controls
            x=4;y=7;
            UI.txInfo = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String',obj.Info,'Units','Normalized',...
                'Position',grid2pos([1,1, x,y-3, x,y]));
            UI.txStartTime = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String','Start Time','Units','Normalized',...
                'Position',grid2pos([1,y-1, 1,1, x,y]));
            UI.edStartTime = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
                'String',obj.StartTime,'Units','Normalized',...
                'Position',grid2pos([2,y-1, 1,1, x,y]),...
                'Callback',@selectionChanged_Callback);
            UI.txEndTime = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String','End Time','Units','Normalized',...
                'Position',grid2pos([3,y-1, 1,1, x,y]));
            UI.edEndTime = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
                'String',obj.EndTime,'Units','Normalized',...
                'Position',grid2pos([4,y-1, 1,1, x,y]),...
                'Callback',@selectionChanged_Callback);
            UI.pbSimulate1 = uicontrol(UI.Panel.Tabs{1},'Style','pushbutton','Tag','SimSource',...
                'String','Simulate1','Units','Normalized',...
                'Position',grid2pos([1,y, 2,1, x,y]),...
                'Callback',@obj.propSim1);
            UI.pbSimulate2 = uicontrol(UI.Panel.Tabs{1},'Style','pushbutton','Tag','SimSource',...
                'String','Simulate2','Units','Normalized',...
                'Position',grid2pos([3,y, 2,1, x,y]),...
                'Callback',@obj.propSim2);
            
            UI.txSpeedSound = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String','Speed of sound','Units','Normalized',...
                'Position',grid2pos([1,y-3, 1,1, x,y]));
            UI.edSpeedSound = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
                'String',obj.MainObj.DataBuffer.SpeedSound,'Units','Normalized',...
                'Position',grid2pos([2,y-3, 1,1, x,y]),...
                'Callback',@selectionChanged_Callback);
        end
        
    end
end