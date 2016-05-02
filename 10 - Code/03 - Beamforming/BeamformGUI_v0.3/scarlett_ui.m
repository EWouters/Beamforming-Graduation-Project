classdef scarlett_ui < handle
    %% Focusrite Scarlett 18i20 Interface Class 
    %  This class will interface with the Scarlett USB audio interface
    %% Constants
    properties (Constant)
        Name = 'Scarlett 18i20 USB';
        NChanMax = 18;      % Maximum number of channels
    end
    %% Properties
    properties
        Parent              % Handle of parent
        Fs = 48000;         % Sample Frequency
        NChan = 4;          % Number of channels
        RecTime = 10;       % Time to record when calling rec without arguments
        FirstChan = 1;      % ID of first channel (usually 1)
        UI
        Data
    end
    %% Methods
    methods
        %% Scarlett Constuctor
        function obj = scarlett_ui(parent, fs,NChan,recTime,firstChan)
            %% Parse Input
            narginchk(0,5)
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
            if nargin < 2 || isempty(fs)
                obj.Fs = 48000;
            else
                obj.Fs = fs;
            end
            if nargin < 2 || isempty(NChan) || NChan > obj.NChanMax
                obj.NChan = 4;
            else
                obj.NChan = NChan;
            end
            if nargin < 3 || isempty(recTime)
                obj.RecTime = 10;
            else
                obj.RecTime = recTime;
            end
            if nargin < 4 || isempty(firstChan) || firstChan+obj.NChan > obj.NChanMax
                obj.FirstChan = 1;
            else
                obj.FirstChan = firstChan;
            end
            
            
            %% Graphics Code
            n=5;m=3;
            chanStr = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18'};
            obj.UI.TextFirstChan = uicontrol(obj.Parent,'Style','text',...
                'String','First Channel','Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, m,n]));
            obj.UI.TextLastChan = uicontrol(obj.Parent,'Style','text',...
                'String','Last Channel','Units','Normalized',...
                'Position',grid2pos([1,2, 1,1, m,n]));
            obj.UI.PopupFirstChan = uicontrol(obj.Parent,'Style','popup',...
                'String',chanStr,'Value',obj.FirstChan,'Units','Normalized','Tag','F',...
                'Position',grid2pos([2,1, 1,1, m,n]),...
                'Callback',@obj.ChansChanged_Callback);
            obj.UI.PopupLastChan = uicontrol(obj.Parent,'Style','popup',...
                'String',chanStr,'Value',obj.FirstChan + obj.NChan - 1,...
                'Units','Normalized','Tag','L',...
                'Position',grid2pos([2,2, 1,1, m,n]),...
                'Callback',@obj.ChansChanged_Callback);
            obj.UI.TextTime = uicontrol(obj.Parent,'Style','text',...
                'String','Time [s]','Units','Normalized',...
                'Position',grid2pos([1,3, 1,1, m,n]));
            obj.UI.TextFs = uicontrol(obj.Parent,'Style','text',...
                'String','Fs [hz]','Units','Normalized',...
                'Position',grid2pos([1,4, 1,1, m,n]));
            obj.UI.EditTime = uicontrol(obj.Parent,'Style','edit',...
                'String',mat2str(obj.RecTime),'Units','Normalized',...
                'Position',grid2pos([2,3, 1,1, m,n]),'Tag','Time',...
                'Callback',@obj.textChanged_Callback);
            obj.UI.EditFs = uicontrol(obj.Parent,'Style','edit',...
                'String',mat2str(obj.Fs),'Units','Normalized',...
                'Position',grid2pos([2,4, 1,1, m,n]),'Tag','Fs',...
                'Callback',@obj.textChanged_Callback);
            obj.UI.PbStartSampling = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Start Sampling','Units','Normalized',...
                'Position',grid2pos([1,5, 1,1, 2,n]),'Callback',@obj.pbStartSampling_Callback);
            obj.UI.PbPlotData = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Plot Data','Units','Normalized',...
                'Position',grid2pos([2,5, 1,1, 2,n]),'Callback',@obj.plot_Callback);
        end
        
        %% Popup Changed function
        function ChansChanged_Callback(obj,~,cbd)
            if obj.UI.PopupFirstChan.Value > obj.UI.PopupLastChan.Value
                if strcmp('F',cbd.Source.Tag)
                    obj.UI.PopupLastChan.Value = obj.UI.PopupFirstChan.Value;
                else
                    obj.UI.PopupFirstChan.Value = obj.UI.PopupLastChan.Value;
                end
            end
            obj.FirstChan = obj.UI.PopupFirstChan.Value;
            obj.NChan = obj.UI.PopupLastChan.Value - obj.UI.PopupFirstChan.Value + 1;
        end
        %% Text Changed function
        function textChanged_Callback(obj,~,cbd)
            n = 0;
            try
                n = str2double(cbd.Source.String);
                if isnan(n) || n <= 0 || ~isresl(n)
                    n = 0;
                end
            catch
            end
            disp(n)
            if n && strcmp('Time',cbd.Source.Tag)
                obj.RecTime = n;
            elseif n
                obj.Fs = n;
            end
            obj.UI.EditTime.String = mat2str(obj.RecTime);
            obj.UI.EditFs.String = mat2str(obj.Fs);
        end
        %% Start Sampling function
        function pbStartSampling_Callback(obj,~,~)
            s = tic;
            obj.Data = pa_wavrecord(obj.FirstChan, obj.FirstChan+obj.NChan-1, round(obj.Fs*obj.RecTime));
            disp(['Time taken to record: ',mat2str(toc(s)),' [s]']);
        end
        
        
        
        %% Record all channels obj.RecTime seconds
        function r = rec(obj,recTime)
            if nargin > 1 
                if ~isempty(recTime)
                    obj.RecTime = recTime;
                end
            end
            r = pa_wavrecord(obj.FirstChan, obj.FirstChan+obj.NChan-1, round(obj.Fs*obj.RecTime));
        end
        %% pbPlot callback
        function plot_Callback(obj,~,~)
            if ~isempty(obj.Data)
                obj.plot(obj.Data);
            end
        end
        %% Plot recording
        function plot(obj,r)
            figure;
            x = (1:size(r,1))/obj.Fs;
            legStr = {'Ch 1'};
            plot(x,r(:,1));
            hold on
            for ii = 2:size(r,2)
                plot(x,r(:,ii));
                legStr{end+1} = sprintf('Ch %d',ii); %#ok<AGROW>
            end
            legend(legStr);
        end
    end
end