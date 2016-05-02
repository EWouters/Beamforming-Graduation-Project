classdef comp_mic_ui < handle
    %% Computer audio Interface Class 
    %  This class will interface with the Computer audio interfaces
    %% Constants
    properties (Constant)
        Name = 'Computer Microphone';
    end
    %% Properties
    properties
        Parent              % Handle of parent
        MainObj
        Info = audiodevinfo;% Device information
        FsOptions = {'8000','11025','22050','44100','48000','88200','96000','192000'};
        Fs = 48000;         % Sample Frequency
        ChanNames = {'Left PC Mic','Right PC Mic'};
        NChan = 2;          % Number of channels
        ID                  % ID of audio device
        BitsPS = 16;        % Bits Per Sample
        UI
        RecObj
        TimerPeriod = 0.5;
    end
    %% Methods
    methods
        %% Scarlett Constuctor
        function obj = comp_mic_ui(parent, mainObj)
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
            
            %% Graphics Code
            n=9;m=3;
            obj.UI.TextInterface = uicontrol(obj.Parent,'Style','text',...
                'String','Audio Interface','Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, m,n]));
            obj.UI.PopupInterface = uicontrol(obj.Parent,'Style','popup',...
                'String',{obj.Info.input.Name},'Units','Normalized',...
                'Position',grid2pos([2,1, 2,1, m,n]),'Tag','I',...
                'Callback',@obj.recChanged_Callback);
            obj.UI.TextNumChan = uicontrol(obj.Parent,'Style','text',...
                'String','Number of channels','Units','Normalized',...
                'Position',grid2pos([1,2, 1,1, m,n]));
            obj.UI.PopupNumChan = uicontrol(obj.Parent,'Style','popup',...
                'String',{'1','2'},'Units','Normalized','Tag','N',...
                'Position',grid2pos([2,2, 1,1, m,n]),...
                'Callback',@obj.recChanged_Callback);
            obj.UI.TextFs = uicontrol(obj.Parent,'Style','text',...
                'String','Fs [hz]','Units','Normalized',...
                'Position',grid2pos([1,3, 1,1, m,n]));
            obj.UI.PopupFs = uicontrol(obj.Parent,'Style','popup',...
                'String',obj.FsOptions,'Units','Normalized',...
                'Position',grid2pos([2,3, 1,1, m,n]),'Tag','Fs',...
                'Callback',@obj.recChanged_Callback);
            obj.UI.PbCreate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Create','Units','Normalized',...
                'Position',grid2pos([3,3, 1,1, m,n]),'Callback',@obj.pbCreate_Callback);
            obj.UI.TextRecHeader = uicontrol(obj.Parent,'Style','listbox',...
                'Units','Normalized','Position',grid2pos([1,4, 3,n-4, m,n]),...
                'String',{'Audio Recorder header','not loaded'});
            obj.UI.PbStart = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Start Recording','Units','Normalized','Enable','off',...
                'Position',grid2pos([1,n, 1,1, 2,n]),'Callback',@obj.pbStart_Callback);
            obj.UI.PbPause = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Pause (!)','Units','Normalized','Enable','on',...
                'Position',grid2pos([2,n, 1,1, 2,n]),'Callback',@obj.pbPause_Callback);
            obj.UI.PopupNumChan.Value = 2;
            obj.UI.PopupFs.Value = 5;
            
        end
        
        %% Popup Changed function
        function recChanged_Callback(obj,~,~)
            obj.Fs = str2double(obj.FsOptions{obj.UI.PopupFs.Value});
            obj.Info = audiodevinfo;
            obj.ID = obj.Info.input(obj.UI.PopupInterface.Value).ID;
            obj.NChan = obj.UI.PopupNumChan.Value;
            obj.UI.PbCreate.String = 'Update';
        end
        %% Create function
        function pbCreate_Callback(obj,~,~)
            if strcmp(obj.UI.PbCreate.String,'Update')
                obj.UI.PbStart.String = 'Start Recording';
                obj.UI.PbStart.Enable = 'off';
                obj.UI.pbPause.String = 'Pause';
                obj.UI.pbPause.Enable = 'off';
                obj.RecObj = [];
                obj.NChan = 0;
            end
            if isempty(obj.RecObj)
                obj.Fs = str2double(obj.FsOptions{obj.UI.PopupFs.Value});
                obj.Info = audiodevinfo;
                obj.ID = obj.Info.input(obj.UI.PopupInterface.Value).ID;
                obj.NChan = obj.UI.PopupNumChan.Value;
                obj.RecObj = audiorecorder(obj.Fs, obj.BitsPS, obj.NChan,obj.ID);
                obj.RecObj.TimerFcn = @obj.timerFcn;
                obj.RecObj.TimerPeriod = obj.TimerPeriod;
                obj.MainObj.DataBuffer.setChanNames(obj.ChanNames(1:obj.NChan));
                obj.UI.PbStart.Enable = 'on';
                obj.UI.PbCreate.String = 'Delete';
                header = {'Audio Recorder header',...
                    sprintf('SampleRate: %i',obj.RecObj.SampleRate),...
                    sprintf('BitsPerSample: %i',obj.RecObj.BitsPerSample),...
                    sprintf('NumberOfChannels: %i',obj.RecObj.NumberOfChannels),...
                    sprintf('DeviceID: %i',obj.RecObj.DeviceID),...
                    sprintf('CurrentSample: %i',obj.RecObj.CurrentSample),...
                    sprintf('TotalSamples: %i',obj.RecObj.TotalSamples),...
                    ['Running: ',obj.RecObj.Running],...
                    sprintf('TimerPeriod: %d',obj.RecObj.TimerPeriod)};
            else
                obj.UI.PbCreate.String = 'Create';
                header = {'Audio Recorder header','not loaded'};
                obj.UI.PbStart.String = 'Start Recording';
                obj.UI.PbStart.Enable = 'off';
                obj.UI.pbPause.String = 'Pause';
                obj.UI.pbPause.Enable = 'off';
                obj.RecObj = [];
                obj.NChan = 0;
            end
            obj.UI.TextRecHeader.String = header;
        end
        
        %% Pushbutton Start Recording function
        function pbStart_Callback(obj,~,cbd)
            if strcmp(cbd.Source.String, 'Start Recording')
                cbd.Source.String = 'Stop Recording';
                obj.UI.pbPause.String = 'Pause';
                obj.UI.pbPause.Enable = 'on';
                try
                    obj.MainObj.DataBuffer.removeChan(obj.ChanNames);
                catch %#ok<CTCH>
                end
                record(obj.RecObj);
            else
                stop(obj.RecObj);
                cbd.Source.String = 'Start Recording';
                header = {'Audio Recorder header',...
                    sprintf('SampleRate: %i',obj.RecObj.SampleRate),...
                    sprintf('BitsPerSample: %i',obj.RecObj.BitsPerSample),...
                    sprintf('NumberOfChannels: %i',obj.RecObj.NumberOfChannels),...
                    sprintf('DeviceID: %i',obj.RecObj.DeviceID),...
                    sprintf('CurrentSample: %i',obj.RecObj.CurrentSample),...
                    sprintf('TotalSamples: %i',obj.RecObj.TotalSamples),...
                    ['Running: ',obj.RecObj.Running],...
                    sprintf('TimerPeriod: %d',obj.RecObj.TimerPeriod)};
                obj.UI.TextRecHeader.String = header;
                obj.UI.pbPause.String = 'Pause';
                obj.UI.pbPause.Enable = 'off';
            end
        end
        
        %% Pushbutton Start Recording function
        function pbPause_Callback(obj,~,cbd)
            if strcmp(cbd.Source.String, 'Pause')
                cbd.Source.String = 'Resume';
                pause(obj.RecObj);
                header = {'Audio Recorder header',...
                    sprintf('SampleRate: %i',obj.RecObj.SampleRate),...
                    sprintf('BitsPerSample: %i',obj.RecObj.BitsPerSample),...
                    sprintf('NumberOfChannels: %i',obj.RecObj.NumberOfChannels),...
                    sprintf('DeviceID: %i',obj.RecObj.DeviceID),...
                    sprintf('CurrentSample: %i',obj.RecObj.CurrentSample),...
                    sprintf('TotalSamples: %i',obj.RecObj.TotalSamples),...
                    ['Running: ',obj.RecObj.Running],...
                    sprintf('TimerPeriod: %d',obj.RecObj.TimerPeriod)};
                obj.UI.TextRecHeader.String = header;
            else
                cbd.Source.String = 'Pause';
                resume(obj.RecObj);
            end
        end
        
        % Timer Function
        function timerFcn(obj,~,~)
%             addSamples(OBJ, Y, CHANNAMES, ADDNEW)
%             addSamples(OBJ, Y, CHANNAMES, ADDNEW, SAMPLEINDS)
%             if ~isempty(obj.MainObj)
                obj.MainObj.DataBuffer.addSamples(obj.RecObj.getaudiodata,obj.ChanNames(1:obj.NChan),1,1);
%             end
            
            %% Continuous recording with dsp player
%             hafr = dsp.AudioFileReader(my_file_name);
%             hap = dsp.AudioPlayer('SampleRate',48000);
%             while ~isDone(hafr)
%                audio = step(hafr);
%                step(hap,audio);
%             end
%             pause(hap.QueueDuration);  % Wait until audio plays to the end
%             release(hafr); % close input file, release resources
%             release(hap);  % close audio output device, release resources
            
            
       
        end
    end
end