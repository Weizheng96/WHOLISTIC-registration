function neiSum=getNeiSum2(phi_current,r)
NeiFltr=ones(r*2+1);
NeiFltr(r+1,r+1)=0;
neiSum=imfilter(phi_current,NeiFltr,'replicate','same','corr');

end