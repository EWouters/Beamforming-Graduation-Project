% knipscript
% beginpunt ingeven
% eindpunt ingeven
% de vector die geknipt moet worden meegeven

function [geknipt] = knipscript_MLS(beginpunt,eindpunt,knip)
grens=0.01;
knip=knip';
geknipt=zeros([45 1.8e5]);

knip=knip(beginpunt:eindpunt);

h = waitbar(0,'MLS - Het knippen is begonnen! 0 graden');

for i=(1:360/8);
    
    eindpunt=0;
    
    isnul=0;
        isnietnul=0;
    
    for j=(1:length(knip))
            if(abs(knip(j))<grens)
                isnul=isnul+1;
            else
                isnietnul=isnietnul+1;
                isnul=0;
            end

            if(isnul>400 && isnietnul>1e4)
                eindpunt=j+2000;
                break;
            end
    end
    
    zondernul=knip(1:eindpunt);
    nietnul_voor=min(find((abs(zondernul)>grens),1,'first'));
    nietnul_na=min(find((abs(zondernul)>grens),1,'last'))+2000;
    zondernul=zondernul(nietnul_voor:nietnul_na);
    
    geknipt(i,:)=[zondernul zeros([1 length(geknipt)-length(zondernul)])];
    knip=knip(eindpunt+1e5:end);
    waitbar(i*8/360,h,sprintf('MLS - Knippen op %i van de 360 graden',i*8))
end

delete(h)
h = msgbox('MLS - Klaargeknipt');

end