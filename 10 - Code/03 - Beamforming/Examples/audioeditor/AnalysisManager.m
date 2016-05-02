classdef AnalysisManager < handle
%AnalysisManager Manages all analyzers in +analyzers directory

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  methods
    function this = AnalysisManager(varargin)
    end

    % Scan the directory +analyzers and find out their names
    function names = loadAnalyzers(this)
      analyzerPackage = 'analyzers';
      thisFileDir = fileparts(mfilename('fullpath'));
      analyzerFiles = what([thisFileDir '/+' analyzerPackage]);
      if isempty(analyzerFiles), return, end
      if isempty(this.Analyzers)
          this.Analyzers = struct('evalString', {}, 'Name', {});
      end
      for i=1:length(analyzerFiles.m)
        try
          evalStr = ([analyzerPackage '.' analyzerFiles.m{i}(1:end-2)]);
          name = eval([evalStr '.getName']);
          this.Analyzers(end+1) = struct('evalString', evalStr, ...
                                         'Name', name);
        catch me
          warning(me.identifier, me.message);
        end
      end
       if ~isempty(this.Analyzers)
         names = cell(length(this.Analyzers), 1);
         [names{:}] = this.Analyzers.Name;
      end
    end

    % Remove the analyzer whose handle is src
    function removeAnalyzerCallback(this, src)
        idx = cellfun(@(a) isequal(a, src), this.ActiveAnalyzers);
        this.ActiveAnalyzers(idx) = [];
        this.ActiveAnalyzerNames(idx) = [];
    end

    function analyze(this, data, Fs, name)
        if nargin == 3
            % Run all active dynamic analyzers
            for i=1:length(this.ActiveAnalyzers)
                if this.ActiveAnalyzers{i}.isDynamic()
                    this.ActiveAnalyzers{i}.analyze(data, Fs);
                end
            end
        else
            % Run a specfic analyzer
            azer = createAnalyzer(this, name);
            if ~isempty(azer)
                azer.analyze(data, Fs);
            end
        end
    end
  end

  methods (Access=private)
    % Create analyzer with the given name
    function azer = createAnalyzer(this, name)
        azer = [];
        for i=1:length(this.ActiveAnalyzerNames)
            if strcmp(name, this.ActiveAnalyzerNames{i})
                azer = this.ActiveAnalyzers{i}; % Already created
                return;
            end
        end
        for i=1:length(this.Analyzers)
            if strcmp(name, this.Analyzers(i).Name)
                this.ActiveAnalyzers{end+1} = eval(this.Analyzers(i).evalString);
                this.ActiveAnalyzerNames{end+1} = this.ActiveAnalyzers{end}.getName();
                addlistener(this.ActiveAnalyzers{end}, 'ObjectBeingDestroyed', ...
                    @(src, evnt) removeAnalyzerCallback(this, src));
                azer = this.ActiveAnalyzers{end};
            end
        end
    end
  end

  properties
    % ANALYZERS Structure with two fields Name and evalString
    % Name is the name of analyzer and evalString can be passed to eval
    % function to create the analyzer.
    Analyzers = [];
    % ACTIVEANALYZERS Handles to analyzers which are currently instantiated
    ActiveAnalyzers = {};
    % ACTIVEANALYZERNAMES Names of analyzers which are currently
    % instantiated (in sync with ActiveAnalyzers)
    ActiveAnalyzerNames = {};
  end

end
