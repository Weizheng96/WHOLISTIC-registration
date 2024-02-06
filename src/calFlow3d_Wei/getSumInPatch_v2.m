function dat_out=getSumInPatch_v2(dat,r,rz,xG,yG,zG,x,y,z)

% dat=Ix.^2;

x_new=xG(end)+r;y_new=yG(end)+r;z_new=zG(end)+rz;

dat_out=dat;

dat_out=dat_out(1:x_new,:,1:z_new);
dat_out=padarray(dat_out,[0 y_new-y 0],'replicate','post');

dat_out=imresize3(gather(dat_out),[length(xG) length(yG) length(zG)],"box");
dat_out=dat_out*(2*r+1)^2*(2*rz+1);


end