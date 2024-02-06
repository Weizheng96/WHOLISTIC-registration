function dat=downsample3DHZR_v1(dat,r)

if r==1
    return;
end

[x,y,~]=size(dat);

xG=gpuArray(1:r:floor(x/r)*r);
yG=gpuArray(1:r:floor(y/r)*r);

for xCnt=1:r-1
    dat(xG,:,:)=dat(xG,:,:)+dat(xG+xCnt,:,:);
end
% dat=dat(xG,:,:);

for yCnt=1:r-1
    dat(xG,yG,:)=dat(xG,yG,:)+dat(xG,yG+yCnt,:);
end
% dat=dat(:,yG,:);

dat=dat(xG,yG,:);

end