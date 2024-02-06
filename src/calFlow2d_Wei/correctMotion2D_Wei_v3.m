function dat_corrected=correctMotion2D_Wei_v3(data_raw,phi_current,x_ind,y_ind,z_new)

% extract motion
[x,y,z] = size(data_raw);
% [x_ind,y_ind,z_new] = ind2sub(size(data_raw),1:x*y*z);
x_bias = reshape(phi_current(:,:,:,1),[1 x*y*z]);
y_bias = reshape(phi_current(:,:,:,2),[1 x*y*z]);

% get tranformed data
x_new = x_ind + x_bias; x_new=max(x_new,1); x_new=min(x_new,x);
y_new = y_ind + y_bias; y_new=max(y_new,1); y_new=min(y_new,y);
data1_tran = interp3(data_raw,y_new,x_new,z_new);
dat_corrected = reshape(data1_tran, [x y z]);

end