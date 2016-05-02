classdef rec2file
    %% Rec2file Class
    %  Class to record audio samples to file as .mat or .wav (or others)
    %%  Example:
    %   obj1 = rec2file
    %   obj1.save([1,2,3,4],1)
    %%

    %% Properties
    properties
        FileName                                        % Name of the audio file to save including extention
        FilePath                                        % Path of the audio file to save
        Title                                           % Title of recording
        Comment = 'Beamforming Audio recording';        % Add comment to audio file
    end
    %% Methods
    methods
        function save(obj,samples,fs)
            if isempty(obj.Title)
                obj.Title = sprintf('Recorded on %s',datestr(now));
            end
            if isempty([obj.FileName obj.FilePath])
                [obj.FileName,obj.FilePath] = uiputfile(...
                    {'*.wav','Waveform Audio File Format (*.wav)';...
                    '*.mat','MAT-files (*.mat)';...
                    '*.*',  'All Files (*.*)'},...
                    'Save File','FileName');
            end
            if isempty(strfind(obj.FileName,'.mat'))
                audiowrite(fullfile(obj.FilePath,obj.FileName),samples,fs,...
                    'BitsPerSample',16,'Comment',obj.Comment,...
                    'Title',obj.Title,'Artist','TU Delft Beamforming BSc Graduation EE');
            else
                audio.y = samples;
                audio.Fs = fs; %#ok<STRNU>
                save(fullfile(obj.FilePath,obj.FileName),'audio');
            end
        end
    end
end