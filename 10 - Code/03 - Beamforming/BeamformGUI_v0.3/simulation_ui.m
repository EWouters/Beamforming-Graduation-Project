classdef simulation_ui < handle
    %% Computer audio Interface Class 
    %  This class will handle the simulation
    %% Constants
    properties (Constant)
        Name = 'Simulation Parameters';
    end
    %% Properties
    properties
        Parent              % Handle of parent
        UI                  % Property with all graphics handles
        Fs = 48000;         % Sample Frequency
        NChanIn = 4;        % Number of Sources
        NChanOut = 2;       % Number of Mics
        SourceFileNames = {'man1.wav';'woman1.wav';'man2.wav';'woman2.wav';'man3.wav';'woman3.wav'};
        SelectedSources     % Indices of selected sources in SourceFileNames
        SourcePos           % Signal positions [x y z]
        MicPos              % Microphone positions [x y z az el up]
        StartTime = 0;      % Start time with respect to beginning of wav file
        EndTime = 5;        % End time with respect to beginning of wav file
        DataIn              % Data which will be played, collected from the SourceFileNames
        DataOut             % Simulated data per microphone
        SpeedSound = 343.216;% Speed of Sound
    end
    %% Methods
    methods
        %% Simulation Constuctor
        function obj = simulation_ui(parent)
            %% Parse Input
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
            else
                if ishandle(parent)
                    obj.Parent = parent;
                else
                    warning(['First argument needs to be a handle,'...
                        'new figure created.']);
                    obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
                end
            end
            %% Initialization code comes here
            obj.MicPos = [zeros(obj.NChanOut,5), ones(obj.NChanOut,1)];
            obj.SourcePos = zeros(obj.NChanIn,3);
%             obj.DataIn = hier moet alle data zoals geselecteerd uit wav
%             files geladen worden
            % For loop to place the signals in a matrix
            addpath('files')
            for ii = 1:obj.NChanIn
                [obj.DataIn{ii}, fs]= audioread(obj.SourceFileNames{ii});	% Save y and Fs for each audio file
            end
            obj.Fs = fs;
            
            
            %% Graphics Code
            obj.updateSources();
            %%
        end
        
        %% Process Simulation Data
        function propSim(obj)
            tTrim = [obj.StartTime obj.EndTime];    % Set the time interval to trim down to
            sig = trimSig(obj.DataIn, obj.Fs, tTrim);
            obj.DataOut = simRec(sig, obj.SourcePos', obj.MicPos(1:3,:)', obj.Fs, obj.SpeedSound);
        end
        
        %% Function to update GUI
        function updateSources(obj)
            oldUI = findobj('Tag','SimSource');
            if ~isempty(oldUI)
                delete(oldUI);
            end
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
                obj.UI{5}.Source{ii} = uicontrol(obj.Parent,'Style','popupmenu','Value',mod(ii,length(obj.SourceFileNames))+1,...
                    'String',obj.SourceFileNames,'Units','Normalized','Tag','SimSource',...
                    'Position',grid2pos([1,ii+3, 2,1, 5,n]),...
                    'Callback',@obj.selectionChanged_Callback);
                obj.SelectedSources(ii) = mod(ii,length(obj.SourceFileNames))+1;
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
            obj.UI{6} = uicontrol(obj.Parent,'Style','text','Tag','SimSource',...
                'String','Start Time','Units','Normalized',...
                'Position',grid2pos([1,n, 2,1, 6,n]));
            obj.UI{7} = uicontrol(obj.Parent,'Style','text','Tag','SimSource',...
                'String','End Time','Units','Normalized',...
                'Position',grid2pos([4,n, 2,1, 6,n]));
            obj.UI{8} = uicontrol(obj.Parent,'Style','edit','Tag','SimSource',...
                'String',obj.StartTime,'Units','Normalized',...
                'Position',grid2pos([3,n, 1,1, 6,n]),...
                'Callback',@obj.selectionChanged_Callback);
            obj.UI{9} = uicontrol(obj.Parent,'Style','edit','Tag','SimSource',...
                'String',obj.EndTime,'Units','Normalized',...
                'Position',grid2pos([6,n, 1,1, 6,n]),...
                'Callback',@obj.selectionChanged_Callback);
        end
        
        %% Function to update data vars
        function selectionChanged_Callback(obj,~,~)
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
        end
    end
end