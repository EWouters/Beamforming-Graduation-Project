      r = audiorecorder(48e3, 16, 1);
      record(r);     % speak into microphone...
      %gain=1;
      play_sequence=GenerateTSPSequence(10,15,0,'circ');
      play_sequence=play_sequence*gain;
    
    audio_play=audioplayer(play_sequence,Fs);
    % speel het TSP-signaal
    playblocking(audio_play);
      stop(r);
      p=getaudiodata(r);
      plot(p);
      
      
      %pause(r);
      p = play(r);   % listen
      resume(r);     % speak again
      stop(r);
      p = play(r);   % listen to complete recording
      mySpeech = getaudiodata(r, 'int16'); % get data as int16 array