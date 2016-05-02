classdef MeasurementApp < handle
    properties (SetAccess = private)
        sitm;
        sample_rate;
        port;
        is_running=false;
        BFCom;
        block_size;
        samples=cell(0); % first row of cells contain the names, second contain the samples
        stream_stereo;
    end
    
    properties (SetAccess = public)
        audio_source=uint8(6); % 6 = voice recognition, 5 = camcorder, 1 = mic, 0 = default
    end
    
    
    methods
        % constructor
        function obj = MeasurementApp(port, sample_rate, block_size, stream_stereo, bfcom_object)
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
                obj.BFCom = bfcom_object;
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
        
        %% functions as specified in communicatie.txt
        % tell every phone to start recording at the specified sampling
        % rate
        
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
                        obj.samples
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
                success = true;
                connectedPhones = obj.getPhoneIDs();
                for i=1:length(connectedPhones)
                    discon_success = obj.stopStreaming(connectedPhones{i});
                    if ~discon_success
                        warning([connectedPhones{i} 'not disconnected successfully']);
                        success = false;
                    end
                end
            else
                disp('Server not running');
                success = false;
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
        
        
        % return the current position in the cell-array
        function pos = getBufferPosition(obj)
            disp('niet geimplementeerd');
            pos = 0;
        end
        
        % return number of samples available in cell-array (AKA the minumum
        % number available in all cells)
        function number = getBufferAvailable(obj)
            number = length(obj.samples{2,1});
            for i=2:size(obj.samples,2)
                if length(obj.samples{2,i})<number
                    number = length(obj.samples{2,i});
                end
            end
        end
        
        % return 'len' new samples if possible in the order that the
        % startStreaming command was sent (the order of obj.samples) then
        % remove the read samples from obj.samples
        function samples_array = readSamples(obj, len)
            if len > obj.getBufferAvailable()
                error('Error using readSamples: more samples requested than could be returned!');
            else
                % init size of samples_array
                samples_array = zeros(len,size(obj.samples,2));
                for i=1:size(obj.samples,2)
                    % assign samples_array
                    samples_array(:,i)=obj.samples{2,i}(1:len);
                    % remove from samples buffer
                    obj.samples{2,i} = obj.samples{2,i}(len+1:end);
                end
            end
        end
        
        
        function synchronize(obj)
            if isempty(obj.getPhoneIDs)
                error('Error: no connected phones!');
            end
            
            % stappenplan:
            % Maak MLS signaal
            mls_sig = generatePulse();
            mls_player = audioplayer(mls_sig,obj.sample_rate);
            % gooi buffer leeg
            if ~isempty(obj.samples)
                for i=1:size(obj.samples,2)
                    obj.samples{2,i}=[];
                end
            end
            % speel MLS (blocking)
            playblocking(mls_player);
            % vind de start van elk signaal
            [offsetsTD, offsetsTD_self] = processSignalsTD(mls_sig, obj.samples);
            offsetsFD = processSignalsFD(mls_sig, obj.samples);
            % hier kan mogelijk een algoritme komen om te testen of offset
            % danwel offsets_self gebruikt moet worden
            % corrigeer voor eventueel negatieve offsets
            offsetsTD = offsetsTD-min(offsetsTD)+1
            offsetsFD = offsetsFD-min(offsetsFD)+1
            % verwijder van alle data tot nu toe 1:offset(i)
            for i=1:size(obj.samples,2)
                % note: the round function..
                obj.samples{2,i}=obj.samples{2,i}(round(offsetsFD(i)):end);
            end
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
        end
        
        function MConnectionLost(obj, h, ConLost)
            phoneID = char(ConLost.phoneID);
            disp(['Connection lost:' phoneID]);
        end
        
        function MNewSamples(obj, h, NewSamples)
            phoneID = char(NewSamples.phoneID);
            index = 0;
            for i=1:size(obj.samples,2)
                if strcmp(obj.samples{1,i},phoneID)
                    index = i;
                    break
                end
            end
            if (index==0)
                disp('unable to locate the phone ID in the stored samples cell!');
            else
                obj.samples{2,index}=[obj.samples{2,index}; double(NewSamples.samples)];
                % #TODO dit optimaliseren??
            end
        end
        
        function MOrientationUpdate(obj, h, ElevationObj)
            id = char(ElevationObj.phoneID);
            azimuth = ElevationObj.azimuth;
            elevation = ElevationObj.elevation;
            disp(['phoneid: ' id]);
            disp(['az: ' num2str(azimuth) ]);
            disp(['el: ' num2str(elevation)]);
        end
        
        function clearSamples(obj)
            obj.samples=cell(0);
        end
        
        function success = startRecording(obj)
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
        
        function recorded_data = stopRecording(obj)
            if (obj.is_running)
                success = obj.stopAllStreaming();
                if (success)
                    disp('All phones have been sent the stop recording signal');
                    recorded_data = reshape(obj.samples{2,1},2,length(obj.samples{2,1})/2)'/2^15;
                else
                    disp('Something went wrong during stopping phones');
                end
            else
                disp('Server not running');
            end
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