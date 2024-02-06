function dat=readWithTime(reader,tRange,c)


t=tRange(1);
I=readOneFrame(reader,t,c);
dat=zeros([size(I) length(tRange)],class(I));
dat(:,:,:,1)=I;

for tCnt=2:length(tRange)
    t=tRange(tCnt);
    dat(:,:,:,tCnt)=readOneFrame(reader,t,c);
end

end