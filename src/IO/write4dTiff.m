function write4dTiff(dat,ImName)

dat = uint16(dat);
% dat=permute(dat,[2 1 3 4]);
fiji_descr = ['ImageJ=1.52p' newline ...
            'images=' num2str(size(dat,3)*...
                              size(dat,4)) newline... 
            'slices=' num2str(size(dat,3)) newline...
            'frames=' num2str(size(dat,4)) newline... 
            'hyperstack=true' newline...
            'mode=grayscale' newline...  
            'loop=false' newline...  
            'min=' num2str(min(dat(:))) newline...      
            'max=' num2str(max(dat(:)))];  % change this to 256 if you use an 8bit image
            
t = Tiff(ImName,'w');
tagstruct.ImageLength = size(dat,1);
tagstruct.ImageWidth = size(dat,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 16;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.LZW;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.ImageDescription = fiji_descr;
for frame = 1:size(dat,4)
    for slice = 1:size(dat,3)
        t.setTag(tagstruct)
        t.write(im2uint16(dat(:,:,slice,frame)));
        t.writeDirectory(); % saves a new page in the tiff file
    end
end
t.close() 

end