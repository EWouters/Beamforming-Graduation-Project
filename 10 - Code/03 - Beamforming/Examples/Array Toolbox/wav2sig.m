function [sig,fs] = wav2sig(fnames, varargin)
% This function reads in wave files and stores all the information into a 
% single matrix with equal number of rows, with each column representing
% the different wave files.  
% 
%   sig = wav2sig(fnames)
%   sig = wav2sig(fnames,fs)
%   sig = wav2sig(fnames,tInt)
%   sig = wav2sig(fnames,fs,tInt)
%
%   Inputs:
%   1) fnames - name of the wave files in a cell array. 
%      Format:
%       a) for 1 file: {'filename1.wav'} 
%       b) multiple files: {'filename1.wav';'filename2.wav'}
%       NOTE: 
%        Each wave file should only have one channel.  If more than one 
%        channels are present, only the first channel will be used.
%   2) varargin (optional):
%       a) fs - resample the wave file to this frequency
%       b) tInt - 1x2 vector to specify time interval (in seconds) to 
%          trim down to
%
%   Output:
%   sig - matrix with the following properties:
%       a) Number of rows is determined by the number of rows in the
%          longest wave file
%          i) shorter wave files will be padded with 0's
%       b) Number of columns is determined by the number of input wave 
%          files
%
%   Written by Satoru Tagawa (staga2@uky.edu) 6/12/08


% Parameter check ********************************************************
% The function must have at least 1 parameter, and at most 3 parameters
if nargin == 0
    error('wavToSigMat must have at least 1 parameter');
end
if nargin > 3
    error('There can only be a maximum of 3 parameters');
end

% If more than one parameter, check to see what the parameters are
if nargin > 1
    [numR1,numC1] = size(varargin{1});
    if numR1 ~= 1  % Argument cannot have more than 1 row
            error('2nd parameter must have the dimension 1x1 or 1x2');
    end

    if length(varargin) == 1    % 2 parameters
        if numC1 == 1
            fs = varargin{1};
        elseif numC1 == 2
            tInt = varargin{1};
        else
            error('2nd parameter must have the dimension 1x1 or 1x2');
        end
    else                        % 3 parameters
        if numC1 == 1
            fs = varargin{1};
        else
            error('fs must have the dimension 1x1');
        end
        
        [numR2,numC2] = size(varargin{2});
        if numR2 ~= 1
            error('tInt must have the dimension 1x1 or 1x2');
        end
        
        if numC2 == 2
            tInt = varargin{2};                 
        else
            error('tInt must have the dimension 1x2');
        end
    end
end
%*************************************************************************


% Read in each wave files and place in cell array "y"
for fno=1:length(fnames)
    % Read the wave file, determine its sample frequency
    [y{fno},nfs(fno)]=wavread(fnames{fno});
    
    % If more than one channel present, eliminate all but the first channel
    [nR,nChanOrig] = size(y{fno});
    if nChanOrig ~= 1
        y{fno} = y{fno}(:,1);
    end
end

% If fs is not given, down sample to the signal with the lowest fs
if nargin == 1 || nargin == 2 && numC1 == 2
    fs = min(nfs);
end    

% Resample the wave files
for fno=1:length(fnames)   
    yf{fno} = resample(y{fno},fs,nfs(fno));
    
    % Find length of the resampled signal
    siglen(fno) = length(yf{fno});
end

maxSigLen = max(siglen);
% Conform the number of rows to that of the longest signal
for fno=1:length(fnames)
    if siglen(fno) == maxSigLen
        sig(:,fno) = yf{fno};
    elseif siglen(fno) < maxSigLen
        sig(:,fno) = [yf{fno}; zeros(maxSigLen-siglen(fno),1)];
    else
        error(['You can''t have a longer signal than the longest', ...
            'signal...']);
    end
end

% if tInt is passed in, trim down or zero pad 'sig'
if nargin==3 || nargin==2 && numC1 == 2
    if tInt(1) > tInt(2)
        error('2nd column in tInt must be greater than the 1st column');
    elseif tInt(1) < 0 || tInt(2) < 0
        error('tInt cannot contain negative values');
    end
    
    begin_index = fs*tInt(1)+1;
    end_index = fs*tInt(2);
    
    % Warning if begin_index is greater than signal length
    if begin_index > length(sig)
        warning('Did you mean to create a silent signal?');
    end
    
    % zero pad if end_index is greater than the signal length
    if end_index > length(sig)
        sig = [sig; zeros(end_index-length(sig),length(fnames))];
    end
    
    sig = sig(begin_index:end_index,:);
end

% Write out to a wav file
% For debugging purpose
% wavwrite(sig,fs,'out.wav');