classdef mitm < handle
    properties (SetAccess = private)
        sitm;
        phoneIDs;
        sample_rate
        port
        is_running=false;
        BFCom
    end
    
    methods
        % constructor
        function obj = mitm(bfcom_object)
            if nargin > 2
                obj.BFCom = bfcom_object;
            end
        end
        
        % start the server containing the sockets
        function startSITM(obj)
            javaaddpath('java_socket'); %add .class files to java path
%             javaaddpath('C:\Program Files\MATLAB\R2014b\java\jar\matlabcontrol.jar'); %add matlabcontrol to java path
            javaaddpath('java_socket/matlabcontrol.jar');
            addpath('helper_functions'); %add helper .m files to matlab path
            obj.sitm = matlab_sitm(obj.port);
            obj.toggleRunning();
        end
        
        %% functions as specified in communicatie.txt
        % tell every phone to start recording at the specified sampling
        % rate
        function startListening(obj,sample_rate)
            if (obj.is_running)
                disp('function not implemented yet');
            else
                disp('Server not running');
            end
        end
        
        function startStreaming(obj, AudioSource, phoneID)
            if (obj.is_running)
                disp('function not implemented yet');
            else
                disp('Server not running');
            end
        end
        
        function stopStreaming(obj,phoneID)
            if (obj.is_running)
                disp('function not implemented yet');
            else
                disp('Server not running');
            end
        end
        
        function phoneIDs = getPhoneIDs(obj)
            if (obj.is_running)
                phoneIDs = obj.phoneIDs;
            else
                disp('Server not running');
                phoneIDs = [];
            end
        end
        
        
        %% "advanced" functions
        % stop the server
        function stop(obj)
            if (obj.is_running)
                obj.sitm.close();
                obj.sitm=[];
                obj.toggleRunning;
            else
                disp('Server not running');
            end
        end
        
        function toggleRunning(obj)
            obj.is_running = ~obj.is_running;
        end
    end
end