classdef AudioEditor < handle
%AudioEditor Create audio editor GUI
%   AudioEditor creates a GUI used for editing audio data. It supports
%   reading from a WAVE audio file, writing to a WAVE audio file, importing
%   from a MATLAB variable, exporting to a MATLAB variable and recording
%   from microphone. There are editing features like cut, copy, paste with
%   undo and redo support for them. There are also filters to process the
%   audio data and analyzers to analyze the data.
%
%   The file reading and writing support can be extended to other formats
%   by writing add-ons. For example, see the files in directory
%   +filereaders and +filewriters. Similarly the filters and analyzers also
%   can be extended. Look at the directories +filters and +analyzers for
%   examples of implementing them.
%
%   Importing and Exporting data (Data menu):
%    Audio data can be read from a file, imported from MATLAB expression or
%    recorded from microphone. Audio data can be written to a file and
%    exported to MATLAB workspace. All these operations can be performed
%    using the options available under the File menu. The File menu also
%    holds a list of most recent files used. Currently the default file
%    reader/writer supports only the files that can be read/write using
%    wavread/wavwrite commands.
%
%   Selecting data:
%    Data can be selected by clicking and dragging with the mouse on the
%    plot. The selection can be extended or reduced by right clicking on
%    the plot. The selected data will be shown with a different background
%    color and with red lines at the border on both ends.
%
%   Editing data:
%    Selected data can be cut or copied to clipboard by choosing the Cut or
%    Copy option under Edit menu. Data from clipboard can be pasted using
%    the Paste option under Edit menu. If no data is selected the data is
%    pasted at the cursor line. If some data is selected, the selected data
%    will be replaced by data from the clipboard. All the Cut, Copy and
%    Paste operations can be un-done or re-done. The Undo and Redo
%    operations are possible until new data is imported into the
%    AudioEditor.
%
%   Filtering data:
%    Selected data can be filtered by using the options from the Filter
%    menu. The selected data is passed through the filter and then the
%    result is used to replace the selected data. By default three filters
%    Digital Filter, Downsample and MATLAB Expression are available.
%    Digital Filter can be used to implement any linear filtering
%    operation by specifying the numerator and denominator coefficients of
%    the transfer function. Downsample can be used to down sample data by
%    any integer value. MATLAB Expression option can be used to operate
%    over the data using any MATLAB command.
%
%   Analyzing data:
%    The data can be analyzed by using the options under Analyze menu. By
%    default Welch PSD is available to analyze the frequency contents of
%    the data. If any data is selected, then the psd is taken for the
%    selected data. If no data is selected, then the psd is taken for 2048
%    samples around the cursor. When audio data is played or when the
%    cursor is moved the analysis window is continuously updated by using
%    the 2048 samples around the cursor.
%
%   Playback Buttons:
%    The play button plays the audio from the cursor location to the end if
%    no audio data is selected. Otherwise it plays the selected data. The
%    pause button pauses audio play and play can be resumed by pressing
%    the pause button again. Pressing the stop button stops audio playback.
%    Pressing the play button again when audio is being played stops the
%    current play and the play is started again from the original starting
%    location.
%
%   Other buttons:
%    File open button performs the same operation as the Read From File
%    option under File menu. The Save button performs the same operation as
%    the Write To File option under File menu. 
%
%    The Zoom in and Zoom out buttons perform zooming operation in the
%    x-axis. The button Fit Selection to axes, zooms the selected data to
%    fill the entire x-axis. The button Fit entire signal to axes does the
%    opposite, by fitting the entire audio signal in the axis.
%
%   Extending the AudioEditor:
%    You can implement your own filters and analyzers. The AudioEditor will
%    automatically identify and populate them in the corresponding menu.
%    For details see example code in the +filters and +analyzers directory.
%
%   Down sampled plot:
%    If the audio data to be plotted is very large, then the data is
%    downsampled before plotting for faster response. While down sampling,
%    the outliers in the data are detected and added to the data making the
%    plot look similar to plotting the orignal data. This is based on
%    the code from dsplot plotting routine by Jiro Doke in MATLAB Central.
%
%   Datatype support:
%    Currently only double and single precision data types are supported
%    for plotting.
%
%   Modifying path:
%    The directory in which this class lives is automatically added to the
%    MATLAB path.

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  properties (SetAccess = 'private', GetAccess='private')
    FigureHandle         % Handle to main figure window
    AxesHandles          % Handles to each axes. Each channel is in one axis
    ChannelHandles       % Handles to each channel's line plots
    Filename = which('speech_dft.wav');
    AudioData            % Audio data being edited
    iOutliers            % Used for down sampled plot
    jOutliers            % Used for down sampled plot
    Fs = 8000;           % Sample time
    FileReaders = [];    % File reader plugins
    FileFilterSpec = {}; % Spec used to filter files for uigetfile
    SelectorLines        % The lines used to select audio data in the editor
    SelectorPatchHandle  % Highlighting the area which is selected
    RecentFiles = {};    % Most recently used files
    RecentFilesMenu      % Handle to most recent used files menu
    AudioPlayer          % audioplayer object.
    Analyzer             % Object which manages all analyzers
    hFilterManager       % Object which manages all filters
    hFileWriterManager   % Object which manages all file writers
    UndoDataManager      % Manages undo and redo data
    Clipboard = ClipboardManager.getInstance; % Cut copy paste
  end

  properties (Constant = true, SetAccess = 'private', GetAccess='private')
    MaxRecentFiles = 4;  % Maximum number of files in most recent files list
    PreferenceGroupName = 'AudioEditor_ApplicationPrefs';
                         % group name for storing preferences
  end

  methods
    function this = AudioEditor(varargin)
      addpath(fileparts(mfilename('fullpath')));
      this.UndoDataManager = UndoManager;
      createFigure(this);
    end
  end

  methods (Access = 'private')

    function createFigure(this)
      fPos = [360,500,850,350];
      this.FigureHandle = figure( ...
                    'Visible','off', ...
                    'Menubar','none', ...
                    'Toolbar','figure', ...
                    'Position', fPos, ...
                    'IntegerHandle', 'off', ...
                    'Color',    get(0, 'defaultuicontrolbackgroundcolor'), ...
                    'NumberTitle', 'off', ...
                    'Name', 'Audio Editor', ...
                    'WindowButtonUpFcn', @(hobj, evd) figureButtonUpCallback(this), ...
                    'ResizeFcn', @(hObj, evd) resizeFcnCallback(this), ...
                    'CloseRequestFcn', @(hObj, evd) figureCloseCallback(this));

      hZoom = zoom(this.FigureHandle);
      hPan  = pan(this.FigureHandle);
      zoomFcn = @(hObject, eventdata) zoomCallback(this, hObject, eventdata);
      set(hZoom, 'Motion', 'horizontal', ...
                 'ActionPostCallback', zoomFcn);
      set(hPan , 'ActionPostCallback', zoomFcn);

      adjustFigure(this);
      this.AxesHandles = axes( ...
                  'Units','pixels', ...
                  'Box', 'on', ...
                  'ButtonDownFcn', @(hobj, evd) axesButtonDownCallback(this));
      hold on;

      set(this.FigureHandle, 'Name', ['Audio Editor: ' this.Filename]);
      movegui(this.FigureHandle, 'center');
      set(this.FigureHandle,'Visible','on');

      loadFileReaders(this);
      loadAudioFile(this, this.Filename); % default audio file
    end

    % Scan +filereaders directory for file reading objects
    function loadFileReaders(this)
      this.FileFilterSpec{1, 1} = '*.*';
      this.FileFilterSpec{1, 2} = 'All Files (*.*)';
      thisFileDir = fileparts(mfilename('fullpath'));
      readerPackage = 'filereaders';
      readers = what([thisFileDir '/+' readerPackage]);
      if isempty(readers), return, end
      if isempty(this.FileReaders)
        this.FileReaders = struct('Reader', [], 'Ext', {});
      end
      for i=1:length(readers.m)
        try
          h = eval([readerPackage '.' readers.m{i}(1:end-2)]);
          ext = h.getFileExtensions();
          if ~isempty(ext)
            this.FileReaders(end+1) = struct('Reader', h, 'Ext', {ext});
          end
          spec = '';
          for j=1:length(ext)
            spec = [spec '*.' ext{j} ';']; %#ok<AGROW>
          end
          this.FileFilterSpec{end+1, 1} = spec;
          this.FileFilterSpec{end, 2} = ''; % For protection if next call fails
          this.FileFilterSpec{end, 2} = h.getExtDescription();
        catch me
          warning(me.identifier, me.message);
        end
      end
    end

    % Things which need to be emptied when reading a new file
    function clearHandles(this)
      this.AxesHandles = [];
      this.ChannelHandles = [];
      this.SelectorLines = [];
      this.SelectorPatchHandle = [];
      this.UndoDataManager.clearUndoData();
    end

    % updates audio data in the plots. Also called for zoom callbacks.
    function updatePlot(this, range)
      range = floor(range * this.Fs);
      numPoints = 50000;
      len = length(this.ChannelHandles);
      x = (1:size(this.AudioData, 1))';
      id = find(x >= range(1) & x <= range(2));
      if length(id) > numPoints/len
        idx = round(linspace(id(1), id(end), round(numPoints/len)))';
        ol = this.iOutliers > id(1) & this.iOutliers < id(end);
        for i=1:len
          idxi = unique([idx; this.iOutliers(ol & this.jOutliers == i)]);
          set(this.ChannelHandles(i), 'XData', idxi/this.Fs, ...
                                      'YData', this.AudioData(idxi));
        end
      else
        for i=1:len
          set(this.ChannelHandles(i), 'XData', id/this.Fs, ...
                                      'YData', this.AudioData(id));
        end
      end
    end

    % Plots downsampled data. This has much faster response time. This is
    % based on dsplot by Jiro Doke in file exchange.
    % TODO Add data cursor callbacks
    function dsplot(this)
      len = length(this.AudioData);
      x = 1:len;
      % Find outliers
      filterWidth = min([50, ceil(length(x)/10)]); % max window size of 50
      a  = this.AudioData - ...
                filter(ones(filterWidth,1)/filterWidth, 1, this.AudioData);
      [this.iOutliers, this.jOutliers] = ...
             find(abs(a - repmat(mean(a), size(a, 1), 1)) > ...
                    repmat(4 * std(a), size(a, 1), 1));
      updatePlot(this, [0 len/this.Fs]);
    end

    function loadAudioFile(this, filename)
      [data, Fs, errFlag] = readAudioFile(this, filename);
      if ~errFlag
        this.Filename = filename;
        plotData(this, data, Fs);
        addToRecentFiles(this, this.Filename);
      end
    end

    % Plot audio data.
    function plotData(this, data, Fs)
      this.AudioData = data;
      this.Fs = Fs;
      sz = size(this.AudioData);
      clearHandles(this);
      set(this.FigureHandle, 'HandleVisibility', 'on');
      for i=1:sz(2)
        subplot(sz(2), 1, i),
        this.ChannelHandles(i) = plot(nan);   % Get a handle for plot
        this.AxesHandles(i) = get(this.ChannelHandles(i), 'Parent');
        set(this.AxesHandles(i), ...
              'ButtonDownFcn', @(hobj, evd) axesButtonDownCallback(this), ...
              'Units', 'Pixels');
        set(this.ChannelHandles(i), ...
              'ButtonDownFcn', @(hobj, evd) axesButtonDownCallback(this));
        axis([0 sz(1)/this.Fs -1 1]);
        zoom reset;     % Remember original zoom position
      end
      dsplot(this);
      addSelectorTool(this);
      set(this.FigureHandle, 'Name', ['Audio Editor: ' this.Filename], ...
                             'HandleVisibility', 'off');
      % If the number of axes changes we need to resize the axes
      resizeFcnCallback(this);
      linkaxes(this.AxesHandles); % link axes for zooming
    end

    % Read audio data from given file.
    function [data, Fs, errFlag] = readAudioFile(this, filename)
      reader = findReader(this, filename);
      if ~isempty(reader)
        try
            setFilename(reader, filename);
            data = getData(reader);
            Fs = getSampleRate(reader);
            errFlag = 0;
        catch ME
            errordlg(ME.message, 'AudioEditor:FileReader');
            data = [];
            Fs = [];
            errFlag = 1;
        end
      else
        data = [];
        Fs = [];
        errFlag = 1;
      end
    end

    % Find the audio file reader which will read the given filename.
    % The search is based on the filename extension.
    function reader = findReader(this, filename)
      reader = [];
      [p,n,ext] = fileparts(filename);
      ext = ext(2:end); % Remove .
      for i=1:length(this.FileReaders)
        if ismember(ext, this.FileReaders(i).Ext)
          reader = this.FileReaders(i).Reader;
          break;
        end
      end
      if isempty(reader)
        errordlg('This file extension is not supported.', ...
                 'AudioEditor:cantFindReader');
      end
    end

    function createToolbar(this)
      audiotb = uitoolbar(this.FigureHandle);
      addPlaybackControls(this, audiotb);

      tth = findall(this.FigureHandle, 'Type', 'uitoolbar');
      ttb = findall(tth, 'Type', 'uipushtool');

      % Set callback for file open button
      fo = findobj(ttb, 'Tag', 'Standard.FileOpen');
      set(fo, 'Separator', 'on', 'ClickedCallback', ...
              @(hobj, evd) fileOpenCallback(this));
      copyobj(fo, audiotb);

      % copy standard buttons to our toolbar
      fo = findobj(ttb, 'Tag', 'Standard.SaveFigure');
      set(fo, 'ClickedCallback', @(hobj, evd) fileWriteCallback(this));
      copyobj(fo, audiotb);

      copyobj(findobj(ttb, 'Tag', 'Standard.PrintFigure'), audiotb);

      ttb = findall(tth, 'Type', 'uitoggletool');
      copyobj(findobj(ttb, 'Tag', 'Exploration.ZoomIn'), audiotb);
      copyobj(findobj(ttb, 'Tag', 'Exploration.ZoomOut'), audiotb);
      copyobj(findobj(ttb, 'Tag', 'Exploration.DataCursor'), audiotb);

      % Add zoom to selection button
      [cd,m,alpha] = imread('icons/ae_zoom_select.png');
      cd = double(cd) / 255;
      cd(~alpha) = NaN;
      uipushtool(audiotb, 'CData', cd, ...
           'TooltipString', 'Fit selection to axes', ...
           'HandleVisibility','off',...
           'ClickedCallback', @(hobj, evd) zoomSelectionCallback(this));

      % Add zoom out back to full signal button
      [cd,m,alpha] = imread('icons/ae_zoom_outfull.png');
      cd = double(cd) / 255;
      cd(~alpha) = NaN;
      uipushtool(audiotb, 'CData', cd, ...
           'TooltipString', 'Fit entire signal to axes', ...
           'HandleVisibility','off',...
           'ClickedCallback', @(hobj, evd) zoomOutfullCallback(this));

      % Move data cursor button to the end
      ttc = allchild(audiotb);
      ttc(1:3) = ttc([3 1 2]);
      set(audiotb, 'Children', ttc);
      set(this.FigureHandle, 'Toolbar', 'none');
    end

    function createMenubar(this)
      mhData = uimenu(this.FigureHandle, 'Label', 'Data');
      uimenu(mhData, 'Label', 'Read From File...', 'Callback', ...
             @(hobj, evd) fileOpenCallback(this));
      uimenu(mhData, 'Label', 'Write To File...', 'Callback', ...
             @(h, evd) fileWriteCallback(this));
      uimenu(mhData, 'Label', 'Read From MATLAB...', 'Callback', ...
             @(h, evd) fromMATLABCallback(this));
      uimenu(mhData, 'Label', 'Write To MATLAB...', 'Callback', ...
             @(h, evd) toMATLABCallback(this));
      uimenu(mhData, 'Label', 'Record From Mic...', 'Callback', ...
             @(h, evd) fromMicCallback(this));
      this.RecentFilesMenu = uimenu(mhData, 'Label', 'Recent Files');
      recentfilenames = getpref(this.PreferenceGroupName, ...
                                'RecentFilesList', which('speech_dft.wav'));
      addToRecentFiles(this, recentfilenames);
      mhEdit = uimenu(this.FigureHandle, 'Label', 'Edit');
      hUndo = uimenu(mhEdit, 'Label', 'Undo', 'Callback',...
           @(hobj, evd) undoCallback(this));
      hRedo = uimenu(mhEdit, 'Label', 'Redo', 'Callback',...
           @(hobj, evd) redoCallback(this));
      this.UndoDataManager.setUndoRedoMenuHandles(hUndo, hRedo);
      hSelectAll = uimenu(mhEdit, 'Label', 'Select All', ...
                    'Callback', @(hobj, evd) selectAllCallback(this));
      set(hSelectAll, 'Separator', 'on');
      hcutMenu = uimenu(mhEdit, 'Label', 'Cut', ...
                    'Callback', @(hobj, evd) cutCallback(this));
      set(hcutMenu, 'Separator', 'on');
      uimenu(mhEdit, 'Label', 'Copy', ...
                    'Callback', @(hobj, evd) copyCallback(this));
      uimenu(mhEdit, 'Label', 'Paste', ...
                    'Callback', @(hobj, evd) pasteCallback(this));
      uimenu(mhEdit, 'Label', 'Paste Add', ...
                    'Callback', @(hobj, evd) pasteAddCallback(this, hobj));
      uimenu(mhEdit, 'Label', 'Paste Substract', ...
                    'Callback', @(hobj, evd) pasteAddCallback(this, hobj));
      createFilterMenu(this);
      createAnalyzeMenu(this);
    end

    function createAnalyzeMenu(this)
      hAnalyze = uimenu(this.FigureHandle, 'Label', 'Analyze');
      names = loadAnalyzers(this);
      for i=1:length(names)
        uimenu(hAnalyze, 'Label', names{i}, 'Callback', ...
               @(obj, eventdata) analyzerCallback(this, obj));
      end
    end
  
    function names = loadAnalyzers(this)
      this.Analyzer = AnalysisManager;
      names = this.Analyzer.loadAnalyzers();
    end

    function createFilterMenu(this)
      hFilter = uimenu(this.FigureHandle, 'Label', 'Filter');
      names = loadFilters(this);
      for i=1:length(names)
        uimenu(hFilter, 'Label', names{i}, 'Callback', ...
               @(obj, eventdata) filterCallback(this, obj));
      end
    end

    function names = loadFilters(this)
      this.hFilterManager = FilterManager;
      names = this.hFilterManager.loadFilters();
    end

    function addToRecentFiles(this, filenames)
      if ~iscell(filenames)
        filenames = {filenames};
      end
      % Update file list
      for i=1:length(filenames)
        [found, loc] = ismember(filenames{i}, this.RecentFiles);
        if found % Move to the top if already on the list
          this.RecentFiles = {this.RecentFiles{loc} this.RecentFiles{(1:end)~=loc}};
        else
          if length(this.RecentFiles) < this.MaxRecentFiles % add to end
            this.RecentFiles(2:end+1) = this.RecentFiles(1:end);
          else % cycle
            this.RecentFiles(2:end) = this.RecentFiles(1:end-1);
          end
          this.RecentFiles(1) = filenames(i);
         end
      end
      % Update menu
      delete(get(this.RecentFilesMenu, 'Children')); % delete existing menu
      for i=1:length(this.RecentFiles)
        [p, n, e] = fileparts(this.RecentFiles{i});
        uimenu(this.RecentFilesMenu, 'Label', [n e], 'UserData', i, ...
               'Callback', @(hobj, evd) recentFilesCallback(this, hobj));
      end
    end

    function adjustFigure(this)
      createToolbar(this);
      createMenubar(this);
    end

    % Add audio play back controls.
    function addPlaybackControls(this, parent)
      % Add playback controls
      load audiotoolbaricons;
      uipushtool(parent, 'CData', play_on,...
                   'TooltipString', 'Play',...
                   'HandleVisibility','off',...
                   'ClickedCallback', @(hobj, evd) playCallback(this));
      uipushtool(parent, 'CData', pause_default,...
                   'TooltipString', 'Pause',...
                   'HandleVisibility','off',...
                   'ClickedCallback', @(hobj, evd) pauseCallback(this));
      uipushtool(parent, 'CData', stop_default,...
                   'TooltipString', 'Stop',...
                   'HandleVisibility','off',...
                   'ClickedCallback', @(hobj, evd) stopCallback(this));
    end

    % Add the selector lines and the gray selection highlight area.
    function addSelectorTool(this)
      cbFcn = @(hobj, evd) selectButtonDownCallback(this, hobj);
      for i=1:length(this.AxesHandles)
        axes(this.AxesHandles(i));
        this.SelectorLines(1, i) = line([0 0], [-1 1], ...
                                        'ButtonDownFcn', cbFcn, ...
                                        'Parent', this.AxesHandles(i));
        this.SelectorLines(2, i) = line([0 0], [-1 1], ...
                                        'ButtonDownFcn', cbFcn, ...
                                        'Parent', this.AxesHandles(i));
        this.SelectorPatchHandle(i) = patch([0 0 0 0], [-1 1 1 -1], ...
                                  [0.5 0.5 0.5], 'FaceAlpha', 0.5, ...
                                  'EdgeColor', [1 0 0], ...
                                  'HitTest', 'off', ...
                                  'Parent', this.AxesHandles(i));
      end
    end

    % Return the points where the selector lines are.
    % The first point is always smaller.
    function [xd1, xd2] = getSelectionPoints(this)
      xd1 = get(this.SelectorLines(1), 'XData');
      xd2 = get(this.SelectorLines(2), 'XData');
      if xd1(1) > xd2(1) % Make xd1 the smaller
        temp = xd1;
        xd1 = xd2;
        xd2 = temp;
      end
    end

    function [xd1, xd2] = getSelectionSampleNumbers(this)
      [xd1, xd2] = getSelectionPoints(this);
      xd1 = floor(xd1*this.Fs);
      xd2 = floor(xd2*this.Fs);
    end

    function stopAudioPlayer(this)
      if ~isempty(this.AudioPlayer)
        stop(this.AudioPlayer); % StopFcn is not called when player is paused
        h = this.AudioPlayer.UserData;
        if ishandle(h)
          delete(h);
        end
      end
    end

    function data = getCurrentData(this, x1, x2)
      if x1 ~= x2
        % Get selected data
        data = this.AudioData(x1(1)+1:x2(1), :);
      else
        % Get 2048 samples around cursor
        % 1048 on the left side and 1047 on the right. If the cursor is
        % close to the extremes the first or the last 2048 samples are
        % returned.
        audioLen = size(this.AudioData, 1);
        if x1 - 1024 >= 1 && x1+1024 < audioLen
          data = this.AudioData(x1-1024:x1+1023, :);
        elseif x1 - 1024 >= 1 && audioLen >= 2048
          data = this.AudioData(end-2047:end, :);
        elseif x1+1024 < audioLen && audioLen >= 2048
          data = this.AudioData(1:2048, :);
        else % audioLen < 2048
          data = [this.AudioData; zeros(2048-audioLen ,size(this.AudioData, 2))];
        end
      end
    end

  end % Private methods

  methods (Access = 'public', Hidden = true) % Callback methods

    function resizeFcnCallback(this)
      fPos = get(this.FigureHandle, 'Position');
      len = length(this.AxesHandles);
      h = round((fPos(4)-45-5*len)/len); % Height of each axis
      for i=0:len-1
        set(this.AxesHandles(len-i), 'Position', [35 45+h*i+5*i fPos(3)-60 h]);
        set(this.AxesHandles(len-i), 'plotBoxAspectRatio', [(fPos(3)-60)/h 1 1]);
        % Setting PlotBoxAspectRatio keeps the axis box on
        if i ~= 0
          % Need XTicks only for bottom axis
          set(this.AxesHandles(len-i), 'XTick', []);
        end
      end
    end

    function fileOpenCallback(this)
      [filename, pathname] = ...
               uigetfile(this.FileFilterSpec, 'Audio file to read', ...
                         this.Filename);
      if ~(isequal(filename,0) || isequal(pathname,0))
        loadAudioFile(this, [pathname filename]);
      end
    end
    
    function fromMicCallback(this)
      [y, Fs] = RecordFromMic;
      if ~isempty(y) && ~isempty(Fs)
        this.Filename = 'From Microphone';
        plotData(this, y, Fs);
      end
    end

    function fileWriteCallback(this)
      if isempty(this.hFileWriterManager)
         this.hFileWriterManager = FileWriterManager;
      end
      fileName = this.hFileWriterManager.writeFile(this.AudioData, this.Fs);
      if ~isempty(fileName)
        addToRecentFiles(this, fileName);
      end
    end

    function fromMATLABCallback(this)
      [varName, Fs] = getFromMATLABVarNameandFs();
      if ~isempty(varName)
        this.Filename = varName;
        plotData(this, evalin('base', varName), Fs);
      end
    end

    function toMATLABCallback(this)
      [varName, FsName] = getToMATLABVarNameandFs();
      if ~isempty(varName) && ~isempty(FsName)
        if ~isvarname(varName) || ~isvarname(FsName)
          errordlg('Invalid variable name.', 'Audio Editor: Error');
        end
        assignin('base', varName, this.AudioData);
        assignin('base', FsName, this.Fs);
      end
    end

    function recentFilesCallback(this, hObject)
      fileIdx = get(hObject, 'UserData');
      fileName = this.RecentFiles{fileIdx};
      if ~exist(fileName, 'file')
          errordlg(['The file ' fileName 'does not exist in path.'], ...
                   'AudioEditor:cantFindFile');
      end
      loadAudioFile(this, fileName);
    end

    % Play audio
    function playCallback(this)
      stopAudioPlayer(this);
      [xd1, xd2] = getSelectionSampleNumbers(this);
      if xd1(1) == xd2(1)
        xd2(1) = size(this.AudioData, 1);
      end
      hl = zeros(length(this.AxesHandles), 1);
      for i=1:length(this.AxesHandles)
        axes(this.AxesHandles(i)); % Make this current axis
        hl(i) = line([xd1(1) xd1(1)]/this.Fs, [-1 1], 'Color', [1 0 0], ...
                     'Parent', this.AxesHandles(i));
      end
      this.AudioPlayer = audioplayer(this.AudioData(xd1(1)+1:xd2(1), :), this.Fs);
      set(this.AudioPlayer, 'TimerPeriod', 0.05, 'UserData', hl, ...
          'TimerFcn', @(ap, evd) audioPlayerCallbackTimer(this, ap, hl, xd1(1)), ...
          'StopFcn',  @(ap, evd) audioPlayerCallbackStop(this, ap, hl));
      play(this.AudioPlayer);
    end

    % Pause audio playback
    function pauseCallback(this)
      if ~isempty(this.AudioPlayer)
        if isplaying(this.AudioPlayer)
          pause(this.AudioPlayer);
        elseif this.AudioPlayer.CurrentSample ~= 1
          % resume only if it is paused
          resume(this.AudioPlayer);
        end
      end
    end

    % Stop audio playback
    function stopCallback(this)
      stopAudioPlayer(this);
    end

    % Position both selection lines at the mouse click point
    function axesButtonDownCallback(this)
      maxxd = size(this.AudioData, 1)/this.Fs;
      cp = get(this.AxesHandles(1), 'CurrentPoint');
      if cp(1) > maxxd || cp(1) < 0
          return;
      end
      if strcmp(get(this.FigureHandle,'SelectionType'),'normal')
        % Move selector lines to this point
        set(this.SelectorLines, 'XData', [cp(1) cp(1)]);
        set(this.SelectorPatchHandle, 'XData', [cp(1) cp(1) cp(1) cp(1)]);
        hLine = this.SelectorLines(1,:);
        set(this.FigureHandle, 'WindowButtonMotionFcn', ...
            @(hobj, evd) selectLineDragCallback(this, hLine));
      elseif strcmp(get(this.FigureHandle,'SelectionType'),'alt') % right click
        xd1 = get(this.SelectorLines(1), 'XData');
        xd2 = get(this.SelectorLines(2), 'XData');
        % Find closest line and move that to this point
        if abs(xd1(1)-cp(1)) < abs(xd2(1)-cp(1))
          set(this.SelectorLines(1,:), 'XData', [cp(1) cp(1)]);
          set(this.SelectorPatchHandle, 'XData', [cp(1) cp(1) xd2(1) xd2(1)]);
        else
          set(this.SelectorLines(2,:), 'XData', [cp(1) cp(1)]);
          set(this.SelectorPatchHandle, 'XData', [xd1(1) xd1(1) cp(1) cp(1)]);
        end
      end
    end

    % Enable dragging of selection lines at the mouse click point
    function selectButtonDownCallback(this, hObject)
      if strcmp(get(this.FigureHandle,'SelectionType'),'normal')
        [r, c] = find(this.SelectorLines == hObject); %#ok<NASGU>
        hLine = this.SelectorLines(1,:);
        set(this.FigureHandle, 'WindowButtonMotionFcn', ...
            @(hobj, evd) selectLineDragCallback(this, hLine));
      end
    end

    % Drag selection lines
    function selectLineDragCallback(this, hLine)
      if strcmp(get(this.FigureHandle,'SelectionType'),'normal')
        maxxd = size(this.AudioData, 1)/this.Fs;
        cp = get(this.AxesHandles(1), 'CurrentPoint');
        if cp(1,1) > maxxd
          cp(1,1) = maxxd;
        elseif cp(1,1) < 0
          cp(1,1) = 0;
        end
        set(hLine, 'XData', [cp(1,1) cp(1,1)]);
        xd = zeros(1, 4);
        xd(1:2) = get(this.SelectorLines(1), 'XData');
        xd(3:4) = get(this.SelectorLines(2), 'XData');
        set(this.SelectorPatchHandle, 'XData', xd);
      end
    end

    function selectAllCallback(this)
      set(this.SelectorLines(1, :), 'XData', [0 0]);
      len = size(this.AudioData, 1)/this.Fs;
      set(this.SelectorLines(2, :), 'XData', [len len]);
      set(this.SelectorPatchHandle, 'XData', [0 0 len len]);
    end

    % Stop selection drag
    function figureButtonUpCallback(this)
      set(this.FigureHandle, 'WindowButtonMotionFcn', '');
      [xd1, xd2] = getSelectionSampleNumbers(this);
      data = getCurrentData(this, xd1(1), xd2(1));
      this.Analyzer.analyze(data, this.Fs);
    end

    % cut
    function cutCallback(this)
      [xd1, xd2] = getSelectionSampleNumbers(this);
      this.Clipboard.Data = this.AudioData(xd1(1)+1:xd2(1), :);
      this.AudioData(xd1(1)+1:xd2(1), :) = [];
      dsplot(this);
      this.UndoDataManager.pushData(this.Clipboard.Data, ...
                    [], xd1(1), xd2(1), xd1(1));
      xd1 = xd1 / this.Fs;
      set(this.SelectorLines, 'XData', xd1);
      set(this.SelectorPatchHandle, 'XData', [xd1(1) xd1(1) xd1(1) xd1(1)]);
    end

    % copy
    function copyCallback(this)
      [xd1, xd2] = getSelectionSampleNumbers(this);
      this.Clipboard.Data = this.AudioData(xd1(1)+1:xd2(1), :);
    end

    % paste
    function pasteCallback(this)
      [xd1, xd2] = getSelectionSampleNumbers(this);
      this.UndoDataManager.pushData(this.AudioData(xd1(1)+1:xd2(1), :), ...
                                    this.Clipboard.Data, ...
                                    xd1(1), xd2(1),...
                                    xd1(1)+size(this.Clipboard.Data,1));
      this.AudioData = [this.AudioData(1:xd1(1), :); ...
                        this.Clipboard.Data; ...
                        this.AudioData(xd2(1)+1:end, :)];
      dsplot(this);
      xd1 = xd1 / this.Fs;
      xd2 = xd1 + size(this.Clipboard.Data, 1)/this.Fs;
      if get(this.SelectorLines(1), 'XData') <  get(this.SelectorLines(2), 'XData')
        set(this.SelectorLines(2,:), 'XData', xd2);
      else
        set(this.SelectorLines(1,:), 'XData', xd2);
      end
      set(this.SelectorPatchHandle, 'XData', [xd1(1) xd1(1) xd2(1) xd2(1)]);
    end

    % paste add
    function pasteAddCallback(this, hobj)
      [xd1, xd2] = getSelectionSampleNumbers(this);
      xd2(1) = xd1(1) + size(this.Clipboard.Data, 1);
      if xd2(1) > size(this.AudioData, 1)
          xd2(1) = size(this.AudioData, 1);
      end
      this.UndoDataManager.pushData(this.AudioData(xd1(1)+1:xd2(1), :), ...
                                    this.Clipboard.Data, ...
                                    xd1(1), xd2(1),...
                                    xd1(1)+size(this.Clipboard.Data,1));
      if strcmp(get(hobj, 'Label'), 'Paste Add')
          this.AudioData(xd1(1)+1:xd2(1), :) = ...
                        this.AudioData(xd1(1)+1:xd2(1), :) +...
                        this.Clipboard.Data(1:(xd2(1)-xd1(1)), :);
      else
          this.AudioData(xd1(1)+1:xd2(1), :) = ...
                        this.AudioData(xd1(1)+1:xd2(1), :) -...
                        this.Clipboard.Data(1:(xd2(1)-xd1(1)), :);
      end
      dsplot(this);
    end

    % undo
    function undoCallback(this)
      [data, x1, x2] = this.UndoDataManager.getUndoData();
      if ~isempty(x1)
        this.AudioData = [this.AudioData(1:x1(1), :); data; ...
                          this.AudioData(x2(1)+1:end, :)];
      end
      dsplot(this);
    end

    % redo
    function redoCallback(this)
      [data, x1, x2] = this.UndoDataManager.getRedoData();
      if ~isempty(x1)
        this.AudioData = [this.AudioData(1:x1(1), :); data; ...
                          this.AudioData(x2(1)+1:end, :)];
      end
      dsplot(this);
    end

    % zoom
    function zoomCallback(this, hFig, eventdata)
      switch get(hFig, 'SelectionType')
        case {'normal', 'alt'}
          xlimits = xlim(eventdata.Axes);
        case 'open'
          xlimits = [0 size(this.AudioData, 1)/this.Fs];
      end
      updatePlot(this, xlimits);
    end

    % Callback for fit selection to the axis button
    function zoomSelectionCallback(this)
      [xd1, xd2] = getSelectionPoints(this);
      if xd1(1) ~= xd2(1)
        updatePlot(this, [xd1(1) xd2(1)]);
        set(this.AxesHandles, 'XLim', [xd1(1) xd2(1)]);
      end
    end

    % Callback for fit entire signal to the axis button
    function zoomOutfullCallback(this)
      xlimits = [0 size(this.AudioData, 1)/this.Fs];
      updatePlot(this, xlimits);
      set(this.AxesHandles, 'XLim', xlimits);
    end

    % Callback from analysis menu
    function analyzerCallback(this, obj)
      aName = get(obj, 'Label');
      [xd1, xd2] = getSelectionSampleNumbers(this);
      data = getCurrentData(this, xd1(1), xd2(1));
      this.Analyzer.analyze(data, this.Fs, aName);
    end

    function filterCallback(this, obj)
      [xd1, xd2] = getSelectionSampleNumbers(this);
      x1 = xd1(1); x2 = xd2(1);
      if x1 ~= x2
        % Send selected data to filter
        y = this.hFilterManager.filter(get(obj, 'Label'), ...
                            this.AudioData(x1+1:x2, :), this.Fs);
        this.UndoDataManager.pushData(this.AudioData(xd1(1)+1:xd2(1), :), ...
                                      y, xd1(1), xd2(1), xd1(1)+size(y,1));
        % Insert received data
        this.AudioData = [this.AudioData(1:x1,:); y; ...
                          this.AudioData(x2+1:end, :)];
        dsplot(this); % Update plot
        % Update selection
        set(this.SelectorLines(1,:), 'XData', xd1/this.Fs);
        xd2 = xd1 + size(y,1);
        set(this.SelectorLines(2,:), 'XData', xd2/this.Fs);
        set(this.SelectorPatchHandle, 'XData', [xd1, xd2]/this.Fs);
      else
        helpdlg('Data needs to be selected for applying filter.', ...
                'Audio Editor: help');
      end
    end

    function audioPlayerCallbackTimer(this, ap, hl, offset)
      if ~ishandle(hl), return, end
      x = get(ap, 'CurrentSample') + offset;
      set(hl, 'XData', [x x]/this.Fs);
      data = getCurrentData(this, x, x);
      this.Analyzer.analyze(data, this.Fs);
    end

    function audioPlayerCallbackStop(this, ap, hl) %#ok<INUSL>
      % This is also called when player is paused
      if ishandle(hl(1)) && (get(ap, 'CurrentSample') == 1 || ...
         get(ap, 'CurrentSample') == get(ap, 'TotalSamples'))
        delete(hl);
      end
    end

    function figureCloseCallback(this)
      stopAudioPlayer(this);
      setpref(this.PreferenceGroupName, 'RecentFilesList', this.RecentFiles);
      delete(this.FigureHandle);
      delete(this);
    end

  end % public Methods

end
% ---------------------- End of class definition --------------------------
