function dat=readOneFrame_single(reader,t,c)

omeMeta = reader.getMetadataStore();
Z = omeMeta.getPixelsSizeZ(0).getValue(); 

z=1;
iPlane = reader.getIndex(z - 1, c -1, t - 1) + 1;
I = bfGetPlane(reader, iPlane);
dat=zeros([size(I) Z],"single");
dat(:,:,1)=I;

for z=2:Z
    iPlane=reader.getIndex(z - 1, c -1, t - 1) + 1;
    dat(:,:,z)=bfGetPlane(reader, iPlane);
end

end