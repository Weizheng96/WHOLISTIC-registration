function neiDiff=getNeiDiff_v2(phi_current,r,rz)

NeiFltr=ones(r*2+1,r*2+1,rz*2+1);
NeiFltr=NeiFltr/((r*2+1)^2*(rz*2+1)-1);
NeiFltr(r+1,r+1,rz+1)=-1;
neiDiff=imfilter(phi_current,NeiFltr,'replicate','same','corr');

end