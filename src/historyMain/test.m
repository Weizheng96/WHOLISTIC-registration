filePath="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230216-v20_jump20_penalty1/" + ...
    "Original_Corrected.ome.tiff";

reader = bfGetReader(convertStringsToChars(filePath));
omeMeta = reader.getMetadataStore();
Y = omeMeta.getPixelsSizeX(0).getValue(); 
X = omeMeta.getPixelsSizeY(0).getValue(); 
Z = omeMeta.getPixelsSizeZ(0).getValue(); 
T = omeMeta.getPixelsSizeT(0).getValue(); 

tRange=201:2:210;
tLength=length(tRange);
templateLst=zeros(X,Y,Z,tLength);
for tCnt=1:tLength
    t=tRange(tCnt);
    templateLst(:,:,:,tCnt)=readOneFrame_double(reader,t,2);
end

template=median(templateLst,4);
implay(template/300)