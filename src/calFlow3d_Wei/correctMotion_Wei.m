function dat_corrected=correctMotion_Wei(data1,phi_current)

[x,y,z] = size(data1);
pad_size = [100 100 3];
data1_pad = padarray(data1,pad_size,'replicate');

[x_ind,y_ind,z_ind] = ind2sub(size(data1),1:x*y*z);

x_bias = reshape(phi_current(:,:,:,1),[1 x*y*z]);
y_bias = reshape(phi_current(:,:,:,2),[1 x*y*z]);
z_bias = reshape(phi_current(:,:,:,3),[1 x*y*z]);

% get tranformed data
x_new = x_ind + x_bias;
y_new = y_ind + y_bias;
z_new = z_ind + z_bias;
data1_tran = interp3(data1_pad,y_new+pad_size(2),x_new+pad_size(1),z_new+pad_size(3));
dat_corrected = gather(reshape(data1_tran, [x y z]));

end