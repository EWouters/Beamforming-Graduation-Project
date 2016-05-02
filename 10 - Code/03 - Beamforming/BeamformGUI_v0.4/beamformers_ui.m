classdef beamformers_ui < handle
    %% Beamformers Interface Class 
    %  This class will hold the ui elements for the Beamformers
    %  Source signal will be loaded from source settings
    %  SourcePos will also be loaded from simulation source
    %% Constants
    properties (Constant)
        Name = 'Beamformers';
    end
    %% Properties
    properties
        MainObj
        Parent              % Handle of parent
        BeamformersStr = {'DSB','MVDR','MVDR + Directivity'};
        Enabled = [0,0,0];
        PrevData
        UI
    end
    %% Methods
    methods
        %%  Beamformers Constuctor
        function obj = beamformers_ui(parent, MainObj)
            %% Parse Input
            % figure Handle
            if ishandle(parent)
                obj.Parent = parent;
            else
                error('First argument needs to be a handle');
            end
            obj.MainObj = MainObj;
            
            %% Graphics Code
            n=length(obj.BeamformersStr);
            for ii = 1:n
                obj.UI.CbBFs{ii} = uicontrol(obj.Parent,'Style','checkbox',...
                    'String',obj.BeamformersStr{ii},'Units','Normalized','Value',obj.Enabled(ii),...
                    'Position',grid2pos([1,ii, 1,1, 1,n,0.1]),'Callback',@obj.pbUpdateSettings_Callback);
            end
%             assignin('base','obj',obj)
        end
        
        %% Update Settings Callback function
        function pbUpdateSettings_Callback(obj,~,~)
            obj.Enabled = [obj.UI.CbBFs{1}.Value obj.UI.CbBFs{2}.Value obj.UI.CbBFs{3}.Value];
        end
        
        %% DSB function
        function data1 = runDSB(obj)
            % Get varables
            fs = obj.MainObj.Channels.Fs;
            x = get(obj.MainObj.PanPlots.UI{2}.Lines(1),'YData');
            x(1) = [];
            if isempty(obj.PrevData)
                obj.PrevData = zeros(size(x));
            end
            sourcePos = obj.MainObj.PanSettings.UI{1}.Simulation.SourcePos(1,:)';
            micPos = obj.MainObj.Channels.LocData(:,2:4)';
            % Call bfDSB algorithm
            data1 = bfDSB(x',obj.PrevData',fs,sourcePos,micPos,343,0);
            % Save previous call data
            obj.PrevData = x;
        end
        
        %% MVDR function
        function data1 = runMVDR(obj)
            % Get varables
            fs = obj.MainObj.Channels.Fs;
            x = get(obj.MainObj.PanPlots.UI{2}.Lines(1),'YData');
            x(1) = [];
            if isempty(obj.PrevData)
                obj.PrevData = zeros(size(x));
            end
            sourcePos = obj.MainObj.PanSettings.UI{1}.Simulation.SourcePos(1,:)';
            micPos = obj.MainObj.Channels.LocData(:,2:4)';
            % Call MVDR algorithm
            
            covMat = cov(y, ctranspose(y));
                       
%             H = hCalc ()
            
            G = ones(1, length(H));     % the directivities can be implemented here

            d = (H.*G)';

            weigths = (inv(covMat).*d)/(ctranspose(d).*inv(covMat).*d);

            data = ctranspose(weights).*y;

            data1 = [];
            disp('TODOTODOTODOTODO MVDR algorithm not implemented yet')
            % Save previous call data
            obj.PrevData = x;
        end
    end
end