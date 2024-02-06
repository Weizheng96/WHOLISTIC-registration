% data1=downsample3D(gpuArray(dat_mov),8);

[x,y,z]=size(dat_mov);

tic
[y_ind2,x_ind2,z_ind2] = meshgrid(1:y,1:x,1:z);
toc

tic
[x_ind,y_ind,z_ind] = ind2sub([x y z],gpuArray(1:x*y*z));
x_ind=single(x_ind);y_ind=single(y_ind);z_ind=single(z_ind);
toc

tic
[x_ind,y_ind,z_ind] = ind2sub(size(data1),1:x*y*z);
x_ind=gpuArray(single(x_ind));y_ind=gpuArray(single(y_ind));z_ind=gpuArray(single(z_ind));
toc

tic
% ndx=uint32(0):uint32(x*y*z-1);
ndx=0:x*y*z-1;
ndx=gpuArray(ndx);
x_ind=mod(ndx,x);
ndx=(ndx-x_ind)/x;
y_ind=mod(ndx,y);
ndx=(ndx-y_ind)/y;
z_ind=mod(ndx,z);
x_ind2=x_ind+1;
y_ind2=y_ind+1;
z_ind2=z_ind+1;
% x_ind=gather(x_ind);
% y_ind=gather(y_ind);
% z_ind=gather(z_ind);
toc

tic
ndx=single(0):single(x*y*z-1);
x_ind=mod(ndx,x);
ndx=(ndx-x_ind)/x;
toc


a=y_ind2(:)==uint32(y_ind3(:));