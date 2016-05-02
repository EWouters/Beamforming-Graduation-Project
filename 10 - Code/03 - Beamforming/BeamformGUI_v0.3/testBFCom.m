obj=bfcom

obj.newConnection('ID1',1,2)
obj.newConnection('ID2',1,1)
obj.newConnection('ID3',1,0)

obj.Phones

obj.lostConnection('ID3')

obj.Phones

obj.newConnection('ID3',-1,0)

phoneIDs = obj.getPhoneIDs()

t1 = tic();
for ii=1:1000000
    obj.ID2phone(IDs{mod(ii,3)+1});
end
t1 = toc(t1)
% takes 28.9886 [s] for 10^6 itterations, so is fast


numPhones = 3
numSamples = 1000
samples = rand(numSamples, numPhones)

obj.newSamplesAvailable(samples, IDs)