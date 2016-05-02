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
        SpeedSound = 342;   % Speed of Sound
        Update
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
            obj.updateSources();
            
            % Link handle of update callback
            obj.Update = @selectionChanged_Callback;
            
            % Debug
%             assignin('base','obj',obj)
        end
        
        %% Process Simulation Data
        function propSim(obj,~,~)
            chanNames = obj.MainObj.DataBuffer.ChanNames;
            micNames = [];
            sourceNames = [];
            for ii = 1:length(chanNames)
                if ~isempty(strfind(chanNames{ii},':')) || ~isempty(strfind(chanNames{ii},'Mic'))
                    micNames = [micNames ii];
                elseif strfind(chanNames{ii},'Sim Source')
                    sourceNames = [sourceNames ii];
                end
            end
            obj.NChanOut = size(micNames,1);
            obj.MicNames = chanNames(micNames);
            obj.NChanOut = size(sourceNames,1);
            obj.SourceNames = chanNames(sourceNames);
            
            obj.MicPos = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),1:3);
            obj.SourcePos =  obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);
            tTrim = [obj.StartTime obj.EndTime];    % Set the time interval to trim down to
            sig = trimSig(obj.MainObj.DataBuffer.getAudioData(obj.SourceNames), obj.Fs, tTrim);
            obj.MainObj.DataBuffer.addSamples(simRec(sig, obj.SourcePos', obj.MicPos(:,1:3)', obj.Fs, obj.SpeedSound),obj.MicNames,1);
        end
        
        %% Function to update GUI
        function updateSources(obj)
            oldUI = findobj('Tag','SimSource');
            if ~isempty(oldUI)
                delete(oldUI);
            end
            
            chanNames = obj.MainObj.DataBuffer.ChanNames;
            micNames = [];
            sourceNames = [];
            noiseNames = [];
            for ii = 1:length(chanNames)
                if ~isempty(strfind(chanNames{ii},':')) || ~isempty(strfind(chanNames{ii},'Mic'))
                    micNames = [micNames ii];
                elseif strfind(chanNames{ii},'Sim Source')
                    sourceNames = [sourceNames ii];
                elseif strfind(chanNames{ii},'Sim Noise')
                    noiseNames = [noiseNames ii];
                end
            end
            obj.NChanOut = size(micNames,1);
            obj.MicNames = chanNames(micNames);
            obj.NChanIn = size(sourceNames,1) + size(noiseNames,1);
            obj.SourceNames = chanNames(sourceNames);
            
            n=4+obj.NChanIn;
            obj.UI{1} = uicontrol(obj.Parent,'Style','text','Tag','SimSource',...
                'String','Number of Sources','Units','Normalized',...
                'Position',grid2pos([1,1, 3,1, 4,n]));
            obj.UI{2} = uicontrol(obj.Parent,'Style','text','Tag','SimSource',...
                'String','Number of Mics','Units','Normalized',...
                'Position',grid2pos([1,2, 3,1, 4,n]));
            chanStr = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18'};
            obj.UI{3} = uicontrol(obj.Parent,'Style','popupmenu','Value',obj.NChanIn,...
                'String',chanStr,'Units','Normalized','Tag','SimSource',...
                'Position',grid2pos([4,1, 1,1, 4,n]),...
                'Callback',@obj.selectionChanged_Callback);
            obj.UI{4} = uicontrol(obj.Parent,'Style','popupmenu','Value',obj.NChanOut,...
                'String',chanStr,'Units','Normalized','Tag','SimSource',...
                'Position',grid2pos([4,2, 1,1, 4,n]),...
                'Callback',@obj.selectionChanged_Callback);
            infoStr = {'Source','x','y','z'};
            for ii = 1:length(infoStr)
                uicontrol(obj.Parent,'Style','text','Tag','SimSource',...
                    'String',infoStr{ii},'Units','Normalized',...
                    'Position',grid2pos([ii+1,3, 1,1, 5,n]));
            end
            for ii = 1:obj.NChanIn
                obj.UI{5}.Source{ii} = uicontrol(obj.Parent,'Style','popupmenu','Value',mod(ii,length(obj.SourceNames))+1,...
                    'String',obj.SourceNames,'Units','Normalized','Tag','SimSource',...
                    'Position',grid2pos([1,ii+3, 2,1, 5,n]),...
                    'Callback',@obj.selectionChanged_Callback);
                obj.SelectedSources(ii) = mod(ii,length(obj.SourceNames))+1;
                obj.UI{5}.x{ii} = uicontrol(obj.Parent,'Style','edit',...
                    'String',obj.SourcePos(ii,1),'Units','Normalized','Tag','SimSource',...
                    'Position',grid2pos([3,ii+3, 1,1, 5,n]),...
                    'Callback',@obj.selectionChanged_Callback);
                obj.UI{5}.y{ii} = uicontrol(obj.Parent,'Style','edit',...
                    'String',obj.SourcePos(ii,2),'Units','Normalized','Tag','SimSource',...
                    'Position',grid2pos([4,ii+3, 1,1, 5,n]),...
                    'Callback',@obj.selectionChanged_Callback);
                obj.UI{5}.z{ii} = uicontrol(obj.Parent,'Style','edit',...
                    'String',obj.SourcePos(ii,3),'Units','Normalized','Tag','SimSource',...
                    'Position',grid2pos([5,ii+3, 1,1, 5,n]),...
                    'Callback',@obj.selectionChanged_Callback);
            end
            m=8;
            obj.UI{6} = uicontrol(obj.Parent,'Style','text','Tag','SimSource',...
                'String','Start Time','Units','Normalized',...
                'Position',grid2pos([1,n, 2,1, m,n]));
            obj.UI{7} = uicontrol(obj.Parent,'Style','text','Tag','SimSource',...
                'String','End Time','Units','Normalized',...
                'Position',grid2pos([4,n, 2,1, m,n]));
            obj.UI{8} = uicontrol(obj.Parent,'Style','edit','Tag','SimSource',...
                'String',obj.StartTime,'Units','Normalized',...
                'Position',grid2pos([3,n, 1,1, m,n]),...
                'Callback',@obj.selectionChanged_Callback);
            obj.UI{9} = uicontrol(obj.Parent,'Style','edit','Tag','SimSource',...
                'String',obj.EndTime,'Units','Normalized',...
                'Position',grid2pos([6,n, 1,1, m,n]),...
                'Callback',@obj.selectionChanged_Callback);
            obj.UI{10} = uicontrol(obj.Parent,'Style','pushbutton','Tag','SimSource',...
                'String','Simulate','Units','Normalized',...
                'Position',grid2pos([7,n, 2,1, m,n]),...
                'Callback',@obj.propSim);
        end
        
        %% Function to update data vars
        function selectionChanged_Callback(obj,~,~)
            % Read data
            oldNChanIn = obj.NChanIn;
            oldNChanOut = obj.NChanOut;
            obj.NChanIn = obj.UI{3}.Value;
            obj.NChanOut = obj.UI{4}.Value;
            if oldNChanIn == obj.NChanIn
                for ii = 1:obj.NChanIn
                    obj.SelectedSources(ii) = obj.UI{5}.Source{ii}.Value;
                    obj.SourcePos(ii,:) = [str2double(obj.UI{5}.x{ii}.String),...
                                           str2double(obj.UI{5}.y{ii}.String),...
                                           str2double(obj.UI{5}.z{ii}.String)];
                end
                obj.StartTime = str2double(obj.UI{8}.String);
                obj.EndTime = str2double(obj.UI{9}.String);
            else
                obj.SourcePos = zeros(obj.NChanIn,3);
                obj.updateSources();
            end
            if oldNChanOut ~= obj.NChanOut
                obj.MicPos = [zeros(obj.NChanOut,5), ones(obj.NChanOut,1)];
            end
            % Write verified data back
            for ii = 1:obj.NChanIn
                obj.UI{5}.Source{ii}.Value = obj.SelectedSources(ii);
                obj.UI{5}.x{ii}.String = mat2str(obj.SourcePos(ii,1));
                obj.UI{5}.y{ii}.String = mat2str(obj.SourcePos(ii,2));
                obj.UI{5}.z{ii}.String = mat2str(obj.SourcePos(ii,3));
            end
            obj.UI{8}.String = mat2str(obj.StartTime);
            if obj.EndTime > obj.StartTime % Make sure time is nonnegative
                obj.UI{9}.String = mat2str(obj.EndTime);
            else
                obj.UI{9}.String = mat2str(obj.StartTime);
                obj.EndTime = obj.StartTime;
            end
        end
    end
end