classdef contr < handle
    %% Control Class 
    %  This class will interface with the Computer audio interfaces
    %% Constants
    properties (Constant)
        Name = 'Control';
    end
    %% Properties
    properties
        MainWin              % Handle of main window
        Channels
        Data
        CBs
    end
    %% Methods
    methods
        %% Control Constuctor
        function obj = contr
            obj.MainWin = main_window;
            obj.Channels
            

            assignin('base','obj',bf_model)
        end

    end
end