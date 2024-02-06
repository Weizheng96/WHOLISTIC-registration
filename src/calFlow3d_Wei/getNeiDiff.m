function neiDiff=getNeiDiff(phi_current,r)

NeiFltr=ones(r*2+1);
NeiFltr=NeiFltr/((r*2+1)^2-1);
NeiFltr(r+1,r+1)=-1;
neiDiff=imfilter(phi_current,NeiFltr,'replicate','same','corr');

end