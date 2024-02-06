function dat_corrected=correctMotion_Wei_v3_nearest(data_raw,x_new,y_new,z_new)
[x,y,z] = size(data_raw);
data1_tran = interp3(single(data_raw),y_new,x_new,z_new,'nearest');
dat_corrected = reshape(data1_tran, [x y z]);

end