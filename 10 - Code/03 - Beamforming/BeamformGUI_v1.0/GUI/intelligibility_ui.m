classdef intelligibility_ui < handle
    %% Intelligibility Interface Class 
    %  This class will hold the ui elements for the Intelligibility
    %  Source signal will be loaded from simulation source
    %  SourcePos will also be loaded from simulation source
    %  Closest mic will be loaded from Chan_Map
    %% Constants
    properties (Constant)
        Name = 'Intelligibility';
    end
    %% Properties
    properties
        MainObj
        Parent              % Handle of parent
        SigsToCompareStr = {'Closest Mic','DSB','MVDR','MVDR + Directivity'};
        MethodsStr = {'stoi','pesq','SNR*'}
        Intel
        SelectedSource = 0;
        NChan = 0;
        UI
    end
    %% Methods
    methods
        %%  Intelligibility Constuctor
        function obj = intelligibility_ui(parent, MainObj)
            %% Parse Input
            % figure Handle
            if ishandle(parent)
                obj.Parent = parent;
            else
                error('First argument needs to be a handle');
            end
            obj.MainObj = MainObj;
            
            %% Graphics Code
            m=length(obj.SigsToCompareStr)+1;
            n=length(obj.MethodsStr)+3;
            obj.UI.pbUpdate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Units','Normalized',...
                'Position',grid2pos([m-1,n, 2,1, m,n, 0.02,0,0,0.02]),'Callback',@obj.pbUpdate_Callback);
            % Place signal checkboxes
            for ii = 1:length(obj.SigsToCompareStr)
                obj.UI.CbSigs{ii} = uicontrol(obj.Parent,'Style','checkbox',...
                    'String','','Units','Normalized','Value',0,...
                    'Position',grid2pos([(ii+1)*3-1,1, 1,1, m*3,n]),'Callback',@obj.pbUpdateSettings_Callback);
                obj.UI.TextSigs{ii} = uicontrol(obj.Parent,'Style','text',...
                    'String',obj.SigsToCompareStr{ii},'Units','Normalized',...
                    'Position',grid2pos([ii+1,2, 1,1, m,n]),'Callback',@obj.pbUpdateSettings_Callback);
            end
            % Place method checkboxes
            for ii = 1:length(obj.MethodsStr)
                obj.UI.CbMethods{ii} = uicontrol(obj.Parent,'Style','checkbox',...
                    'String',obj.MethodsStr{ii},'Units','Normalized','Value',0,...
                    'Position',grid2pos([1,ii+2, 1,1, m,n]),'Callback',@obj.pbUpdateSettings_Callback);
            end
            % Place text boxes
            for ii = 1:length(obj.SigsToCompareStr)
                for jj = 1:length(obj.MethodsStr)
                    obj.UI.TextIntel{ii,jj} = uicontrol(obj.Parent,'Style','edit',...
                        'String','-1','Units','Normalized',...
                        'Position',grid2pos([ii+1,jj+2, 1,1, m,n]),...
                        'Callback',@obj.pbUpdateSettings_Callback);
                end
            end
%             assignin('base','obj',obj)
        end
        
        %% Update Intelligibility Callback function
        function pbUpdate_Callback(obj,~,~)
            % This function calls intelligibility scripts
            obj.SelectedSource = obj.MainObj.PanSettings.UI{1}.SelectedSource;
            % Get sample window indices
            firstSample = obj.MainObj.PanPlots.UI{2}.FirstSample;
            nSamples = obj.MainObj.PanPlots.UI{2}.WindowSize;
            lastSample = firstSample+nSamples-1;
            % Get the signals to process
            cleanSig = obj.MainObj.PanSettings.UI{1}.Simulation.DataIn{1};
            closestMicSig = obj.getClosestMicSig();
            DSBSig = obj.MainObj.PanSettings.UI{3}.runDSB();
            MVDRSig = zeros(size(DSBSig));
            MVDRDirSig = zeros(size(DSBSig));
            enhancedSigs = [closestMicSig(firstSample:lastSample) DSBSig MVDRSig MVDRDirSig];
            
            % Calculate Intel
            for ii = 1:length(obj.SigsToCompareStr)
                if obj.UI.CbSigs{ii}.Value 
                    % Calculate stoi
                    if obj.UI.CbMethods{1}.Value
                        obj.Intel(ii,1) = stoi(cleanSig(firstSample:lastSample),...
                            enhancedSigs(:,ii), obj.MainObj.Channels.Fs);
                        obj.UI.TextIntel{ii,1}.String = mat2str(obj.Intel(ii,1));
                    end
                    % Calculate pesq
                    if obj.UI.CbMethods{2}.Value
                        obj.Intel(ii,2) = pesq_resample(cleanSig(firstSample:lastSample),...
                            enhancedSigs(:,ii), obj.MainObj.Channels.Fs);
                        obj.UI.TextIntel{ii,2}.String = mat2str(obj.Intel(ii,2));
                    end
                end
            end
        end
        
        %% Function to get the signal of the closest microphone
        function data1 = getClosestMicSig(obj)
            % Using positions 
            sourcePos = obj.MainObj.PanSettings.UI{1}.Simulation.SourcePos(1,:);
            micPos = obj.MainObj.Channels.LocData(:,2:4);
            data1 = obj.MainObj.Channels.getData();
            data1 = data1(:,dsearchn(micPos,sourcePos));
        end
        
        %% Update Settings Callback function
        function pbUpdateSettings_Callback(~,~,~)
            % Nothing to do here?
        end
    end
end














%             % Calculate stois
%             for ii = 1:length(obj.SigsToCompareStr)
%                 if obj.UI.CbSigs{ii}.Value && obj.UI.CbMethods{1}.Value
%                     disp('Stoi time')
%                     tic
%                     obj.Intel(ii,1) = stoi(cleanSig(firstSample:lastSample),...
%                         closestMicSig(firstSample:lastSample), obj.MainObj.Channels.Fs);
%                     toc
%                     obj.UI.TextIntel{ii,1}.String = mat2str(obj.Intel(ii,1));
%                     disp(obj.Intel(ii,1));
%                 end
%             end

%             % Calculate pesq
%             for ii = 1:length(obj.SigsToCompareStr)
%                 if obj.UI.CbSigs{ii}.Value && obj.UI.CbMethods{2}.Value
%                     disp('Pesq time')
%                     tic
%                     obj.Intel(ii,2) = pesq_resample(cleanSig(firstSample:lastSample),...
%                         closestMicSig(firstSample:lastSample), obj.MainObj.Channels.Fs);
%                     toc
%                     obj.UI.TextIntel{ii,2}.String = mat2str(obj.Intel(ii,2));
%                     disp(obj.Intel(ii,2));
%                 end
%             end