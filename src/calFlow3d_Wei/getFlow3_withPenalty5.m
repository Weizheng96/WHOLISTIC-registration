function phi_gradient=getFlow3_withPenalty5(IIxx,IIxy,IIxz,IIyy,IIyz,IIzz,Ixt,Iyt,Izt,motion_current,beta,r,zRatio)
%% the control points
[x,y,z,~]=size(motion_current);
xG=r+1:2*r+1:x;yG=r+1:2*r+1:y;zG=1:z;
gStep=2*r+1;
%% calculate transformation gradient of control points (F)
[Fxx,Fxy,Fxz]=getSpatialGradient_Wei(motion_current(xG,yG,zG,1)/gStep);
[Fyx,Fyy,Fyz]=getSpatialGradient_Wei(motion_current(xG,yG,zG,2)/gStep);
[Fzx,Fzy,Fzz]=getSpatialGradient_Wei(motion_current(xG,yG,zG,3));
Fxx=Fxx+1;Fyy=Fyy+1;Fzz=Fzz+1;

%% calculate  transformaion inconsistance (Is)
Isx=getNeiDiff(motion_current(xG,yG,zG,1),1);
Isy=getNeiDiff(motion_current(xG,yG,zG,2),1);
Isz=getNeiDiff(motion_current(xG,yG,zG,3),1);

%% calculate penalty
beta_z=beta*zRatio^2;
Pxx=beta*(Fxx.*Fxx+Fyx.*Fyx)+beta_z*(Fzx.*Fzx);
Pxy=beta*(Fxx.*Fxy+Fyx.*Fyy)+beta_z*(Fzx.*Fzy);
Pxz=beta*(Fxx.*Fxz+Fyx.*Fyz)+beta_z*(Fzx.*Fzz);

Pyx=beta*(Fxy.*Fxx+Fyy.*Fyx)+beta_z*(Fzy.*Fzx);
Pyy=beta*(Fxy.*Fxy+Fyy.*Fyy)+beta_z*(Fzy.*Fzy);
Pyz=beta*(Fxy.*Fxz+Fyy.*Fyz)+beta_z*(Fzy.*Fzz);

Pzx=beta*(Fxz.*Fxx+Fyz.*Fyx)+beta_z*(Fzz.*Fzx);
Pzy=beta*(Fxz.*Fxy+Fyz.*Fyy)+beta_z*(Fzz.*Fzy);
Pzz=beta*(Fxz.*Fxz+Fyz.*Fyz)+beta_z*(Fzz.*Fzz);

Pxt=beta*(Isx.*Fxx+Isy.*Fyx)+beta_z*(Isz.*Fzx);
Pyt=beta*(Isx.*Fxy+Isy.*Fyy)+beta_z*(Isz.*Fzy);
Pzt=beta*(Isx.*Fxz+Isy.*Fyz)+beta_z*(Isz.*Fzz);

%% add penelty
Ixx=IIxx+Pxx;
Ixy=IIxy+Pxy;
Ixz=IIxz+Pxz;

Iyx=IIxy+Pyx;
Iyy=IIyy+Pyy;
Iyz=IIyz+Pyz;

Izx=IIxz+Pzx;
Izy=IIyz+Pzy;
Izz=IIzz+Pzz;

Ixt=Ixt+Pxt;
Iyt=Iyt+Pyt;
Izt=Izt+Pzt;
%% get determinant 3*3
DET=getDet3_2(Ixx,Ixy,Ixz,Iyx,Iyy,Iyz,Izx,Izy,Izz);
%% get minor
M11=   getDet2(Iyy,Iyz,Izy,Izz);
M12=-1*getDet2(Iyx,Iyz,Izx,Izz);
M13=   getDet2(Iyx,Iyy,Izx,Izy);

M21=-1*getDet2(Ixy,Ixz,Izy,Izz);
M22=   getDet2(Ixx,Ixz,Izx,Izz);
M23=-1*getDet2(Ixx,Ixy,Izx,Izy);

M31=   getDet2(Ixy,Ixz,Iyy,Iyz);
M32=-1*getDet2(Ixx,Ixz,Iyx,Iyz);
M33=   getDet2(Ixx,Ixy,Iyx,Iyy);
%% get flow
Vx=(M11.*Ixt+M12.*Iyt+M13.*Izt)./DET;
Vy=(M21.*Ixt+M22.*Iyt+M23.*Izt)./DET;
Vz=(M31.*Ixt+M32.*Iyt+M33.*Izt)./DET;
%% merge
phi_gradient=cat(4,Vx,Vy,Vz);
phi_gradient(isnan(phi_gradient))=0;

end