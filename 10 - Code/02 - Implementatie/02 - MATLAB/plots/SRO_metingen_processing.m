% Meetresultaten SRO
% Neemt aan dat de data in een Mx3 matrix 'result' staat
FS = 48e3;
BLOCKLENGTH = FS*30; % 1 minuut
NUMBLOCKS = 3600/(BLOCKLENGTH/FS);
NUMMICS = size(result,2);
max_index_matrix = zeros(NUMBLOCKS,2);
total_result = cell(1,NUMMICS);
freq_resolutie = FS/BLOCKLENGTH
for j=1:NUMMICS
    for i=1:NUMBLOCKS
        slice = result((i-1)*BLOCKLENGTH+1:i*BLOCKLENGTH,j);
        slice_fd = abs(fft(slice));
        real_slice_fd = slice_fd(1:floor(BLOCKLENGTH/2));
        [mx, index] = max(real_slice_fd);
        index=index*FS/BLOCKLENGTH;
        max_index_matrix(i,:) = [mx, index];
    end
    total_result{j} = max_index_matrix;
end