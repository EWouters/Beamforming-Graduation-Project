classdef WelchPsd < handle
%WelchPsd Compute Welch spectral estimation

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  methods
    function this = WelchPsd()
        % Create figure and setup spectrum object
        this.FigureHandle = figure( ...
                    'Menubar','none', ...
                    'Toolbar','figure', ...
                    'Position', [360,500,250,150], ...
                    'IntegerHandle', 'off', ...
                    'NumberTitle', 'off', ...
                    'Name', 'Audio Editor: Welch PSD',...
                    'CloseRequestFcn', @(hObj, evd) figureCloseCallback(this));
         % Remove all buttons except zoom in, out and data cursor
         tb = uitoolbar(this.FigureHandle);
         tth = findall(this.FigureHandle, 'Type', 'uitoolbar');
         ttb = findall(tth, 'Type', 'uitoggletool');
         copyobj(findobj(ttb, 'Tag', 'Exploration.ZoomIn'), tb);
         copyobj(findobj(ttb, 'Tag', 'Exploration.ZoomOut'), tb);
         copyobj(findobj(ttb, 'Tag', 'Exploration.DataCursor'), tb);
         set(this.FigureHandle, 'Toolbar', 'none');
         this.PlotHandles(1) = plot(nan);
         hold on;
         this.PlotHandles(2) = plot(nan, 'r');
         set(this.FigureHandle, 'HandleVisibility', 'off');
         this.SpectrumObj = spectrum.welch;
         this.SpectrumObj.SegmentLength = 256;
    end

    function analyze(this, data, Fs)
      % Compute welch psd estimate and plot
      y = [data; zeros(this.SpectrumObj.SegmentLength-size(data,1), size(data,2))];
      for i=1:size(y,2)
        yp = psd(this.SpectrumObj, y(:,i), 'Fs', Fs);
        set(this.PlotHandles(i), 'XData', yp.Frequencies, ...
                                 'YData', 10*log10(yp.Data));
      end
      set(get(this.PlotHandles(1), 'Parent'), 'XLim', [0 Fs/2]);
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
        name = 'Welch PSD';
    end
    % This can be called for any change in cursor position
    function isd = isDynamic()
        isd = true;
    end
  end

  properties
      FigureHandle
      PlotHandles
      SpectrumObj
  end

end
