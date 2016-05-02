classdef AudioSpectrogram < handle
%AudioSpectrogram Compute spectrogram

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  methods
    function this = AudioSpectrogram()
        % Create figure
        this.FigureHandle = figure( ...
                    'Menubar','none', ...
                    'Toolbar','figure', ...
                    'Position', [360,500,550,250], ...
                    'IntegerHandle', 'off', ...
                    'NumberTitle', 'off', ...
                    'Name', 'Audio Editor: Spectrogram',...
                    'CloseRequestFcn', @(hObj, evd) figureCloseCallback(this));
         % Remove all buttons except zoom in, out and data cursor
         tb = uitoolbar(this.FigureHandle);
         tth = findall(this.FigureHandle, 'Type', 'uitoolbar');
         ttb = findall(tth, 'Type', 'uitoggletool');
         copyobj(findobj(ttb, 'Tag', 'Exploration.ZoomIn'), tb);
         copyobj(findobj(ttb, 'Tag', 'Exploration.ZoomOut'), tb);
         set(this.FigureHandle, 'Toolbar', 'none', 'HandleVisibility', 'off');
    end

    function analyze(this, data, Fs)
      figure(this.FigureHandle);
      set(this.FigureHandle, 'HandleVisibility', 'on');
      if size(data, 2) == 1
          subplot(1,1,1);
          spectrogram(data, 256, 128, 256, Fs, 'yaxis');
      else
          subplot(2,1,1);
          spectrogram(data(:,1), 256, 128, 256, Fs, 'yaxis');
          subplot(2,1,2);
          spectrogram(data(:,2), 256, 128, 256, Fs, 'yaxis');
      end
      set(this.FigureHandle, 'HandleVisibility', 'off');
    end

    function figureCloseCallback(this)
        delete(this.FigureHandle);
        delete(this);
    end

    function delete(this)
        if ishandle(this.FigureHandle)
            delete(this.FigureHandle);
        end
    end
  end

  methods (Static)
    function name = getName()
        name = 'Spectrogram';
    end
    % This can be called for any change in cursor position
    function isd = isDynamic()
        isd = false;
    end
  end

  properties
      FigureHandle
  end

end
