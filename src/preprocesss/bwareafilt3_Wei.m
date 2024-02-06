function vol=bwareafilt3_Wei(vol,range)

CC = bwconncomp(vol);
numPixels = cellfun(@numel,CC.PixelIdxList);
for cnt=1:length(numPixels)
    if numPixels(cnt)<range(1) || numPixels(cnt)>range(2)
        vol(CC.PixelIdxList{cnt})=false;
    end
end

end