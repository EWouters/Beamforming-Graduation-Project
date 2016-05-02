classdef ReadWaveFile < handle
%ReadWaveFile Read data from a WAVE file

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  methods
    function this = ReadWaveFile(varargin)
    end

    function ext = getFileExtensions(this) %#ok<INUSD>
        ext = {'wav'};
    end

    function desc = getExtDescription(this) %#ok<INUSD>
        desc = 'WAV Files (*.wav)';
    end

    function setFilename(this, filename)
        this.Filename = filename;
    end

    function data = getData(this)
        try
            data = wavread(this.Filename);
        catch ME
            rethrow(ME);
        end
    end

    function Fs = getSampleRate(this)
        [data, Fs] = wavread(this.Filename, 1);
    end
  end

  properties
    Filename
  end

end
