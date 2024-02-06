function dat=downsample3D_v2(dat,r)

[x,y,z]=size(dat);

xG=(1:r:floor(x/r)*r);
yG=(1:r:floor(y/r)*r);
zG=(1:r:floor(z/r)*r);

dat=dat(xG,yG,zG);

end