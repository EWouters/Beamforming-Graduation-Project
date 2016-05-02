function helpf(type)
 
if strcmp(type,'colea'),
    ttlStr = 'Colea'; 

    hlpStr1= ...                                              
        ['                                                '
         '                  Push Buttons                  '
	 ' * Zoom In                                      '
	 '  This is used for zooming in the waveform. To  '
	 '  do that, click with the left mouse button the '
	 '  beginning of the region, and then click with  '
	 '  the right mouse button the end of the region. '
	 '                                                '
	 ' * Zoom out                                     '
	 '   This is used for zooming out to the original '
	 '   display.                                     '
	 '                                                '
	 ' * Play                                         '
	 '   All - plays the waveform within the window.  '
	 '   Sel - plays the region selected with the left'
	 '         and mouse buttons, i.e., between the 2 '
	 '         vertical lines.                        '
         '                                                '];

     

     helpwin(hlpStr1,ttlStr);

elseif strcmp(type,'filtool')

	titles='Filter Tool';
	hlp1 = ...
	  [' Type in the desired cut-off frequency         '
	   ' and then hit the enter key. If you want to    '
	   ' see the filter, then hit the "View filter"    '
	   ' button.                                       '];

	helpwin(hlp1,titles);

elseif strcmp(type,'voltool')

	titles='Volume Tool';
	hlp1 = ...
          [' Move the slider bar to adjust the volume.     '
	   ' There are three different modes:              '
	   '                                               '	
	   ' ** Autoscale (default)                        '
	   ' The signal is automatically scaled to the     '
	   ' maximum value allowed by the hardware. In this'
	   ' mode, you can not use the slider bar.         '
	   '                                               '
	   ' ** No scale                                   '
	   ' In this mode the signal can be made louder or '
	   ' softer by moving the slider bar.              '
	   '                                               '
	   ' ** Absolute                                   '
	   ' In this mode, the signal is played as is. No  '
	   ' scaling is done. Moving the slider bar has no '
	   ' effect.                                       '
	   '                                               '];

        helpwin(hlp1,titles);
        
 elseif strcmp(type,'fileutil')

	titles='File utility';
	hlp1 = ...
     [' This utility can be used for downsampling or   '
      ' upsampling the speech signal by factors of 2-4 ' 
      ' 	                                              '
      ' To downsample or upsample the speech signal    '
      ' first select the factor from the pull-down     '
      ' menu  and then press the Apply button.         '
      '                                                '
      ' To do byte swapping, juck check the box, and   '
      ' press the Apply button.                        '];   
   
        helpwin(hlp1,titles);
        
elseif strcmp(type,'rectool')

	titles='Recording Tool';
	hlp1 = ...
     [' To start recording, click on the Record button '
      ' and start speaking to the microphone.          ' 
      ' 	                                              '
      ' You may set the sampling frequency, the        '
      ' duration of the recorded segment (in secs), the'
      ' number of bits used in A/D, and the filename   '
      ' of the recorded speech. The recorded file will '
      ' be saved in Microsoft  .wav format.            '
      ' 	                                              '];  
   
        helpwin(hlp1,titles);

 end

