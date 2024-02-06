function dat=getSumInPatch_v3(dat,r,rz,xG,yG,zG,x,y,z)


% x_new=xG(end)+r;y_new=yG(end)+r;z_new=zG(end)+rz;
x_pad=xG(end)+2*r-x;y_pad=yG(end)+2*r-y;z_pad=zG(end)+2*rz-z;

dat=padarray(dat,[x_pad y_pad z_pad],'replicate','post');
% dat=dat(1:x_new,1:y_new,1:z_new);

for xCnt=[-r:-1 1:r]
    dat(xG,:,:)=dat(xG,:,:)+dat(xG+xCnt,:,:);
end
dat=dat(xG,:,:);

for yCnt=[-r:-1 1:r]
    dat(:,yG,:)=dat(:,yG,:)+dat(:,yG+yCnt,:);
end
dat=dat(:,yG,:);

for zCnt=[-rz:-1 1:rz]
    dat(:,:,zG)=dat(:,:,zG)+dat(:,:,zG+zCnt);
end
dat=dat(:,:,zG);

end