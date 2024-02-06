function phi_gradient=getFlow3_withPenalty(Ixx,Ixy,Ixz,Iyy,Iyz,Izz,Ixt,Iyt,Izt,smoothPenaltySum,neiSum)
%% add penelty
Ixx=Ixx+smoothPenaltySum;
Iyy=Iyy+smoothPenaltySum;
Izz=Izz+smoothPenaltySum;
Ixt=Ixt+neiSum(:,:,:,1);
Iyt=Iyt+neiSum(:,:,:,2);
Izt=Izt+neiSum(:,:,:,3);
%% get determinant 3*3
DET=getDet3(Ixx,Ixy,Ixz,Iyy,Iyz,Izz);

%% get minor
M11=getDet2(Iyy,Iyz,Iyz,Izz);
M12=-1*getDet2(Ixy,Iyz,Ixz,Izz);
M13=getDet2(Ixy,Iyy,Ixz,Iyz);
M22=getDet2(Ixx,Ixz,Ixz,Izz);
M23=-1*getDet2(Ixx,Ixy,Ixz,Iyz);
M33=getDet2(Ixx,Ixy,Ixy,Iyy);
%% get flow
Vx=-(M11.*Ixt+M12.*Iyt+M13.*Izt)./DET;
Vy=-(M12.*Ixt+M22.*Iyt+M23.*Izt)./DET;
Vz=-(M13.*Ixt+M23.*Iyt+M33.*Izt)./DET;
phi_gradient=cat(4,Vx,Vy,Vz);

end