function dat=downsample3D_v3(dat,r)

if r==1
    return;
end

[x,y,z]=size(dat);

xG=gpuArray(1:r:floor(x/r)*r);
yG=gpuArray(1:r:floor(y/r)*r);
zG=gpuArray(1:r:floor(z/r)*r);

for xCnt=1:r-1
    dat(xG,:,:)=dat(xG,:,:)+dat(xG+xCnt,:,:);
end
% dat=dat(xG,:,:);

for yCnt=1:r-1
    dat(xG,yG,:)=dat(xG,yG,:)+dat(xG,yG+yCnt,:);
end
% dat=dat(:,yG,:);

for zCnt=1:r-1
    dat(xG,yG,zG)=dat(xG,yG,zG)+dat(xG,yG,zG+zCnt);
end
dat=dat(xG,yG,zG);

end