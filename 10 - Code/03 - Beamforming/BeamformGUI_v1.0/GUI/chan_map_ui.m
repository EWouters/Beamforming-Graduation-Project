classdef chan_map_ui < handle
    %% Channel Map Interface Class 
    %  This class will interface with the Computer audio interfaces
    %% Constants
    properties (Constant)
        Name = 'Channel Mapping';
        Tag = 'chan_map'
    end
    %% Properties
    properties
        MainObj
        Parent              % Handle of parent
        Channels
        Fs = 48000;
        NChan = 0;
        LocData
        LocsSmartPhones
        LocsFile
        LocsSimulation
        LocsUSB
        LocsCompMic
        ChanNames
        SelectedSource = 0;
        LocPath = [pwd,'\files'];
        LocName = 'Locations1.mat';
        UI
        UpdateChans
    end
    %% Methods
    methods
        %%  Channel Map Constuctor
        function obj = chan_map_ui(parent, panSettings)
            %% Parse Input
            % figure Handle
            if ishandle(parent)
                obj.Parent = parent;
            else
                error('First argument needs to be a handle');
            end
            obj.MainObj.PanSettings = panSettings;
            obj.UpdateChans = @obj.pbUpdateChannels_Callback;
            
            %% Graphics Code
            obj.UpdateChans();
%             assignin('base','obj',obj)
        end
        
        %% Load Locations Callback function
        function pbLoadLoc_Callback(obj,~,~)
            [name1,path1] = uigetfile(...
                {'*.mat','MAT-files (*.mat)';...
                'Save Locations to File',fullfile(obj.LocPath,obj.LocName)});
            if ischar(name1) && ischar(path1)
                obj.LocPath = path1;
                obj.LocName = name1;
                file1 = load(fullfile(obj.LocPath,obj.LocName),'Locations');
                if size(file1.Locations,1) == obj.NChan
                    obj.LocData = file1.Locations;
                    % Write back data to ui
                    for ii = 1:obj.NChan
                        obj.UI.Chan{ii,1}.Value = obj.LocData(ii,1); % Checkboxes to enable the channel which also display the name
                        for jj = 1:5
                            obj.UI.Chan{ii,jj+1}.String = mat2str(obj.LocData(ii,jj+1)); % Text edit for {'x','y','z','az','el'}
                        end
                        obj.UI.Chan{ii,7}.Value = obj.LocData(ii,7); % Checkboxes for 'up', Face Up state
                    end
                else
                    warndlg(sprintf('File has %i Channels, Current Source has %i',size(file1.Locations,1),obj.NChan));
                end
            end
        end
        %% Save Locations Callback function
        function pbSaveLoc_Callback(obj,~,~)
            [obj.LocName,obj.LocPath] = uiputfile(...
                {'*.mat','MAT-files (*.mat)';...
                'Save Locations to File',fullfile(obj.LocPath,obj.LocName)});
            Locations = obj.LocData; %#ok<NASGU>
            save(fullfile(obj.LocPath,obj.LocName),'Locations');
        end
        %% Get Orientations function
        function pbGetOrien_Callback(~,~,~)
            warning('Get orentations is not yet implemented')
        end
        %% Update Locations Callback function
        function pbUpdateLocs_Callback(obj,~,~)
            % Read data
            for ii = 1:obj.NChan
                obj.LocData(ii,1) = obj.UI.Chan{ii,1}.Value; % Checkboxes to enable the channel which also display the name
                for jj = 1:5
                    obj.LocData(ii,jj+1) = str2double(obj.UI.Chan{ii,jj+1}.String); % Text edit for {'x','y','z','az','el'}
                    obj.UI.Chan{ii,jj+1}.String = mat2str(obj.LocData(ii,jj+1)); % Write back verified data
                end
                obj.LocData(ii,7) = obj.UI.Chan{ii,7}.Value; % Checkboxes for 'up', Face Up state
            end
        end
        
        %% Update Channels Callback function
        function pbUpdateChannels_Callback(obj,~,~)
            % Update sources channel map
            % Get number of channels
            oldSource = obj.SelectedSource;
            oldNChan = obj.NChan;
            obj.SelectedSource = obj.MainObj.PanSettings.UI{1}.SelectedSource;  % Get source from setting
            selectedSourceStr = obj.MainObj.PanSettings.UI{1}.RbgOptions{obj.SelectedSource};
            %% Check if source or number of channels has changed
            % This time reset data
            if oldSource ~= obj.SelectedSource
                obj.NChan = 0;
                obj.ChanNames = {};
            end
            % Get number of Channels, Channel Names and Location Data from selected source
            switch obj.SelectedSource
                case 1  % Smartphones
                    if ~isempty(obj.MainObj.PanSettings.UI{1}.Smartphones.BFCom.Phones)
                        obj.NChan = length(obj.MainObj.PanSettings.UI{1}.Smartphones.BFCom.Phones);
                        obj.ChanNames = obj.MainObj.PanSettings.UI{1}.Smartphones.BFCom.getPhoneIDs();
                        obj.LocData = obj.MainObj.PanSettings.UI{1}.Smartphones.BFCom.getLocations();
                    else
                        obj.LocData = [ones(obj.NChan,1), zeros(obj.NChan,5), ones(obj.NChan,1)];
                    end
                case 2  % File
                    if ~isempty(obj.MainObj.PanSettings.UI{1}.File.Info)
                        obj.NChan = obj.MainObj.PanSettings.UI{1}.File.Info.NumChannels;
                        obj.ChanNames = {}; % Write new Channel names
                        for ii = 1:obj.NChan
                            obj.ChanNames = {obj.ChanNames{:}, sprintf('Ch %i',ii)}; %#ok<*CCAT>
                        end
                        obj.LocData = [ones(obj.NChan,1), zeros(obj.NChan,5), ones(obj.NChan,1)];
                        % save locations as wav comment
                    end
                case 3  % Simulation
                    obj.NChan = obj.MainObj.PanSettings.UI{1}.Simulation.NChanOut;
                    obj.ChanNames = {}; % Write new Channel names
                    for ii = 1:obj.NChan
                        obj.ChanNames = {obj.ChanNames{:}, sprintf('Sim %i',ii)};
                    end
                    obj.LocData = [ones(obj.NChan,1), obj.MainObj.PanSettings.UI{1}.Simulation.MicPos];
                case 4  % USB
                    obj.NChan = obj.MainObj.PanSettings.UI{1}.USB.NChan;
                    obj.ChanNames = {}; % Write new Channel names
                    for ii = obj.MainObj.PanSettings.UI{1}.USB.FirstChan:(obj.MainObj.PanSettings.UI{1}.USB.FirstChan+obj.NChan-1)
                        obj.ChanNames = {obj.ChanNames{:}, sprintf('A%i',ii)};
                    end
                    obj.LocData = [ones(obj.NChan,1), zeros(obj.NChan,5), ones(obj.NChan,1)];
                case 5  % Computer Mic
                    if ~isempty(obj.MainObj.PanSettings.UI{1}.CompMic.RecObj) %#ok<ALIGN>
                        if obj.MainObj.PanSettings.UI{1}.CompMic.RecObj.TotalSamples %#ok<ALIGN>
                            obj.NChan = obj.MainObj.PanSettings.UI{1}.CompMic.NChan;
                            if obj.NChan == 1
                                obj.ChanNames = {'Left'};
                            elseif obj.NChan == 2
                                obj.ChanNames = {'Left', 'Right'};
                            end
                        else obj.NChan = 0; end
                    else obj.NChan = 0; end
                    obj.LocData = [ones(obj.NChan,1), zeros(obj.NChan,5), ones(obj.NChan,1)];
                otherwise
                    error('Invalid source selection. Can''t map channels');
            end
            
            %% Check if source or number of channels has changed
            % This time reset GUI
            if oldSource ~= obj.SelectedSource || oldNChan ~= obj.NChan
                % Clean up ui elements
                oldUI = findobj('Tag','ChanMap');
                if ~isempty(oldUI)
                    delete(oldUI);
                    clear('obj.UI');
                end
                % Set height and width of grid
                m=4;n=obj.NChan+3;
                % Create Header and Buttons
                obj.UI.Header = uicontrol(obj.Parent,'Style','text',...
                    'String',['Source: ', selectedSourceStr],'FontWeight','Bold','Units','Normalized',...
                    'Position',grid2pos([1,1, m,1, m,n]),'Tag','ChanMap');
                obj.UI.Pb{1} = uicontrol(obj.Parent,'Style','pushbutton',...
                    'String','Update','Units','Normalized','Tag','ChanMap',...
                    'Position',grid2pos([1,n, 1,1, m,n]),'Callback',@obj.pbUpdateChannels_Callback);
                obj.UI.Pb{2} = uicontrol(obj.Parent,'Style','pushbutton',...
                    'String','Load Locations','Units','Normalized','Tag','ChanMap',...
                    'Position',grid2pos([2,n, 1,1, m,n]),'Callback',@obj.pbLoadLoc_Callback);
                obj.UI.Pb{3} = uicontrol(obj.Parent,'Style','pushbutton',...
                    'String','Save Locations','Units','Normalized','Tag','ChanMap',...
                    'Position',grid2pos([3,n, 1,1, m,n]),'Callback',@obj.pbSaveLoc_Callback);
                obj.UI.Pb{4} = uicontrol(obj.Parent,'Style','pushbutton','Tag','ChanMap',...
                    'String','Get Orientation','Units','Normalized','Enable','off',...
                    'Position',grid2pos([4,n, 1,1, m,n]),'Callback',@obj.pbGetOrien_Callback);
                % Create labels for edit boxes
                infoStr = {'Name','x','y','z','az','el','up'};
                for ii = 1:length(infoStr)
                    obj.UI.Text{ii} = uicontrol(obj.Parent,'Style','text',...
                        'String',infoStr{ii},'Units','Normalized','Tag','ChanMap',...
                        'Position',grid2pos([ii,2, 1,1, length(infoStr),n]));
                end
                % Create edit boxes
                m=7;
                obj.UI.Chan = cell(obj.NChan,7);
                for ii = 1:obj.NChan
                    % Checkboxes to enable the channel which also display the name
                    obj.UI.Chan{ii,1} = uicontrol(obj.Parent,'Style','checkbox','Tag','ChanMap',...
                        'String',obj.ChanNames{ii},'Units','Normalized','Value',obj.LocData(ii,1),...
                        'Position',grid2pos([1,ii+2, 1,1, m,n]),'Callback',@obj.pbUpdateLocs_Callback);
                    % Text edit for {'x','y','z','az','el'}
                    for jj = 1:5
                        obj.UI.Chan{ii,jj+1} = uicontrol(obj.Parent,'Style','edit','Tag','ChanMap',...
                            'String',obj.LocData(ii,jj+1),'Units','Normalized',...
                            'Position',grid2pos([jj+1,ii+2, 1,1, m,n]),'Callback',@obj.pbUpdateLocs_Callback);
                    end
                    % Checkboxes for 'up', Face Up state
                    obj.UI.Chan{ii,7} = uicontrol(obj.Parent,'Style','checkbox','Tag','ChanMap',...
                        'Units','Normalized','Value',obj.LocData(ii,7),...
                        'Position',grid2pos([7,ii+2, 1,1, m,n, 0.3]),'Callback',@obj.pbUpdateLocs_Callback);
                end
                % Label for when no channels present
                if ~obj.NChan
                    obj.UI.Chan = uicontrol(obj.Parent,'Style','text','FontWeight','Bold',...
                        'String','No Channels Found','Units','Normalized','Tag','ChanMap',...
                        'Position',grid2pos([1,2, 1,0.5,1,n,0,0.1]));
                end
            else
                disp('No channels to update')
            end
        end
        
        %% Get Data function
        function data1 = getData(obj)
            % Get Data from selected source
            switch obj.SelectedSource
                case 1  % Smartphones
                    data1 = obj.MainObj.PanSettings.UI{1}.Smartphones.BFCom.Buffer;
                    obj.Fs = obj.MainObj.PanSettings.UI{1}.Smartphones.BFCom.Fs;
                case 2  % File
                    if isempty(obj.MainObj.PanSettings.UI{1}.File.Data)
                        obj.MainObj.PanSettings.UI{1}.File.pbFilePath_Callback();
                    end
                    data1 = obj.MainObj.PanSettings.UI{1}.File.Data;
                    try    obj.Fs = obj.MainObj.PanSettings.UI{1}.File.Info.SampleRate;
                    catch; obj.Fs = 48000; end
                case 3  % Simulation
                    data1  = obj.MainObj.PanSettings.UI{1}.Simulation.DataOut;
                    obj.Fs = obj.MainObj.PanSettings.UI{1}.Simulation.Fs;
                case 4  % USB
                    data1  = obj.MainObj.PanSettings.UI{1}.USB.Data;
                    obj.Fs = obj.MainObj.PanSettings.UI{1}.USB.Fs;
                case 5  % Computer Mic
                    try
                        data1  = obj.MainObj.PanSettings.UI{1}.CompMic.RecObj.getaudiodata();
                        obj.Fs = obj.MainObj.PanSettings.UI{1}.CompMic.RecObj.SampleRate;
                    catch
                        data1 = [];
                        obj.Fs = 48000;
                    end
                otherwise
                    error('Invalid source selection. Can''t get data');
            end
            if isempty(data1)
                warning('The data could not be loaded from source')
            end
        end
        
        %% Get Window function
        function [data1, totalSamples] = getWindow(obj,source,firstSample,nSamples)
            % Get Data window from selected source
            data1 = [];
            totalSamples = 0;
            switch source
                case 1  % Smartphones
                    data1 = obj.MainObj.PanSettings.UI{1}.Smartphones.BFCom.Buffer;
                    totalSamples = 0;
                    disp('TODOTODO smartphone window')
                case 2  % File
                    if isempty(obj.MainObj.PanSettings.UI{1}.File.Data)
                        obj.MainObj.PanSettings.UI{1}.File.pbFilePath_Callback();
                    end
                    if firstSample+nSamples <= length(obj.MainObj.PanSettings.UI{1}.File.Data)
                        data1 = obj.MainObj.PanSettings.UI{1}.File.Data(firstSample:firstSample+nSamples,:);
                        totalSamples = length(obj.MainObj.PanSettings.UI{1}.File.Data);
                    end
                case 3  % Simulation
                    if firstSample+nSamples <= length(obj.MainObj.PanSettings.UI{1}.Simulation.DataOut)
                        data1  = obj.MainObj.PanSettings.UI{1}.Simulation.DataOut(firstSample:firstSample+nSamples,:);
                        totalSamples = length(obj.MainObj.PanSettings.UI{1}.Simulation.DataOut);
                    end
                case 4  % USB
                    if firstSample+nSamples <= length(obj.MainObj.PanSettings.UI{1}.USB.Data)
                        data1  = obj.MainObj.PanSettings.UI{1}.USB.Data(firstSample:firstSample+nSamples,:);
                        totalSamples = length(obj.MainObj.PanSettings.UI{1}.USB.Data);
                    end
                case 5  % Computer Mic
                    try data1  = obj.MainObj.PanSettings.UI{1}.CompMic.RecObj.getaudiodata(); catch; end
                    if firstSample+nSamples <= length(data1)
                        data1  = data1(firstSample:firstSample+nSamples,:);
                        totalSamples = obj.MainObj.PanSettings.UI{1}.CompMic.RecObj.TotalSamples;
                    end
                otherwise
                    error('Invalid source selection. Can''t get data');
            end
            if isempty(data1)
                warning('The data window could not be loaded from source');
            end
        end
    end
end