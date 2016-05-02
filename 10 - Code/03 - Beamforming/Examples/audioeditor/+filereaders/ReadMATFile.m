classdef ReadMATFile < handle
% Returns audio data stored in a MAT file.
% The file must contain two variables y (data) and Fs (sample rate).

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  methods
    function this = ReadMATFile(varargin)
    end

    function ext = getFileExtensions(this) %#ok<INUSD>
        ext = {'mat'};
    end

    function desc = getExtDescription(this) %#ok<INUSD>
        desc = 'MAT Files (*.mat)';
    end

    function setFilename(this, filename)
        this.Filename = filename;
    end

    function y = getData(this) %#ok<INUSD>
        y = [];
        load(this.Filename);
    end

    function Fs = getSampleRate(this) %#ok<INUSD>
        Fs = [];
        load(this.Filename);
    end
  end

  properties
      Filename
  end
end
