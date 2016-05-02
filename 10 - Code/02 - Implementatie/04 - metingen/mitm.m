classdef mitm < handle    
    properties (SetAccess = private)
        sitm;
        sample_rate;
        port;
        is_running=false;
        block_size;
        samples=cell(0); % first row of cells contain the names, second contain the samples
        stream_stereo;
        MainObj;
        orientation=cell(0);
        pulse=generatePulse();
        min_cntr;
    end
    
    properties (SetAccess = public)
        audio_source=uint8(6); % 6 = voice recognition
        RECLENGTH=60; % recording length in minutes
    end
    
    
    methods
        %% constructor
        function obj = mitm(port, sample_rate, block_size, stream_stereo, mainObj)
            if nargin>1
                obj.port = port;
                obj.sample_rate = sample_rate;
            end
            if nargin > 2
                obj.block_size = block_size;
            end
            if nargin > 3
                obj.stream_stereo = stream_stereo;
            end
            if nargin > 4
                obj.MainObj = mainObj; % bf_data is obj.MainObj.DataBuffer
            else
                obj.MainObj.DataBuffer = bf_data;
                % hier vars die geladen worden uit main obj toevoegen voor
                % gebruik zonder main_window
            end
        end
        
        % start the server containing the sockets
        function startSITM(obj)
            obj.sitm = SITM(obj.port, obj.sample_rate, obj.block_size, obj.stream_stereo);
            obj.toggleRunning();
            % set handle for Java callbacks
            sitm_handle = handle(obj.sitm, 'CallbackProperties');
            % set callbacks to corresponding java function
            sitm_handle.get
            set(sitm_handle, 'NewConnectionCallback', @obj.MNewConnection);
            set(sitm_handle, 'ConnectionLostCallback', @obj.MConnectionLost);
            set(sitm_handle, 'NewSamplesCallback', @(h,event)obj.MNewSamples(h,event));
            set(sitm_handle, 'OrientationUpdateCallback', @obj.MOrientationUpdate);
        end
        
        %% start / stop commands
        function success = startStreaming(obj, phoneID)
            if (obj.is_running)
                success = obj.sitm.startStreaming(phoneID, obj.audio_source);
                index=0;
                if success
                    for i=1:size(obj.samples,2)
                        if strcmp(obj.samples{1,i},phoneID)
                            index = i;
                            break
                        end
                    end
                    if index~=0
                        % remove the old samples left in buffer
                        obj.samples(:,index)=[];
                    end
                    obj.samples{1,end+1}=phoneID;
                    obj.samples{2,end}=[];
                end
                
            else
                disp('Server not running');
            end
        end
        
        function success = startAllStreaming(obj)
            if (obj.is_running)
                phones = obj.getPhoneIDs();
                if isempty(phones)
                    warning('no phones connected!');
                end
                for i=1:length(phones)
                    success = obj.startStreaming(phones{i})
                    if ~success
                        disp(['Failed to start' phones{i}]);
                    end
                end
            else
                disp('Server not running');
            end
        end
        
        function success = stopStreaming(obj,phoneID)
            if (obj.is_running)
                success = obj.sitm.stopStreaming(phoneID);
            else
                disp('Server not running');
            end
        end
        
        function success = stopAllStreaming(obj)
            if (obj.is_running)
                connectedPhones = obj.getPhoneIDs();
                for i=1:length(connectedPhones)
                    discon_success = obj.stopStreaming(connectedPhones{i});
                    if ~discon_success
                        disp([connectedPhones{i} 'not disconnected successfully']);
                    end
                end
            else
                disp('Server not running');
            end
        end
        
        function list = getPhoneIDs(obj)
            list = cell(0);
            if (obj.is_running)
                id = obj.sitm.getPhoneIDs();
                for i=1:length(id)
                    list{i} = char(id(i));
                end
            else
                disp('Server not running');
            end
        end
        
        function list = getStreamingIDs(obj)
            list = cell(0);
            if (obj.is_running)
                id = obj.sitm.getStreamingIDs();
                for i=1:length(id)
                    list{i} = char(id(i));
                end
            else
                disp('Server not running');
            end
        end    
        
        function [azimuth elevation phoneID] = getOrientation(obj)
            azimuth=zeros(size(obj.orientation,2),1);
            elevation=zeros(size(obj.orientation,2),1);
            phoneID = cell(size(obj.orientation,2),1);
            for i=1:size(obj.orientation,2)
                azimuth(i)   = obj.orientation{2,i}(end,1);
                elevation(i) = obj.orientation{2,i}(end,2);
                phoneID{i}   = char(obj.orientation{1,i});
            end
        end
                
        function delays = synchronize(obj, play_flag)
            % als play_flag == 1 dan zélf audio afspelen!
            if isempty(obj.getPhoneIDs)
                warning('Error: no connected phones!');
                delays = [];
                return
            end
            if play_flag
                obj.clearSamples(1); % 1 indicates the names should be kept!
                mls_player = audioplayer(obj.pulse,obj.sample_rate);
                playblocking(mls_player);
            end
            % vind de start van elk signaal
            [offsetsTD, ~] = processSignals(obj.pulse, double(obj.MainObj.DataBuffer.getAudioData));            
            % corrigeer voor eventueel negatieve offsets
            offsetsTD = offsetsTD-min(offsetsTD)+1;
            delays = offsetsTD
        end
        
        %% "advanced" functions
        % stop the server
        function stop(obj)
            if (obj.is_running)
                obj.stopAllStreaming();
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
        
        % functions assigned to java callback in matlab
        function MNewConnection(obj, h, NewCon)
            phoneID = char(NewCon.phoneID); % convert java string to matlab string (= array of char)
            disp(['New connection from ' phoneID]);
            % add to bf_data 
            obj.MainObj.DataBuffer.setChanNames(phoneID, 1);
            % add to orientation cell
            obj.orientation{1,end+1}=phoneID;
            obj.orientation{2,end}=[];
            obj.min_cntr(end+1)=1;
        end
        
        function MConnectionLost(obj, h, ConLost)
            phoneID = char(ConLost.phoneID);
            disp(['Connection lost:' phoneID]);
            % optional: remove from outputfile
        end
        
        function MNewSamples(obj, h, NewSamples)
            %iets met ADDSAMPLES(OBJ, Y, CHANNAMES) (y=kolomvector)
            phoneID = char(NewSamples.phoneID);
            new_samples = double(NewSamples.samples)/2^15;
            % input sanitation
            if ~iscolumn(new_samples)
                new_samples = new_samples';
            end
            if min(size(new_samples))>1
                error('Data is not a vector! Possibly stereo streaming enabled?');
            end
            if ~isempty(obj.samples)
                for i=1:size(obj.samples,2)
                    if strcmp(phoneID,obj.samples{1,i})
                        obj.samples{2,i}=[obj.samples{2,i}; new_samples];
                        % opslaan als .wav als er een minuut is opgenomen
                        first_sample = 1+obj.min_cntr(i)*obj.RECLENGTH*obj.sample_rate;
                        last_sample = first_sample + obj.RECLENGTH*obj.sample_rate;
                        if length(obj.samples{2,i})>=last_sample
                            audiowrite(['phone' num2str(i) 'recording' num2str(obj.min_cntr(i)) '.wav'], obj.samples{2,i}(first_sample:last_sample), obj.sample_rate)
                            obj.min_cntr(i)=obj.min_cntr(i)+1;
                        end
                    end
                end
            else
                obj.samples{1,1}=phoneID;
                obj.samples{2,1}=new_samples;
            end
        end
        
        function MOrientationUpdate(obj, h, ElevationObj)
        end
        
        function clearSamples(obj, keep_names)
            if keep_names && ~isempty(obj.samples)
                for i=1:size(obj.samples,2)
                    obj.samples{2,i}=[];
                end
            else
                obj.samples=cell(0);
            end
        end
        
        function clearOrientation(obj)
            obj.orientation=cell(0);
        end
        
    end
    
    %% do not touch functions
    methods (Access = private)
        function delete(obj)
            if (obj.is_running)
                obj.sitm.close();
                obj.sitm=[];
                obj.toggleRunning;
            else
                obj.sitm=[];
                obj.is_running=false;
            end
        end
    end
end