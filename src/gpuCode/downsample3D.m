function dat=downsample3D(dat,r)

[x,y,z]=size(dat);

xG=1:r:floor(x/r)*r;
yG=1:r:floor(y/r)*r;
zG=1:r:floor(z/r)*r;

for xCnt=1:r-1
    dat(xG,:,:)=dat(xG,:,:)+dat(xG+xCnt,:,:);
end
dat=dat(xG,:,:);

for yCnt=1:r-1
    dat(:,yG,:)=dat(:,yG,:)+dat(:,yG+yCnt,:);
end
dat=dat(:,yG,:);

for zCnt=1:r-1
    dat(:,:,zG)=dat(:,:,zG)+dat(:,:,zG+zCnt);
end
dat=dat(:,:,zG);

end