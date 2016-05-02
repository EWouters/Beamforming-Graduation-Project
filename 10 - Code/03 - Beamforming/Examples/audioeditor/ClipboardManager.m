classdef ClipboardManager < handle
%ClipboardManager Clipboard manager used by AudioEditor
%   C = ClipboardManager.getInstance returns a clipboard manager class.
%   This is singleton class and its main purpose is storing data.

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

  properties
      Data = [];
  end
  methods(Static)
    function obj = getInstance
      persistent Instance;
      if ~isa(Instance, 'ClipboardManager')
          Instance = ClipboardManager;
      end
      obj = Instance;
      mlock; % Lock so that we do not lose the persistent instance
    end
  end
  methods(Access=private)
    % Constructor
    function this = ClipboardManager
    end
  end
  
end
