function [x_new,y_new,z_new]=correctIdx(data_raw,phi_current,x_ind,y_ind,z_ind)
% extract motion
[x,y,z] = size(data_raw);
% [x_ind,y_ind,z_ind] = ind2sub(size(data_raw),1:x*y*z);
x_bias = reshape(phi_current(:,:,:,1),[1 x*y*z]);
y_bias = reshape(phi_current(:,:,:,2),[1 x*y*z]);
z_bias = reshape(phi_current(:,:,:,3),[1 x*y*z]);

% get tranformed data
x_new = x_ind + x_bias; x_new=max(x_new,1); x_new=min(x_new,x);
y_new = y_ind + y_bias; y_new=max(y_new,1); y_new=min(y_new,y);
z_new = z_ind + z_bias; z_new=max(z_new,1); z_new=min(z_new,z);

end