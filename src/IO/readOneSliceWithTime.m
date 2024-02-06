function dat=readOneSliceWithTime(reader,z,tRange,c)


t=tRange(1);
iPlane = reader.getIndex(z - 1, c -1, t - 1) + 1;
I = bfGetPlane(reader, iPlane);
dat=zeros([size(I) length(tRange)],class(I));
dat(:,:,1)=I;

for tCnt=2:length(tRange)
    t=tRange(tCnt);
    iPlane=reader.getIndex(z - 1, c -1, t - 1) + 1;
    dat(:,:,tCnt)=bfGetPlane(reader, iPlane);
end

end