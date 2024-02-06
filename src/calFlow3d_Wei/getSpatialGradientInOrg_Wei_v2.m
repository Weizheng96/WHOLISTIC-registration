function [Ix,Iy,Iz]=getSpatialGradientInOrg_Wei_v2(data_raw,x_new,y_new,z_new)
%% set parameters
step=1;
%% extract motion
[x,y,z] = size(data_raw);
%% get gradient
data1_incre = interp3(data_raw,y_new,rangeConstrain(x_new+step,1,x),z_new);
data1_decre = interp3(data_raw,y_new,rangeConstrain(x_new-step,1,x),z_new);
Ix = (data1_incre - data1_decre)/(2*step);
% clear data1_incre data1_decre

data1_incre = interp3(data_raw,rangeConstrain(y_new+step,1,y),x_new,z_new);
data1_decre = interp3(data_raw,rangeConstrain(y_new-step,1,y),x_new,z_new);
Iy = (data1_incre - data1_decre)/(2*step);
% clear data1_incre data1_decre

data1_incre = interp3(data_raw,y_new,x_new,rangeConstrain(z_new+step,1,z));
data1_decre = interp3(data_raw,y_new,x_new,rangeConstrain(z_new-step,1,z));
Iz = (data1_incre - data1_decre)/(2*step);
% clear data1_incre data1_decre

%% reshape
Ix = reshape(Ix, [x y z]);
Iy = reshape(Iy, [x y z]);
Iz = reshape(Iz, [x y z]);

end