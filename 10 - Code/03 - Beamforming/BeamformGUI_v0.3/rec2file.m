classdef rec2file
    %% Rec2file Class
    %  Class to record audio samples to file as .mat or .wav (or others)
    %%  Example:
    %   obj1 = rec2file
    %   obj1.save([1,2,3,4],1)
    %%

    %% Properties
    properties
        FileName       % Name of the audio file to save including extention
        FilePath       % Path of the audio file to save
        Title          % Title of recording
        Comment        % The Comment can be used to hold the locations
        BitsPerSample = 16;
        Fs
        Locations
        ChanNames
    end
    %% Methods
    methods
        function save(obj,samples,fs,locations)
            if isempty(obj.Title)
                obj.Title = sprintf('Recorded on %s',datestr(now));
            end
            if isempty([obj.FileName obj.FilePath])
                [obj.FileName,obj.FilePath] = uiputfile(...
                    {'*.wav','Waveform Audio File Format (*.wav)';...
                    '*.mat','MAT-files (*.mat)';...
                    '*.*',  'All Files (*.*)'},...
                    'Save File',fullfile(pwd, '\files', sprintf('Recording %s',datestr(now))));
            end
            if isempty(strfind(obj.FileName,'.mat'))
                audiowrite(fullfile(obj.FilePath,obj.FileName),samples,fs,...
                    'BitsPerSample',16,'Comment',obj.Comment,...
                    'Title',obj.Title,'Artist','TU Delft Beamforming BSc Graduation Project EE');
            else
                audio.y = samples;
                audio.Fs = fs;
                audio.BitsPerSample = 16;
                audio.Comment = mat2str(locations);
                save(fullfile(obj.FilePath,obj.FileName),'audio');
            end
        end
        
        %% Function to convert location to string
        function str = vars2str(names1, vars1)
            % input like ({'','',''},{var1,var2,var3}
            
            for ii = 1:length(names1)
                str = [str names1{ii} '|' mat2str(vars1{ii}) '|']; %#ok<AGROW>
            end
        end
    end
end