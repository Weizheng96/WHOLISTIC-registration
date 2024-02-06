function [dat_corrected,x_new,y_new,z_new,invalidRegion]=correctMotion_Wei_v2(data_raw,phi_current)

% extract motion
[x,y,z] = size(data_raw);
[x_ind,y_ind,z_ind] = ind2sub(size(data_raw),1:x*y*z);
x_bias = reshape(phi_current(:,:,:,1),[1 x*y*z]);
y_bias = reshape(phi_current(:,:,:,2),[1 x*y*z]);
z_bias = reshape(phi_current(:,:,:,3),[1 x*y*z]);

% get tranformed data
x_new = x_ind + x_bias; 
y_new = y_ind + y_bias; 
z_new = z_ind + z_bias; 


if nargout==5
    invalidRegion=(x_new<1|x_new>x|y_new<1|y_new>y|z_new<1|z_new>z);
    invalidRegion=reshape(invalidRegion, [x y z]);
end

x_new=max(x_new,1); x_new=min(x_new,x);
y_new=max(y_new,1); y_new=min(y_new,y);
z_new=max(z_new,1); z_new=min(z_new,z);

data1_tran = interp3(data_raw,y_new,x_new,z_new);
dat_corrected = reshape(data1_tran, [x y z]);

end