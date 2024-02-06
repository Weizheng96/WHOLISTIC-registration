function dat_corrected=correctMotion2D_Wei_v1(data_raw,phi_current)

% extract motion
[x,y] = size(data_raw);
[x_ind,y_ind] = ind2sub(size(data_raw),1:x*y);
x_bias = reshape(phi_current(:,:,1),[1 x*y]);
y_bias = reshape(phi_current(:,:,2),[1 x*y]);

% get tranformed data
x_new = x_ind + x_bias; x_new=max(x_new,1); x_new=min(x_new,x);
y_new = y_ind + y_bias; y_new=max(y_new,1); y_new=min(y_new,y);
data1_tran = interp2(data_raw,y_new,x_new);
dat_corrected = reshape(data1_tran, [x y]);

end