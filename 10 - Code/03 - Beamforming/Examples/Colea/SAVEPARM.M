function saveparm(type)


global saveFmnts

if strcmp(type,'formnts') % Save formant values

 saveFmnts=1;
 ftrack('save');

end
