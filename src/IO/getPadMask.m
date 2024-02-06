function mask_movPad=getPadMask(X,Y,Z_mov,Z_ref,option)

resizeRatio=option.zRatio_mov/option.zRatio_ref;
zPadUp=ceil((Z_ref-Z_mov*resizeRatio)/2)-8;
zPadBot=Z_ref-Z_mov*resizeRatio-zPadUp;

mask_movPad=false(X,Y,Z_ref);
mask_movPad(:,:,1:zPadUp)=true;
mask_movPad(:,:,end-zPadBot+1:end)=true;

end