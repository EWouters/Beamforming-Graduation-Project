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
        RoomDims = [6.85 3.95 3.2];
        Offset = [1.25 2.20 0.70];  % Offset of the room [x y z] in m
        alphas = [0.54 -0.56 0.58 -0.53 -0.55 0.57];        % Reflection coefficients [x1 x2 y1 y2 z1 z2]
        reverb = true;                                      % Reverberations on/off
        SNR  = 60;                                          % iid noise SNR in dB.
        PosErr  = 0;                                        % max random position error
        PlotRIR = true;
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
%             obj.Update = @obj.selectionChanged_Callback;
            
            % Debug
%             assignin('base','obj',obj);
        end
        
        %% Process Simulation Data
        function propSim1(obj,~,~)
            % Update data in object
            obj.MicNames = obj.UI.MicSelector.ChanNames;
            obj.NChanOut = size(obj.UI.MicSelector.ChanNames,2);
            obj.MicPos = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),1:3);
            
            obj.SourceNames = obj.UI.SourceSelector.ChanNames;
            obj.NChanIn = size(obj.UI.SourceSelector.ChanNames,2);
            obj.SourcePos =  obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);
            
            if obj.NChanIn && obj.NChanOut
                % Run simulation
%                 tTrim = [obj.StartTime obj.EndTime];    % Set the time interval to trim down to
%                 sigIn = trimSig(obj.MainObj.DataBuffer.getAudioData(obj.SourceNames), obj.Fs, tTrim);
                sigIn = obj.MainObj.DataBuffer.getAudioData(obj.SourceNames);
                sigOut = simRec(sigIn, obj.SourcePos', obj.MicPos', obj.Fs, obj.MainObj.DataBuffer.SpeedSound);

                % Generate output names
                for ii = 1:obj.NChanOut %#ok<FORFLG>
                    micOutNames{ii} = ['Sim ' obj.MicNames{ii}];
                end

                % Write to data buffer
                obj.MainObj.DataBuffer.addSamples(sigOut,micOutNames,1,1);
            end
        end
        
        %% Process Simulation Data
        function propSim2(obj,~,~)
            % Update data in object
            obj.MicNames = obj.UI.MicSelector.ChanNames;
            obj.NChanOut = size(obj.UI.MicSelector.ChanNames,2);
            obj.MicPos = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),1:3);
            
            obj.SourceNames = obj.UI.SourceSelector.ChanNames;
            obj.NChanIn = size(obj.UI.SourceSelector.ChanNames,2);
            obj.SourcePos =  obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);
            
            if obj.PosErr
                obj.MicPos = obj.MicPos + obj.PosErr*randn(size(obj.MicPos));
                obj.SourcePos = obj.SourcePos + obj.PosErr*randn(size(obj.SourcePos));
                %{
                obj.MicPos
                obj.SourcePos
                %}
            end
            
            
            if obj.NChanIn && obj.NChanOut
                % Run simulation
%                 % Test parameters
%                 tTrim = [obj.StartTime obj.EndTime];    % Set the time interval to trim down to
%                 simTime = obj.EndTime - obj.StartTime;
%                 sigIn = trimSig(obj.MainObj.DataBuffer.getAudioData(obj.SourceNames), obj.Fs, tTrim);
                sigIn = obj.MainObj.DataBuffer.getAudioData(obj.SourceNames);
                sigOut = simRec2(sigIn, obj.SourcePos, obj.MicPos, obj.Fs, obj.MainObj.DataBuffer.SpeedSound, obj.RoomDims, obj.Offset, obj.alphas, obj.reverb, obj.SNR, obj.PosErr, obj.PlotRIR);

                % Generate output names
                for ii = 1:obj.NChanOut %#ok<FORFLG>
                    micOutNames{ii} = ['Sim ' obj.MicNames{ii}];
                end

                % Write to data buffer
                obj.MainObj.DataBuffer.setLocations(obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),:),micOutNames,1);
                obj.MainObj.DataBuffer.addSamples(sigOut,micOutNames,1,1);
            else
                warning('No channels connected to sim')
            end
        end
        
        function selectionChanged_Callback(obj,~,~)
%             obj.StartTime = max(0,str2double(obj.UI.edStartTime.String));
%             obj.EndTime = min(obj.MainObj.DataBuffer.TotalSamples,str2double(obj.UI.edEndTime.String));
%             obj.UI.edStartTime.String = mat2str(obj.StartTime); % Write back verified data
%             obj.UI.edEndTime.String =  mat2str(obj.EndTime); % Write back verified data

            for ii = 1:3
                obj.RoomDims(ii) = str2double(obj.UI.edDims(ii).String);
                obj.UI.edDims(ii).String = mat2str(obj.RoomDims(ii));
            end
            for ii = 1:3
                obj.Offset(ii) = str2double(obj.UI.edOff(ii).String);
                obj.UI.edOff(ii).String = mat2str(obj.Offset(ii));
            end
            for ii = 1:6
                obj.alphas(ii) = str2double(obj.UI.edRef(ii).String);
                obj.UI.edRef(ii).String = mat2str(obj.alphas(ii));
            end
            obj.SNR = str2double(obj.UI.edSNR.String);
            obj.UI.edSNR.String = mat2str(obj.SNR);
            obj.reverb = obj.UI.cbReverb.Value;
            obj.PlotRIR = obj.UI.cbPlotRIR.Value;
            
            obj.PosErr = str2double(obj.UI.edPosErr.String);
            obj.UI.edPosErr.String =  mat2str(obj.PosErr); % Write back verified data
            
            obj.MainObj.DataBuffer.SpeedSound = str2double(obj.UI.edSpeedSound.String);
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
%             UI.txInfo = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
%                 'String',obj.Info,'Units','Normalized',...
%                 'Position',grid2pos([1,1, x,y-3, x,y]));
%             UI.txStartTime = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
%                 'String','Start Time','Units','Normalized',...
%                 'Position',grid2pos([1,y-1, 1,1, x,y]));
%             UI.edStartTime = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
%                 'String',obj.StartTime,'Units','Normalized',...
%                 'Position',grid2pos([2,y-1, 1,1, x,y]),...
%                 'Callback',@obj.selectionChanged_Callback);
%             UI.txEndTime = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
%                 'String','End Time','Units','Normalized',...
%                 'Position',grid2pos([3,y-1, 1,1, x,y]));
%             UI.edEndTime = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
%                 'String',obj.EndTime,'Units','Normalized',...
%                 'Position',grid2pos([4,y-1, 1,1, x,y]),...
%                 'Callback',@obj.selectionChanged_Callback);
            UI.pbSimulate1 = uicontrol(UI.Panel.Tabs{1},'Style','pushbutton','Tag','SimSource',...
                'String','Simulate1','Units','Normalized',...
                'Position',grid2pos([1,y, 2,1, x,y]),...
                'Callback',@obj.propSim1);
            UI.pbSimulate2 = uicontrol(UI.Panel.Tabs{1},'Style','pushbutton','Tag','SimSource',...
                'String','Simulate2','Units','Normalized',...
                'Position',grid2pos([3,y, 2,1, x,y]),...
                'Callback',@obj.propSim2);
            % room dimensions
            UI.txDims = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String',{'Room Dimensions','[x,y,z]'},'Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, x,y]));
            for ii = 1:3
                UI.edDims(ii) = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
                    'String',obj.RoomDims(ii),'Units','Normalized',...
                    'Position',grid2pos([ii+1,1, 1,1, x,y]),...
                    'Callback',@obj.selectionChanged_Callback);
            end
            % room offset
            UI.txDims = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String',{'Room Offset','[x,y,z]'},'Units','Normalized',...
                'Position',grid2pos([1,2, 1,1, x,y]));
            for ii = 1:3
                UI.edOff(ii) = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
                    'String',obj.Offset(ii),'Units','Normalized',...
                    'Position',grid2pos([1+ii,2, 1,1, x,y]),...
                    'Callback',@obj.selectionChanged_Callback);
            end
            % Reflection coefficients
            UI.txRefs = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String',{'Reflection coefficients','[x1 x2 y1 y2 z1 z2]'},'Units','Normalized',...
                'Position',grid2pos([1,3, 1,1, x,y]));
            for ii = 1:6
                UI.edRef(ii) = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
                    'String',obj.alphas(ii),'Units','Normalized',...
                    'Position',grid2pos([1.5+ii/2,3, 1/2,1, x,y]),...
                    'Callback',@obj.selectionChanged_Callback);
            end
            % sound speed
            UI.txSNR = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String','SNR [dB]','Units','Normalized',...
                'Position',grid2pos([1,4, 1,1, x,y]));
            UI.edSNR = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
                'String',obj.SNR,'Units','Normalized',...
                'Position',grid2pos([2,4, 1,1, x,y]),...
                'Callback',@obj.selectionChanged_Callback);
            % sound speed
            UI.txSpeedSound = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String','Speed of sound','Units','Normalized',...
                'Position',grid2pos([3,4, 1,1, x,y]));
            UI.edSpeedSound = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
                'String',obj.MainObj.DataBuffer.SpeedSound,'Units','Normalized',...
                'Position',grid2pos([4,4, 1,1, x,y]),...
                'Callback',@obj.selectionChanged_Callback);
            % Position error
            UI.txPosErr = uicontrol(UI.Panel.Tabs{1},'Style','text','Tag','SimSource',...
                'String','Position error Sigma','Units','Normalized',...
                'Position',grid2pos([1,5, 1,1, x,y]));
            UI.edPosErr = uicontrol(UI.Panel.Tabs{1},'Style','edit','Tag','SimSource',...
                'String',obj.PosErr,'Units','Normalized',...
                'Position',grid2pos([2,5, 1,1, x,y]),...
                'Callback',@obj.selectionChanged_Callback);
            % reverberations
            sp1 = 1e-1;
            UI.cbReverb = uicontrol(UI.Panel.Tabs{1},'Style','checkbox','Tag','SimSource',...
                'String','Reverberations','Units','Normalized','Value', obj.reverb,...
                'Callback',@obj.selectionChanged_Callback,...
                'Position',grid2pos([1+sp1,6+sp1, 2-2*sp1,1-2*sp1, x,y]));
            % PLot flag
            UI.cbPlotRIR = uicontrol(UI.Panel.Tabs{1},'Style','checkbox','Tag','SimSource',...
                'String','Plot RIR','Units','Normalized','Value', obj.reverb,...
                'Callback',@obj.selectionChanged_Callback,...
                'Position',grid2pos([3+sp1,6+sp1, 2-2*sp1,1-2*sp1, x,y]));
        end
        
    end
end