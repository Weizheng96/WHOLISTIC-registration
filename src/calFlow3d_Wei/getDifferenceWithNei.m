function Diff=getDifferenceWithNei(phi_current)
r=1;
DiffFltr=-ones(r*2+1);
DiffFltr(r+1,r+1)=(r*2+1)^2-1;
DiffFltr=DiffFltr/(r*2+1)^2;
Diff=imfilter(phi_current,DiffFltr,'replicate','same','corr');

end