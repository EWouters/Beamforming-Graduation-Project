classdef std_class
    %% Standard Class Title 
    %  This class is only intended to serve as a template class
    %% Constants
    properties (Constant)
        Consts1 = consts;	% Constant property from another class
    end
    %% Properties
    properties
        Prop1 = 1;          % Prop 1
        Prop2;              % Prop 2
    end
    %% Methods
    methods
        %% Standard Constuctor
        function obj = std_class(varargin)
            disp('std_class object created')
            obj.Prop2 = 2;
        end
        %% Standard Function
        function varargout = std_func(obj, varargin)
            % Function that takes variable input arguments which are
            % checked for the right type and range
            % Validators
            % Classes: single | double | int8 | int16 | int32 | int64 | uint8 | uint16 | uint32 | uint64 | logical | char | struct | cell | function_handle
            % Attributes: 2d | 3d | column | row | scalar | vector | size , [d1,...,dN] | numel, N | ncols, N | nrows, N | ndims, N	| square | diag | nonempty | nonsparse
            % Range Attributes: '>', N | '>=', N | '<', N | '<=', N
            % Numeric Atributes: binary | even | odd | integer | real | finite | nonnan | nonnegative | nonzero | positive | decreasing | increasing | nondecreasing | nonincreasing
            % valid = @(x) validateattributes(x,classes,attributes,funcName,varName,argIndex)
            p = inputParser;        % Create input parser object
            valid1 = @(x) validateattributes(x,{'char'},{'numel',1});
            valid2 = @(x) validateattributes(x,{'numeric'},{'real','size',[2,2]});
            valid3 = @(x) validateattributes(x,{'numeric'},{'size',[1,1]});
            addRequired(p,'nameOfStrInput', valid1);
            addOptional(p,'nameOfNumInput',[1,2;3,4],valid2);
            addParameter(p,'numericParam',-1,valid3);
            parse(p,varargin{:})
            varargout = {p.Results};
            % Example:
            % obj = std_class
            % r = obj.std_func('A',[1,2;3,4],'numericParam',-2)
            % r = obj.std_func('A')
        end
    end
end