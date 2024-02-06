function phi_gradient=getFlow2D_withPenalty_v3(Ixx,Ixy,Iyy,Ixt,Iyt,smoothPenaltySum,neiSum)
%% add penelty
Ixx=Ixx+smoothPenaltySum;
Iyy=Iyy+smoothPenaltySum;
Ixt=Ixt+neiSum(:,:,:,1);
Iyt=Iyt+neiSum(:,:,:,2);
%% get determinant 3*3
DET=getDet2(Ixx,Ixy,Ixy,Iyy);
%% get minor
M11=Iyy;
M12=-1*Ixy;
M22=Ixx;
%% get flow
Vx=(M11.*Ixt+M12.*Iyt)./DET;
Vy=(M12.*Ixt+M22.*Iyt)./DET;

%% merge
phi_gradient=cat(4,Vx,Vy);
phi_gradient(isnan(phi_gradient))=0;

end