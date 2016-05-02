classdef FilterManager < handle
%FilterManager Manages filters found in +filters directory

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  methods
    function this = FilterManager(varargin)
    end

    % Scan the directory +filters and find out their names
    function names = loadFilters(this)
      filterPackage = 'filters';
      thisFileDir = fileparts(mfilename('fullpath'));
      filterFiles = what([thisFileDir '/+' filterPackage]);
      if isempty(filterFiles), return, end
      if isempty(this.Filters)
          this.Filters = struct('evalString', {}, 'Name', {});
      end
      for i=1:length(filterFiles.m)
        try
          evalStr = ([filterPackage '.' filterFiles.m{i}(1:end-2)]);
          name = eval([evalStr '.getName']);
          this.Filters(end+1) = struct('evalString', evalStr, ...
                                       'Name', name);
        catch me
          warning(me.identifier, me.message);
        end
      end
       if ~isempty(this.Filters)
         names = cell(length(this.Filters), 1);
         [names{:}] = this.Filters.Name;
      end
    end

    function y = filter(this, name, data, Fs)
        for i=1:length(this.Filters)
            if strcmp(name, this.Filters(i).Name)
                h = eval(this.Filters(i).evalString);
                break;
            end
        end
        y = h.filter(data, Fs);
    end
  end

  properties
    % FILTERS Structure with two fields Name and evalString
    % Name is the name of filter and evalString can be passed to eval
    % function to create the filter.
    Filters = [];
  end

end
