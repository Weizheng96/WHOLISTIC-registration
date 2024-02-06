function dat_mov=resizeMov(dat_mov_Raw,Z_ref,option)

[X,Y,Z]=size(dat_mov_Raw);

resizeRatio=option.zRatio_mov/option.zRatio_ref;
zPadUp=ceil((Z_ref-Z*resizeRatio)/2)-8;
zPadBot=Z_ref-Z*resizeRatio-zPadUp;


dat_mov = imresize3(dat_mov_Raw,[X Y Z*resizeRatio]);
dat_mov = padarray(dat_mov,[0 0 zPadUp],'replicate','pre');
dat_mov = padarray(dat_mov,[0 0 zPadBot],'replicate','post');


end