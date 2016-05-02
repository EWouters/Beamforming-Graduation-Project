classdef FileWriterManager < handle
%FileWriterManager Manage file writer add-ons in +filewriters directory

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  methods
      function this = FileWriterManager
      end
      
      function fileName = writeFile(this, data, Fs)
        fileName = FileWriterManager.getFileName();
        if isempty(fileName)
          return;
        end
        if isempty(this.FileWriters)
          % First time: Scan all file writers
          scanFileWriters(this);
        end
        [p, name, ext] = fileparts(fileName);
        % Find writer based on extension
        for i=1:length(this.FileWriters)
          if strcmp(ext, this.FileWriters(i).Ext)
            % Send it to writer
            writer = eval(this.FileWriters(i).evalString);
            writer.write(fileName, data, Fs);
            return;
          end
        end
        errordlg('File writer for this extension not found.', ...
                 'Audio Editor: File writing');
      end
  end

  methods (Access=private)
    function scanFileWriters(this)
      fileWriterPackage = 'filewriters';
      thisFileDir = fileparts(mfilename('fullpath'));
      fileWriterFiles = what([thisFileDir '/+' fileWriterPackage]);
      if isempty(fileWriterFiles), return, end
      if isempty(this.FileWriters)
          this.FileWriters = struct('evalString', {}, 'Ext', {});
      end
      for i=1:length(fileWriterFiles.m)
        try
          evalStr = ([fileWriterPackage '.' fileWriterFiles.m{i}(1:end-2)]);
          ext = eval([evalStr '.getExt']);
          this.FileWriters(end+1) = struct('evalString', evalStr, ...
                                           'Ext', ext);
        catch me
          warning(me.identifier, me.message);
        end
      end
    end
  end
  
  methods (Static)
    function fileName = getFileName()
      fileName = '';
      FigureHandle = figure( ...
                    'Visible','off', ...
                    'Menubar','none', ...
                    'Toolbar','none', ...
                    'Position', [360,500,320,100], ...
                    'IntegerHandle', 'off', ...
                    'Color',    get(0, 'defaultuicontrolbackgroundcolor'), ...
                    'NumberTitle', 'off', ...
                    'Name', 'Audio Editor: Write to File');
      uicontrol('Parent', FigureHandle, 'Style', 'Text', ...
                'String', 'Filename:', ...
                'Units', 'Normalized', 'Position', [0 0.45 0.23 0.3], ...
                'FontSize', 12);
      hfile = uicontrol('Parent', FigureHandle, 'Style', 'edit', ...
                'String', 'output.wav', ...
                'Units', 'Normalized', 'Position', [0.23 0.5 0.57 0.3], ...
                'HorizontalAlignment', 'left', ...
                'FontSize', 12, 'BackgroundColor', 'white');
      uicontrol('Parent', FigureHandle, 'Style', 'pushbutton', ...
                'String', 'Browse', 'Units', 'Normalized', ...
                'Position', [0.8 0.5 0.2 0.3], 'FontSize', 12, ...
                'Callback', @browseCallback);
      uicontrol('Parent', FigureHandle, 'Style', 'pushbutton', ...
                'String', 'Write', 'Units', 'Normalized', ...
                'Position', [0.1 0 .4 0.3], 'FontSize', 12, ...
                'Callback', @writeCallback);
      uicontrol('Parent', FigureHandle, 'Style', 'pushbutton', ...
                'String', 'Cancel', 'Units', 'Normalized', ...
                'Position', [0.5 0 .4 0.3], 'FontSize', 12, ...
                'Callback', @cancelCallback);
      movegui(FigureHandle, 'center');
      set(FigureHandle', 'CloseRequestFcn', @cancelCallback);
      set(FigureHandle,'Visible','on');
      uiwait(FigureHandle);

      function writeCallback(h, evd) %#ok<INUSD,INUSD>
        fileName = get(hfile, 'String');
        delete(FigureHandle);
      end
      function cancelCallback(h, evd) %#ok<INUSD,INUSD>
        delete(FigureHandle);
      end
  end
end

  properties
    FileWriters
  end
end