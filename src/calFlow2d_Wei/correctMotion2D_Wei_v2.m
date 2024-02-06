function [dat1_corrected,dat2_corrected]=correctMotion2D_Wei_v2(data1_raw,data2_raw,phi_current)
phi_current=gpuArray(phi_current);
% extract motion
[x,y,z] = size(data1_raw);
[x_ind,y_ind,z_ind] = ind2sub(size(data1_raw),1:x*y*z);
x_ind=gpuArray(single(x_ind));y_ind=gpuArray(single(y_ind));z_ind=gpuArray(single(z_ind));
x_bias = reshape(phi_current(:,:,:,1),[1 x*y*z]);
y_bias = reshape(phi_current(:,:,:,2),[1 x*y*z]);

% get tranformed data
x_new = x_ind + x_bias; x_new=max(x_new,1); x_new=min(x_new,x);
y_new = y_ind + y_bias; y_new=max(y_new,1); y_new=min(y_new,y);
data1_tran = interp3(data1_raw,y_new,x_new,z_ind);
dat1_corrected = reshape(data1_tran, [x y z]);

data2_tran = interp3(data2_raw,y_new,x_new,z_ind);
dat2_corrected = reshape(data2_tran, [x y z]);

end