classdef directivity_ui < handle
%% Directivity UI class
% Class select directivity measurements

    %% Properties
    properties
        Parent              % Handle of parent
        Name = 'Directivity'; % Name of UI
        UI                  % Cell UIs for the options
        Directivity = directivity;
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = directivity_ui(parent)
            %% Parse Input
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
            else
                if ishandle(parent)
                    obj.Parent = parent;
                else
                    warning(['First argument needs to be a handle,'...
                        'new figure created.']);
                    obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
                end
            end
%             disp('TODOTODOTODOTODOTODOTODO')
        end
    end
end