function dat_mov=resizeMov_v2(dat_mov_Raw,Z_ref,zLst)

[X,Y,Z_mov]=size(dat_mov_Raw);
Z_TEMP=zLst(end)-zLst(1)+1;
[x_new,y_new,z_new] = ind2sub([X Y Z_TEMP],1:X*Y*Z_TEMP);
z_new=(z_new-1)/(Z_TEMP-1)*(Z_mov-1)+1;

dat_mov=reshape(interp3(dat_mov_Raw,y_new,x_new,z_new),[X Y Z_TEMP]);

zPadUp=zLst(1)-1;
zPadBot=Z_ref-zLst(end);
dat_mov = padarray(dat_mov,[0 0 zPadUp],'replicate','pre');
dat_mov = padarray(dat_mov,[0 0 zPadBot],'replicate','post');


end