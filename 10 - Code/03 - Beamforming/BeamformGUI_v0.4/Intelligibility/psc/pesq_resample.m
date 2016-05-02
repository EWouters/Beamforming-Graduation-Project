function pval = pesq_resample(clean, enhanced, fs)
    % Funtion to resample intelligibility signals for pesq algortihm
%     clean_rs = resample(clean,16000,fs);
    clean_rs = clean;
    
    
    enhanced_rs = resample(enhanced,16000,fs);

    pval = pesq(clean_rs, enhanced_rs, 16000);
end