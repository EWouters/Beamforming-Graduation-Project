classdef std_processor < handle
    % STD_PROCESSOR Standard processing object. This file is a template to
    % make a processing object like a beamformer or an intelligibility measure
    %
    %   BF_DATA() create processing object
    %   BF_DATA(MAINOBJ) create processing object with handle to main object
    %   BF_DATA(MAINOBJ, CHANNAMES) add names of channels to process
    %
    % STD_PROCESSOR Methods:
    %   update  - Function to get a data window and call process function if
    %   there is data available to process
    %   process - Function where processing is done
    %
    % STD_PROCESSOR Properties:
    %   MainObj       - Handle of main object
    %   Name          - Name of Processor
    %   ChanNames     - Channel names
    %   CurrentSample - Current sample
    %   WindowSize    - Size of window to process, twice this length is
    %   taken and multiplied by the window
    %   FftData       - Fft Data matrix
    %   Tag           - Tag to find object
    %   Win           - Window to use on audio signal standard the sqrt(hanning(2*WindowSize)) is used
    %
    %   Written for the BSc graduation project Acoustic Enhancement via
    %   Beamforming Using Smartphones.
    %
    %   Team:       S. Bosma                R. Brinkman
    %               T. de Rooij             R. Smeding
    %               N. van Wijngaarden      E. Wouters
    %
    %   Supervisor: Jorge Martínez Castañeda
    %
    %   Contact: E.H.Wouters@student.tudelft.nl
    %
    %   See also BF_DATA, MAIN_WINDOW
    
    %% Properties
    properties
        MainObj                             % Handle of main object
        Name          = 'processor1';       % Name of Processor
        ChanNames     = {};                 % Channel names
        CurrentSample = 1;                  % Current sample
        WindowSize    = 2048;               % Size of window to process, twice this length is taken and multiplied by the window
        FftData       = [];                 % Fft Data matrix
        Tag           = 'std_processor';    % Tag to find object
        Win = sqrt(hanning(2*2048));        % Window to use on audio signal
    end
    methods
        function obj = std_processor(mainObj, chanNames)
            if nargin == 0
                obj.MainObj.DataBuffer = bf_data;
                help std_processor
            elseif nargin >= 1
                obj.MainObj = mainObj;
            end
            if nargin >= 2
%                 obj.ChanNames = obj.MainObj.DataBuffer.ChanNames(obj.MainObj.DataBuffer.names2inds(chanNames));
                obj.ChanNames = chanNames;
            end
        end
        
        function value = update(obj)
%             disp('Update recieved')
            value = 0;
            while obj.CurrentSample + obj.WindowSize*2 <= min(obj.MainObj.DataBuffer.CurrentSample(obj.MainObj.DataBuffer.names2inds(obj.ChanNames)))
                value = value + 1;
                % Load data from buffer
                dataIn = obj.MainObj.DataBuffer.getAudioData(obj.ChanNames,obj.CurrentSample,obj.CurrentSample+obj.WindowSize*2-1);
                
                % Call process function
%                 tic
                dataOut = obj.process(dataIn);
%                 toc
                % TODO return data to buffer or save in property
%                 disp(dataOut);
                obj.CurrentSample = obj.CurrentSample + obj.WindowSize;
                
                % Write back to buffer
                obj.MainObj.DataBuffer.addSamples(dataOut,obj.Name,1);
            end
        end
        
        function dataOut = process(obj, dataIn)
            if size(obj.Win,2) ~= size(obj.ChanNames,1)
                obj.Win = repmat(sqrt(hanning(2*obj.WindowSize)),1,size(obj.ChanNames,1));
            end
            dataOut = fft(dataIn.*obj.Win);
        end
    end
end