classdef RLSFilter < matlab.System
%RLSFilter Compute output, error and coefficients using Recursive Least
%          Squares (RLS) adaptive algorithm.
%
%   HRLS = dsp.RLSFilter returns an adaptive FIR filter System object(TM),
%   HRLS, that computes the filtered output, filter error and the filter
%   weights for a given input and desired signal using the Recursive Least
%   Squares (RLS) algorithm.
%
%   HRLS = dsp.RLSFilter('PropertyName', PropertyValue, ...) returns an RLS
%   filter System object, HRLS, with each specified property set to the
%   specified value.
%
%   HRLS = dsp.RLSFilter(LEN, 'PropertyName', PropertyValue, ...) returns
%   an RLS filter System object, HRLS, with the Length property set to LEN,
%   and other specified properties set to the specified values.
%
%   Step method syntax:
%
%   [Y, ERR] = step(HRLS, X, D) filters the input X, using D as the desired
%   signal, and returns the filtered output in Y and the filter error in
%   ERR. The System object estimates the filter weights needed to minimize
%   the error between the output signal and the desired signal. These
%   filter weights can be obtained by accessing the 'Coefficients' property
%   after calling the 'step' method by HRLS.Coefficients.
%
%   RLSFilter methods:
%
%   step     - See above description for use of this method
%   release  - Allow property value and input characteristics changes
%   clone    - Create RLSFilter object with same property values
%   isLocked - Locked status (logical)
%   reset    - Reset the internal states to initial conditions
%
%   RLSFilter properties:
%
%   Method                      - Method to calculate filter coefficients
%   Length                      - Length of filter coefficients vector
%   SlidingWindowBlockLength    - Width of the sliding window
%   ForgettingFactor            - RLS Forgetting factor
%   InitialCoefficients         - Initial coefficients of the filter
%   InitialInverseCovariance    - Initial inverse covariance
%   InitialSquareRootInverseCovariance  - Initial square root inverse
%                                         covariance
%   InitialSquareRootCovariance - Initial square root covariance
%   LockCoefficients            - Locks the coefficient updates (logical)
%
%   % EXAMPLE #1: System identification of an FIR filter
%      hrls1 = dsp.RLSFilter(11, 'ForgettingFactor', 0.98);
%      hfilt = dsp.FIRFilter('Numerator',fir1(10, .25)); % Unknown System
%      x = randn(1000,1);                       % input signal
%      d = step(hfilt, x) + 0.01*randn(1000,1); % desired signal
%      [y,e] = step(hrls1, x, d);
%      w = hrls1.Coefficients;
%      subplot(2,1,1), plot(1:1000, [d,y,e]);
%      title('System Identification of an FIR filter');
%      legend('Desired', 'Output', 'Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([hfilt.Numerator; w].');
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value');
%
%   % EXAMPLE #2: Noise cancellation
%      hrls2 = dsp.RLSFilter('Length', 11, 'Method', 'Householder RLS');
%      hfilt2 = dsp.FIRFilter('Numerator',fir1(10, [.5, .75]));
%      x = randn(1000,1);                           % Noise
%      d = step(hfilt2, x) + sin(0:.05:49.95)';     % Noise + Signal
%      [y, err] = step(hrls2, x, d);
%      subplot(2,1,1), plot(d), title('Noise + Signal');
%      subplot(2,1,2), plot(err), title('Signal');
%
%   See also dsp.LMSFilter, dsp.AffineProjectionFilter, dsp.FIRFilter,
%            dsp.FastTransversalFilter.

%   Copyright 1995-2013 The MathWorks, Inc.

%#codegen

    properties (Nontunable)
        %Method Method to calculate the filter coefficients
        %   Specify the method used to calculate filter coefficients as one
        %   of [{'Conventional RLS'} | 'Householder RLS' | 'Sliding-window
        %   RLS' | 'Householder sliding-window RLS' | 'QR-decomposition
        %   RLS'].
        Method = 'Conventional RLS';
    end
    
    properties (Nontunable, PositiveInteger)
        %Length Length of filter coefficients vector
        %   Specify the length of the FIR filter coefficients vector as a
        %   scalar positive integer value. The default value of this
        %   property is 32.
        Length = 32;
        
        %SlidingWindowBlockLength Width of the sliding window
        %   Specify the width of the sliding window as a scalar positive
        %   integer value greater than equal to the Length property value.
        %   This property is applicable only when the Method property is
        %   set to 'Sliding-window RLS' or 'Householder sliding-window
        %   RLS'. The default value of this property is 48.
        SlidingWindowBlockLength = 48;
    end
    
    properties
        %ForgettingFactor RLS Forgetting factor
        %   Specify the RLS forgetting factor as a scalar positive numeric
        %   value less than or equal to 1. Setting this property value to 1
        %   denotes infinite memory while adapting to find the new filter.
        %   The default value of this property is 1.
        ForgettingFactor = 1.0;
    
        %InitialCoefficients Initial coefficients of the filter
        %   Specify the initial values of the FIR adaptive filter
        %   coefficients as a scalar or a vector of length equal to the
        %   Length property value. The default value of this property is 0.
        InitialCoefficients = 0;
        
        %InitialInverseCovariance Initial inverse covariance
        %   Specify the initial values of the inverse covariance matrix of
        %   the input signal. This property must either be a scalar or a
        %   square matrix with each dimension equal to the Length property
        %   value. If a scalar value is set, the InverseCovariance property
        %   will be initialized to a diagonal matrix with diagonal elements
        %   equal to that scalar value. This property applies only when the
        %   Method property is set to 'Conventional RLS' or 'Sliding-window
        %   RLS'. The default value of this property is 1000.
        InitialInverseCovariance = 1e3;
        
        %InitialSquareRootInverseCovariance Initial square root inverse
        %                                   covariance
        %   Specify the initial values of the square root inverse
        %   covariance matrix of the input signal. This property must
        %   either be a scalar or a square matrix with each dimension equal
        %   to the Length property value. If a scalar value is set, the
        %   SquareRootInverseCovariance property will be initialized to a
        %   diagonal matrix with diagonal elements equal to that scalar
        %   value. This property applies only when the Method property is
        %   set to 'Householder RLS' or 'Householder sliding-window RLS'.
        %   The default value of this property is sqrt(1000).
        InitialSquareRootInverseCovariance = sqrt(1e3);
        
        %InitialSquareRootCovariance Initial square root covariance
        %   Specify the initial values of the square root covariance
        %   matrix of the input signal. This property must either be a
        %   scalar or a square matrix with each dimension equal to the
        %   Length property value. If a scalar value is set, the
        %   SquareRootCovariance property will be initialized to a diagonal
        %   matrix with diagonal elements equal to that scalar value. This
        %   property applies only when the Method property is set to
        %   'QR-decomposition RLS'. The default value of this property is
        %   sqrt(1/1000).
        InitialSquareRootCovariance = sqrt(1e-3);
    end
    
    properties (Logical)
        %LockCoefficients Lock the coefficient updates
        %   Specify whether the filter coefficient values should be locked.
        %   By default, the value of this property is false, and the object
        %   continuously updates the filter coefficients. When this
        %   property is set to true, the filter coefficients are not
        %   updated and their values remain at the current value.
        LockCoefficients = false;
    end
    
    properties (DiscreteState)
        %Coefficients Current coefficients of the filter
        %   This property stores the current coefficients of the filter
        %   as a row vector of length equal to the Length property value.
        %   This property is initialized to the values of
        %   InitialCoefficients property.
        Coefficients;
        
        %States Current internal states of the filter
        %   This property stores the current states of the filter as a
        %   column vector. Its length is equal to the Length property when
        %   the Method is 'Conventional RLS', 'Householder RLS', or
        %   'QR-decomposition RLS' and is equal to the value of (Length +
        %   SlidingWindowBlockLength) when the Method is 'Sliding-window
        %   RLS' or 'Householder sliding-window RLS'. This property is
        %   initialized to a zero vector of appropriate length.
        States;
        
        %DesiredStates Current desired states of the filter
        %   This property stores the current desired signal states of the
        %   adaptive filter as a column vector. Its length is equal to the
        %   SlidingWindowBlockLength property value. This property applies
        %   only when the Method is 'Sliding-window RLS' or 'Householder
        %   sliding-window RLS'. This property is initialized to a zero
        %   vector of appropriate length.
        DesiredStates;
        
        %InverseCovariance Current inverse covariance
        %   This property stores the current inverse covariance matrix of
        %   the input signal. It is a square matrix with each dimension
        %   equal to the Length property value. This property applies only
        %   when the Method property is 'Conventional RLS' or
        %   'Sliding-window RLS'. This property is initialized to the
        %   values of InitialInverseCovariance property.
        InverseCovariance;
        
        %SquareRootInverseCovariance Current square root inverse covariance
        %   This property stores the current square root inverse covariance
        %   matrix of the input signal. It is a square matrix with each
        %   dimension equal to the Length property value. This property
        %   applies only when the Method property is 'Householder RLS' or
        %   'Householder sliding-window RLS'. This property is initialized
        %   to the values of InitialSquareRootInverseCovariance property.
        SquareRootInverseCovariance;
        
        %SquareRootCovariance Current square root covariance
        %   This property stores the current square root covariance matrix
        %   of the input signal. It is a square matrix with each dimension
        %   equal to the Length property value. This property applies only
        %   when the Method property is 'QR-decomposition RLS'. This
        %   property is initialized to the values of
        %   InitialSquareRootCovariance property.
        SquareRootCovariance;
        
        %KalmanGain Current Kalman gain vector
        %   This property stores the current Kalman gain vector. It is a
        %   column vector of length equal to the Length property. This
        %   property does not apply when the Method property is
        %   'QR-decomposition RLS'. This property is initialized to a zero
        %   vector of appropriate length.
        KalmanGain;
        
        %ModifiedCrossCorrelation Modified input cross correlation vector
        %   This property stores the current modified input cross
        %   correlation vector, which is the square root inverse covariance
        %   multiplied by the time-average cross-correlation of the current
        %   input signal. This property is a column vector of length equal
        %   to the Length property. This property applies only when the
        %   Method property is 'QR-decomposition RLS'. This property is
        %   initialized to a zero vector of appropriate length.
        ModifiedCrossCorrelation;
    end
    
    properties (Access=protected)
        %FilterParameters Private property to store the filter parameters
        %   This is a private MATLAB structure that stores all the filter
        %   parameters in the appropriate data type. For RLSFilter System
        %   object, ForgettingFactor and LockCoefficients are the filter
        %   parameters. This property is initialized in the setup method.
        FilterParameters;
    end
    
    properties (Access=protected, Nontunable)
        %InputDataType Data type of the inputs
        %   This is a private property that stores the data type of the
        %   inputs and it is used to set the data type of all the
        %   DiscreteState properties and the outputs.
        InputDataType;
    end
    
    properties(Constant, Hidden)
        MethodSet = matlab.system.StringSet( { ...
            'Conventional RLS', ...
            'Householder RLS', ...
            'Sliding-window RLS', ...
            'Householder sliding-window RLS', ...
            'QR-decomposition RLS'} );
    end
    
    
    methods
        % RLS Filter Constructor
        function obj = RLSFilter(varargin)
            % Support name-value pair arguments as well as alternatively
            % allow 'Length' to be value only argument.
            setProperties(obj, nargin, varargin{:}, 'Length');
        end
        
        % Validating ForgettingFactor
        function set.ForgettingFactor(obj,val)
            coder.internal.errorIf(~isscalar(val) || val <= 0 || val > 1 || ~isreal(val), ...
                'dsp:system:AdaptiveFilter:mustBeRealScalar0to1LeftOpen', 'ForgettingFactor');
            obj.ForgettingFactor = val;
        end
        
        % Validating InitialCoefficients
        function set.InitialCoefficients(obj,val)
            coder.internal.errorIf(~(isnumeric(val) && isvector(val) && all(isfinite(val(:)))), ...
                'dsp:system:AdaptiveFilter:mustBeNumericVector', 'InitialCoefficients');
            obj.InitialCoefficients = val(:).';
        end
        
        % Validating InitialInverseCovariance
        function set.InitialInverseCovariance(obj,val)
            coder.internal.errorIf(~(isnumeric(val) && ismatrix(val) && ...
                (size(val,1)==size(val,2)) && all(isfinite(val(:)))), ...
                'dsp:system:AdaptiveFilter:mustBeNumericSquareMatrix', 'InitialInverseCovariance');
            obj.InitialInverseCovariance = val;
        end
        
        % Validating InitialSquareRootInverseCovariance
        function set.InitialSquareRootInverseCovariance(obj,val)
            coder.internal.errorIf(~(isnumeric(val) && ismatrix(val) && ...
                (size(val,1)==size(val,2)) && all(isfinite(val(:)))), ...
                'dsp:system:AdaptiveFilter:mustBeNumericSquareMatrix', 'InitialSquareRootInverseCovariance');
            obj.InitialSquareRootInverseCovariance = val;
        end
        
        % Validating InitialSquareRootCovariance
        function set.InitialSquareRootCovariance(obj,val)
            coder.internal.errorIf(~(isnumeric(val) && ismatrix(val) && ...
                (size(val,1)==size(val,2)) && all(isfinite(val(:)))), ...
                'dsp:system:AdaptiveFilter:mustBeNumericSquareMatrix', 'InitialSquareRootCovariance');
            obj.InitialSquareRootCovariance = val;
        end
    end
    
    methods (Static, Hidden)
        %RLSCoefficientUpdate This static method performs the conventional
        % RLS coefficient update for the given error signal, RLS states and
        % RLS parameters. The input argument 'discreteStates' must be a
        % structure and must contain the following fields: States,
        % Coefficients, InverseCovariance and KalmanGain. The input
        % argument 'params' must be a structure and must contain the
        % ForgettingFactor value and LockCoefficients logical value.
        function discreteStates = RLSCoefficientUpdate(error, discreteStates, params)
            % Local copy of the filter states and parameters
            X = discreteStates.States;
            P = discreteStates.InverseCovariance;
            lam = params.ForgettingFactor;
            
            % Compute Kalman gain vector
            XP = X'*P;
            invDen = 1/(lam + XP*X);
            K = invDen*(P*X);
            
            % InverseCovariance matrix update
            discreteStates.InverseCovariance = (1/lam)*(P - K*XP);
            
            % Save Kalman gain vector
            discreteStates.KalmanGain = K;
            
            % Update filter coefficient vector
            if ~params.LockCoefficients
                discreteStates.Coefficients = discreteStates.Coefficients + error * K';
            end
        end
        
        %SWRLSCoefficientUpdate This static method performs the
        % sliding-window RLS coefficient update for the given error signal,
        % RLS states and RLS parameters. The input argument
        % 'discreteStates' must be a structure and must contain the
        % following fields: States, Coefficients, InverseCovariance,
        % DesiredStates and KalmanGain. The input argument 'params' must be
        % a structure and must contain the ForgettingFactor value and
        % LockCoefficients logical value.
        function discreteStates = SWRLSCoefficientUpdate(error, discreteStates, params)
            % Local copy of the states
            P = discreteStates.InverseCovariance;
            W = discreteStates.Coefficients;
            D = discreteStates.DesiredStates;
            
            % Local copy of the filter parameters
            lam = params.ForgettingFactor;
            L = length(W);
            N = length(D);
            lamNm1 = lam^(1-N);
            
            % InverseCovariance matrix update
            XL = discreteStates.States(1:L);
            XP = XL'*P;
            PX = P*XL;
            invden = 1/(lam + XP*XL);
            K = invden*PX;              %  compute Kalman gain vector
            P = (1/lam)*(P - K*XP);     %  update covariance matrix
            
            % InverseCovariance matrix "down-date"
            XL = discreteStates.States(N:N+L-1);
            XP = XL'*P;
            PX = P*XL;
            invden = 1/(-lamNm1 + XP*XL);
            KN = invden*PX;             %  compute Kalman gain vector
            discreteStates.InverseCovariance = P - KN*XP;  %  "down-date" covariance matrix
            
            % Save Kalman gain vector
            discreteStates.KalmanGain = K;
            
            % Update filter coefficient vector
            if ~params.LockCoefficients
                W = W + error * K';         %  update filter coefficient vector
                E = D(N) - W*XL;            %  compute trailing error signal sample
                discreteStates.Coefficients = W + E*KN';   %  "down-date" filter coefficient vector
            end
        end
        
        %HRLSCoefficientUpdate This static method performs the
        % Householder RLS coefficient update for the given error signal,
        % RLS states and RLS parameters. The input argument
        % 'discreteStates' must be a structure and must contain the
        % following fields: States, Coefficients,
        % SquareRootInverseCovariance and KalmanGain. The input argument
        % 'params' must be a structure and must contain the
        % ForgettingFactor value and LockCoefficients logical value.
        function discreteStates = HRLSCoefficientUpdate(error, discreteStates, params)
            % Local copy of the filter states and parameters
            G = discreteStates.SquareRootInverseCovariance;
            lam = params.ForgettingFactor;
            
            % Square root covariance matrix update
            V = G*discreteStates.States;   %  compute whitened input signal vector
            U = G'*V;
            gam = lam + V'*V;
            zeta = 1/(gam + sqrt(lam*gam));
            K = 1/gam*U;                        %  compute Kalman gain vector
            discreteStates.SquareRootInverseCovariance = (1/sqrt(lam))*(G - zeta*V*U');
            
            % Save Kalman gain vector
            discreteStates.KalmanGain = K;
            
            % Update filter coefficient vector
            if ~params.LockCoefficients
                discreteStates.Coefficients = discreteStates.Coefficients + error * K';
            end
        end
        
        %HSWRLSCoefficientUpdate This static method performs the
        % Householder sliding-window RLS coefficient update for the given
        % error signal, RLS states and RLS parameters. The input argument
        % 'discreteStates' must be a structure and must contain the
        % following fields: States, Coefficients, DesiredStates,
        % SquareRootInverseCovariance and KalmanGain. The input argument
        % 'params' must be a structure and must contain the
        % ForgettingFactor value and LockCoefficients logical value.
        function discreteStates = HSWRLSCoefficientUpdate(error, discreteStates, params)
            % Local copy of the states
            G = discreteStates.SquareRootInverseCovariance;
            W = discreteStates.Coefficients;
            D = discreteStates.DesiredStates;
            
            % Local copy of the filter parameters
            lam = params.ForgettingFactor;
            L = length(W);
            N = length(D);
            lamNm1 = lam^(1-N);
            
            % Covariance matrix update
            XL = discreteStates.States(1:L);
            V = G*XL;
            U = G'*V;
            gam = lam + V'*V;
            zeta = 1/(gam + sqrt(lam*gam));
            K = 1/gam*U;                        %  compute Kalman gain vector
            G = (1/sqrt(lam))*(G - zeta*V*U');  %  update square root covariance matrix
            
            % Covariance matrix "down-date"
            XL = discreteStates.States(N:N+L-1);
            V = G*XL;
            U = G'*V;
            gam = lamNm1 - V'*V;
            zeta = 1/(gam + sqrt(lamNm1*gam));
            KN = -1/gam*U;          %  compute Kalman gain vector
            discreteStates.SquareRootInverseCovariance = G + zeta*V*U';  %  "down-date" square root covariance matrix
            
            % Save Kalman gain vector
            discreteStates.KalmanGain = K;
            
            % Update filter coefficient vector
            if ~params.LockCoefficients
                W = W + error * K';     %  update filter coefficient vector
                E = D(N) - W*XL;        %  compute trailing error signal sample
                discreteStates.Coefficients = W + E*KN';   %  "down-date" filter coefficient vector
            end
        end
        
        %QRDRLSCoefficientUpdate This static method performs the
        % QR-decomposition RLS coefficient update for the given error
        % signal, RLS states and RLS parameters. The input argument
        % 'discreteStates' must be a structure and must contain the
        % following fields: States, Coefficients, SquareRootCovariance and
        % ModifiedCrossCorrelation. The input argument 'params' must be a
        % structure and must contain the ForgettingFactor value and
        % LockCoefficients logical value.
        function discreteStates = QRDRLSCoefficientUpdate(error, discreteStates, params)
            % Local copy of the states
            W = discreteStates.Coefficients;
            R = discreteStates.SquareRootCovariance;
            P = discreteStates.ModifiedCrossCorrelation;
            
            % Local copy of the filter parameters
            slam = sqrt(params.ForgettingFactor);
            L = length(W);
            
            %  Update Cholesky factor and P vector via Givens rotations
            R = slam*R;             %  Multiply Cholesky factor by sqrt(lambda)
            P = slam*P;             %  Multiply P vector by sqrt(lambda)
            Xi = conj(discreteStates.States);        %  Initialize Xi vector
            E = conj(error);        %  Initialize error signal
            
            %  Main loop of weight update
            for i=1:L
                nniL = i:L;         %  Index used in weight update to avoid add'l FOR loop
                ri = real(R(i,i));
                xi = conj(Xi(i));
                invden = 1/sqrt(real(ri*conj(ri) + xi*conj(xi)));
                ci = ri*invden;     %  compute cos() for Givens rotation
                si = xi*invden;     %  compute sin() for Givens rotation
                Ri = R(i,nniL);     %  Select (i)th row of Cholesky factor
                pi = P(i);          %  Select (i)th element of P vector
                R(i,nniL) = ci*Ri + si*Xi(nniL).';  %  Givens rotations on Cholesky factor
                Xi(nniL)  = -conj(si)*Ri.' + ci*Xi(nniL);  %  Givens rotations on input vector
                P(i) = ci*pi + si*E;%  Givens rotation on (i)th element of P vector
                E = -conj(si)*pi + ci*E;  %  Givens rotations on error signal
            end
            
            % Save SquareRootCovariance matrix and ModifiedCrossCorrelation
            discreteStates.SquareRootCovariance = R;
            discreteStates.ModifiedCrossCorrelation = P;
            
            % Update filter coefficient vector
            if ~params.LockCoefficients
                %  Backsubstitution step for Coefficient calculation
                W(L) = conj(P(i)/R(i,i));  %  Calculate (L)th coefficient
                for i = L-1:-1:1
                    nnip1L = i+1:L;
                    W(i) = conj((P(i) - R(i,nnip1L)*W(nnip1L)')/R(i,i));  %  Calculate (i)th coeff
                end
                
                % Save Coefficients vector
                discreteStates.Coefficients = W;
            end
        end
    end
    
    methods (Access=protected)
        function validatePropertiesImpl(obj)
            L = obj.Length;
            methodLocal = obj.Method;
            
            % Validating InitialCoefficients
            coder.internal.errorIf(~(any(length(obj.InitialCoefficients)==[1,L])), ...
                'dsp:system:AdaptiveFilter:invalidVectorOfLengthL', 'InitialCoefficients');
            
            % Validating SlidingWindowBlockLength. It must be at least be
            % as large as Length of the filter.
            if (strcmp(methodLocal, 'Sliding-window RLS') || ...
                    strcmp(methodLocal, 'Householder sliding-window RLS'))
                coder.internal.errorIf(obj.SlidingWindowBlockLength < L, ...
                    'dsp:system:RLSFilter:invalidSlidingWindowBlockLength');
            end
            
            % Validating Initial Input Covariance for different methods
            switch methodLocal
                case {'Conventional RLS', 'Sliding-window RLS'}
                    tempSize = size(obj.InitialInverseCovariance);
                    coder.internal.errorIf(~(any(tempSize(1)==[1,L]) && tempSize(1)==tempSize(2)), ...
                        'dsp:system:AdaptiveFilter:invalidSquareMatrixOfDimensionL', 'InitialInverseCovariance');
                case {'Householder RLS', 'Householder sliding-window RLS'}
                    tempSize = size(obj.InitialSquareRootInverseCovariance);
                    coder.internal.errorIf(~(any(tempSize(1)==[1,L]) && tempSize(1)==tempSize(2)), ...
                        'dsp:system:AdaptiveFilter:invalidSquareMatrixOfDimensionL', 'InitialSquareRootInverseCovariance');
                case 'QR-decomposition RLS'
                    tempSize = size(obj.InitialSquareRootCovariance);
                    coder.internal.errorIf(~(any(tempSize(1)==[1,L]) && tempSize(1)==tempSize(2)), ...
                        'dsp:system:AdaptiveFilter:invalidSquareMatrixOfDimensionL', 'InitialSquareRootCovariance');
            end
        end
        
        function validateInputsImpl(~, x, d)
            % Validating the size of the inputs x and d. Inputs must be
            % vectors.
            coder.internal.errorIf(~isvector(x) || isempty(x), ...
                'MATLAB:system:inputMustBeVector','signal');
            
            coder.internal.errorIf(~isvector(d) || isempty(d), ...
                'MATLAB:system:inputMustBeVector','desired signal');
            
            % Inputs must be of same size
            coder.internal.errorIf(~all(size(x)==size(d)), ...
                'MATLAB:system:inputsNotSameSize');
            
            % Validating the data type of the inputs x and d. x and d must
            % both be single or double.
            coder.internal.errorIf(~(isa(x,'float') && strcmp(class(x), ...
                class(d))), 'dsp:system:AdaptiveFilter:inputsNotFloatingPoint');
        end
        
        function setupImpl(obj, x, d)
            % Setting InputDataType to be the data type of x and setting
            % the FilterParameters structure based on that.
            inputDataTypeLocal = class(x);
            obj.InputDataType = inputDataTypeLocal;
            obj.FilterParameters = getFilterParameterStruct(obj);
            
            % Local copy of the required properties
            L = obj.Length;
            methodLocal = obj.Method;
            realInputX = isreal(x);
            realInputD = isreal(d);
            realInitCoeffs = isreal(obj.InitialCoefficients);
            
            % Find complexity of initial input covariance and allocate
            % memory for input covariance
            ZLL = zeros(L,L,inputDataTypeLocal);
            switch methodLocal
                case {'Conventional RLS', 'Sliding-window RLS'}
                    realInitCov = isreal(obj.InitialInverseCovariance);
                    if realInputX && realInitCov
                        obj.InverseCovariance = ZLL;
                        obj.KalmanGain = zeros(L,1,inputDataTypeLocal);
                    else
                        obj.InverseCovariance = complex(ZLL);
                        obj.KalmanGain = complex(zeros(L,1,inputDataTypeLocal));
                    end
                case {'Householder RLS', 'Householder sliding-window RLS'}
                    realInitCov = isreal(obj.InitialSquareRootInverseCovariance);
                    if realInputX && realInitCov
                        obj.SquareRootInverseCovariance = ZLL;
                        obj.KalmanGain = zeros(L,1,inputDataTypeLocal);
                    else
                        obj.SquareRootInverseCovariance = complex(ZLL);
                        obj.KalmanGain = complex(zeros(L,1,inputDataTypeLocal));
                    end
                otherwise
                    realInitCov = isreal(obj.InitialSquareRootCovariance);
                    if realInputX && realInitCov
                        obj.SquareRootCovariance = ZLL;
                    else
                        obj.SquareRootCovariance = complex(ZLL);
                    end
                    if realInputX && realInitCov && realInitCoeffs
                        obj.ModifiedCrossCorrelation = zeros(L,1,inputDataTypeLocal);
                    else
                        obj.ModifiedCrossCorrelation = complex(zeros(L,1,inputDataTypeLocal));
                    end
            end
            
            % Allocate memory for States and DesiredStates
            if (strcmp(methodLocal, 'Sliding-window RLS') || ...
                    strcmp(methodLocal, 'Householder sliding-window RLS'))
                % Sliding window block length
                N = obj.SlidingWindowBlockLength;
                
                % Initializing States to zeros:
                if realInputX
                    obj.States = zeros(L+N,1,inputDataTypeLocal);
                else
                    obj.States = complex(zeros(L+N,1,inputDataTypeLocal));
                end
                
                % Initializing DesiredStates to zeros:
                if realInputD
                    obj.DesiredStates = zeros(N,1,inputDataTypeLocal);
                else
                    obj.DesiredStates = complex(zeros(N,1,inputDataTypeLocal));
                end
            else
                % Initializing States to zeros:
                if realInputX
                    obj.States = zeros(L,1,inputDataTypeLocal);
                else
                    obj.States = complex(zeros(L,1,inputDataTypeLocal));
                end
            end
            
            % Allocate memory for Coefficients:
            if realInputX && realInputD && realInitCoeffs && realInitCov
                obj.Coefficients = zeros(1,L,inputDataTypeLocal);
            else
                obj.Coefficients = complex(zeros(1,L,inputDataTypeLocal));
            end
        end
        
        function resetImpl(obj)
            % Local copy of the required properties
            L = obj.Length;
            methodLocal = obj.Method;
            inputDataTypeLocal = obj.InputDataType;
            
            % Initializing Coefficients to InitialCoefficients
            coeffsLocal = obj.Coefficients;
            coeffsLocal(:) = cast(obj.InitialCoefficients,inputDataTypeLocal);
            
            obj.Coefficients = dsp.private.copyMatrix(coeffsLocal,obj.Coefficients);
            
            % Initializing States and DesiredStates to zeros
            if (strcmp(methodLocal, 'Sliding-window RLS') || ...
                    strcmp(methodLocal, 'Householder sliding-window RLS'))
                % Initializing States to InitialStates
                N = obj.SlidingWindowBlockLength;
                if isreal(obj.States)
                    obj.States = zeros(L+N,1,inputDataTypeLocal);
                else
                    obj.States = complex(zeros(L+N,1,inputDataTypeLocal));
                end
                
                % Initializing DesiredStates to InitialDesiredStates
                if isreal(obj.DesiredStates)
                    obj.DesiredStates = zeros(N,1,inputDataTypeLocal);
                else
                    obj.DesiredStates = complex(zeros(N,1,inputDataTypeLocal));
                end
            else
                % Initializing States to InitialStates
                if isreal(obj.States)
                    obj.States = zeros(L,1,inputDataTypeLocal);
                else
                    obj.States = complex(zeros(L,1,inputDataTypeLocal));
                end
            end
            
            % Initialize input covariance
            switch methodLocal
                case {'Conventional RLS', 'Sliding-window RLS'}
                    % Initialize InverseCovariance to
                    % InitialInverseCovariance
                    invCovLocal = obj.InverseCovariance;
                    invCovLocal(:) = cast(obj.InitialInverseCovariance*eye(L),inputDataTypeLocal);
                    
                    obj.InverseCovariance = dsp.private.copyMatrix(invCovLocal,obj.InverseCovariance);
                    
                case {'Householder RLS', 'Householder sliding-window RLS'}
                    % Initialize SquareRootInverseCovariance to
                    % InitialSquareRootInverseCovariance
                    sqrtInvCovLocal = obj.SquareRootInverseCovariance;
                    sqrtInvCovLocal(:) = cast(obj.InitialSquareRootInverseCovariance*eye(L),inputDataTypeLocal);
                    
                    obj.SquareRootInverseCovariance = dsp.private.copyMatrix(sqrtInvCovLocal,obj.SquareRootInverseCovariance);
                    
                case 'QR-decomposition RLS'
                    % Initialize SquareRootCovariance to
                    % InitialSquareRootCovariance
                    sqrtCovLocal = obj.SquareRootCovariance;
                    sqrtCovLocal(:) = cast(obj.InitialSquareRootCovariance*eye(L),inputDataTypeLocal);
                    
                    obj.SquareRootCovariance = dsp.private.copyMatrix(sqrtCovLocal,obj.SquareRootCovariance);
            end
            
            % Initializing ModifiedCrossCorrelation to its initial value and KalmanGain to zeros
            if strcmp(methodLocal, 'QR-decomposition RLS')
                ModifiedCrossCorrelationLocal = obj.SquareRootCovariance * obj.Coefficients';
                obj.ModifiedCrossCorrelation = dsp.private.copyMatrix(ModifiedCrossCorrelationLocal,obj.ModifiedCrossCorrelation);
            else
                obj.KalmanGain = dsp.private.copyMatrix(zeros(L,1,inputDataTypeLocal),obj.KalmanGain);
            end
        end
        
        function processTunedPropertiesImpl(obj)
            % Whenever ForgettingFactor is changed, update the private
            % structure that stores the type casted version of it
            obj.FilterParameters.ForgettingFactor = ...
                cast(obj.ForgettingFactor,obj.InputDataType);
            obj.FilterParameters.LockCoefficients = obj.LockCoefficients;
        end
        
        function [y,e] = stepImpl(obj, x, d)
            % Load states, properties and initialize variables
            discreteStates = getDiscreteState(obj);
            params = obj.FilterParameters;
            L = obj.Length;
            [y,e,ntr] = initializeVariables(obj,size(x));
            
            % Main Loop
            switch obj.Method
                case 'Conventional RLS'
                    for n=1:ntr
                        %  filter the current input buffer
                        discreteStates.States = updateBuffer(obj,x(n),discreteStates.States);
                        y(n) = discreteStates.Coefficients*discreteStates.States;
                        %  compute and assign current error signal sample
                        e(n) = d(n) - y(n);
                        %  update filter coefficient vector
                        discreteStates = obj.RLSCoefficientUpdate(e(n),discreteStates,params);
                    end
                case 'Sliding-window RLS'
                    for n=1:ntr
                        %  filter the current input buffer
                        discreteStates.States = updateBuffer(obj,x(n),discreteStates.States);
                        discreteStates.DesiredStates = updateBuffer(obj,d(n),discreteStates.DesiredStates);
                        y(n) = discreteStates.Coefficients*discreteStates.States(1:L);
                        %  compute and assign current error signal sample
                        e(n) = d(n) - y(n);
                        %  update filter coefficient vector
                        discreteStates = obj.SWRLSCoefficientUpdate(e(n),discreteStates,params);
                    end
                case 'Householder RLS'
                    for n=1:ntr
                        %  filter the current input buffer
                        discreteStates.States = updateBuffer(obj,x(n),discreteStates.States);
                        y(n) = discreteStates.Coefficients*discreteStates.States;
                        %  compute and assign current error signal sample
                        e(n) = d(n) - y(n);
                        %  update filter coefficient vector
                        discreteStates = obj.HRLSCoefficientUpdate(e(n),discreteStates,params);
                    end
                case 'Householder sliding-window RLS'
                    for n=1:ntr
                        %  filter the current input buffer
                        discreteStates.States = updateBuffer(obj,x(n),discreteStates.States);
                        discreteStates.DesiredStates = updateBuffer(obj,d(n),discreteStates.DesiredStates);
                        y(n) = discreteStates.Coefficients*discreteStates.States(1:L);
                        %  compute and assign current error signal sample
                        e(n) = d(n) - y(n);
                        %  update filter coefficient vector
                        discreteStates = obj.HSWRLSCoefficientUpdate(e(n),discreteStates,params);
                    end
                case 'QR-decomposition RLS'
                    for n=1:ntr
                        %  filter the current input buffer
                        discreteStates.States = updateBuffer(obj,x(n),discreteStates.States);
                        y(n) = discreteStates.Coefficients*discreteStates.States;
                        %  compute and assign current error signal sample
                        e(n) = d(n) - y(n);
                        %  update filter coefficient vector
                        discreteStates = obj.QRDRLSCoefficientUpdate(d(n),discreteStates,params);
                    end
            end
            
            % Save states
            setDiscreteState(obj,discreteStates);
        end
        
        function N = getNumInputsImpl(~)
            % Specify number of System inputs
            N = 2;
        end
        
        function N = getNumOutputsImpl(~)
            % Specify number of System outputs
            N = 2;
        end
        
        %getFilterParameterStruct This method that gives the filter
        % parameters structure with the values casted to the InputDataType
        % property value.
        function filterParams = getFilterParameterStruct(obj)
            filterParams = struct('ForgettingFactor', ...
                cast(obj.ForgettingFactor,obj.InputDataType), ...
                'LockCoefficients', obj.LockCoefficients);
        end
        
        %initializeVariables This method is used to initialized output
        % variables and temporary variables required in the main loop of
        % the stepImpl method.
        function [y,e,ntr] = initializeVariables(obj,Sx)
            ntr = max(Sx);                      %  temporary number of iterations
            if isreal(obj.Coefficients)         %  initialize output signal vector
                y = zeros(Sx,obj.InputDataType);
            else
                y = complex(zeros(Sx,obj.InputDataType));
            end
            e = y;                      %  initialize error signal vector
        end
        
        %updateBuffer This method is used to update the input buffer with
        % the current input sample by shifting the buffer down.
        function buffer = updateBuffer(~, currentInput, buffer)
            % Function to assign the current input by shifting the buffer down
            buffer(:) = [currentInput(:); buffer(1:end-length(currentInput))];
        end
        
        %isInactivePropertyImpl This overloaded method is used to flag some
        % of the irrelevant properties based on the Method property value
        % as inactive.
        function flag = isInactivePropertyImpl(obj, prop)
            flag = false;
            methodLocal = obj.Method;
            switch prop
                case {'SlidingWindowBlockLength'}
                    if ~(strcmp(methodLocal, 'Sliding-window RLS') || ...
                            strcmp(methodLocal, 'Householder sliding-window RLS'))
                        flag = true;
                    end
                case {'InitialInverseCovariance'}
                    if ~(strcmp(methodLocal, 'Conventional RLS') || ...
                            strcmp(methodLocal, 'Sliding-window RLS'))
                        flag = true;
                    end
                case {'InitialSquareRootInverseCovariance'}
                    if ~(strcmp(methodLocal, 'Householder RLS') || ...
                            strcmp(methodLocal, 'Householder sliding-window RLS'))
                        flag = true;
                    end
                case {'InitialSquareRootCovariance'}
                    if ~strcmp(methodLocal, 'QR-decomposition RLS')
                        flag = true;
                    end
            end
        end
        
        %setDiscreteStateImpl This overloaded method is used to set the
        % DiscreteState properties of the object equal to the corresponding
        % fields of the structure passed as input argument.
        function setDiscreteStateImpl(obj, discreteStates)
            obj.States = dsp.private.copyMatrix(discreteStates.States,obj.States);
            obj.Coefficients = dsp.private.copyMatrix(discreteStates.Coefficients,obj.Coefficients);
            switch obj.Method
                case 'Conventional RLS'
                    obj.InverseCovariance = dsp.private.copyMatrix(discreteStates.InverseCovariance,obj.InverseCovariance);
                    obj.KalmanGain = dsp.private.copyMatrix(discreteStates.KalmanGain,obj.KalmanGain);                    
                case 'Sliding-window RLS'
                    obj.InverseCovariance = dsp.private.copyMatrix(discreteStates.InverseCovariance,obj.InverseCovariance);
                    obj.KalmanGain = dsp.private.copyMatrix(discreteStates.KalmanGain,obj.KalmanGain);                    
                    obj.DesiredStates = dsp.private.copyMatrix(discreteStates.DesiredStates,obj.DesiredStates);                                        
                case 'Householder RLS'
                    obj.SquareRootInverseCovariance = dsp.private.copyMatrix(discreteStates.SquareRootInverseCovariance,obj.SquareRootInverseCovariance);
                    obj.KalmanGain = dsp.private.copyMatrix(discreteStates.KalmanGain,obj.KalmanGain);                    
                case 'Householder sliding-window RLS'
                    obj.SquareRootInverseCovariance = dsp.private.copyMatrix(discreteStates.SquareRootInverseCovariance,obj.SquareRootInverseCovariance);
                    obj.KalmanGain = dsp.private.copyMatrix(discreteStates.KalmanGain,obj.KalmanGain);                    
                    obj.DesiredStates = dsp.private.copyMatrix(discreteStates.DesiredStates,obj.DesiredStates);                                                            
                case 'QR-decomposition RLS'
                    obj.SquareRootCovariance = dsp.private.copyMatrix(discreteStates.SquareRootCovariance,obj.SquareRootCovariance);
                    obj.ModifiedCrossCorrelation = dsp.private.copyMatrix(discreteStates.ModifiedCrossCorrelation,obj.ModifiedCrossCorrelation);                   
            end
        end
        
        %getDiscreteStateImpl This overloaded method is used to get all the
        % active DiscreteState properties of the object as a structure.
        function discreteStates = getDiscreteStateImpl(obj)
            switch obj.Method
                case 'Conventional RLS'
                    discreteStates = struct('States', obj.States, ...
                        'Coefficients', obj.Coefficients, ...
                        'InverseCovariance', obj.InverseCovariance, ...
                        'KalmanGain',obj.KalmanGain);
                case 'Sliding-window RLS'
                    discreteStates = struct('States', obj.States, ...
                        'Coefficients', obj.Coefficients, ...
                        'DesiredStates', obj.DesiredStates, ...
                        'InverseCovariance', obj.InverseCovariance, ...
                        'KalmanGain',obj.KalmanGain);
                case 'Householder RLS'
                    discreteStates = struct('States', obj.States, ...
                        'Coefficients', obj.Coefficients, ...
                        'SquareRootInverseCovariance', obj.SquareRootInverseCovariance, ...
                        'KalmanGain',obj.KalmanGain);
                case 'Householder sliding-window RLS'
                    discreteStates = struct('States', obj.States, ...
                        'Coefficients', obj.Coefficients, ...
                        'DesiredStates', obj.DesiredStates, ...
                        'SquareRootInverseCovariance', obj.SquareRootInverseCovariance, ...
                        'KalmanGain',obj.KalmanGain);
                otherwise
                    discreteStates = struct('States', obj.States, ...
                        'Coefficients', obj.Coefficients, ...
                        'SquareRootCovariance', obj.SquareRootCovariance, ...
                        'ModifiedCrossCorrelation',obj.ModifiedCrossCorrelation);
            end
        end
        
        %saveObjectImpl This overloaded method is used to save all the
        % active properties of the object, including the required private
        % and protected ones, when the object is saved.
        function s = saveObjectImpl(obj)
            s = saveObjectImpl@matlab.System(obj);
            if isLocked(obj)
                s.InputDataType = obj.InputDataType;
            end
        end
        
        %loadObjectImpl This overloaded method is used to load all the
        % active properties of the object, including the private and
        % protected ones, when the object is loaded.
        function loadObjectImpl(obj, s, wasLocked)
            loadObjectImpl@matlab.System(obj, s, wasLocked);
            if wasLocked
                obj.InputDataType = s.InputDataType;
                obj.FilterParameters = getFilterParameterStruct(obj);
            end
        end
    end
end
