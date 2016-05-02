classdef loadfile
    %% Rec2file Class
    %  Class to record audio samples to file as .mat or .wav (or others)
    %%  Example:
    %   obj = rec2file
    %   obj.save([1,2,3,4],1)
    %%

    %% Properties
    properties
        Name                                        % Name of the audio file to save including extention
        Path                                        % Path of the audio file to save
        Info
    end
    %% Methods
    methods
        function obj = loadfile
            obj.Name = '\Source1.wav';
            obj.Path = pwd;
        end
        function loadf(obj,path,name)
            
            if isempty([name path])
                [obj.fileName,obj.filePath] = uiputfile(...
                    {'*.wav','Waveform Audio File Format (*.wav)';...
                    '*.mat','MAT-files (*.mat)';...
                    '*.*',  'All Files (*.*)'},...
                    'Save File','fileName');
            end
            if isempty(strfind(obj.fileName,'.mat'))
                audiowrite(fullfile(obj.filePath,obj.fileName),samples,fs,...
                    'BitsPerSample',16,'Comment',obj.Comment,...
                    'Title',obj.Title,'Artist','TU Delft Beamforming BSc Graduation EE');
            else
                audio.y = samples;
                audio.Fs = fs; %#ok<STRNU>
                save(fullfile(obj.filePath,obj.fileName),'audio');
            end
        end
    end
end