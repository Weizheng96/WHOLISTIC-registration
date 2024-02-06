function outputID = regionGrowxx_3D(inputID,iters, lx,ly,lz,xxshift, yyshift)
   %%% input the numbers of the circles to grow
    [idX, idY, idZ] = ind2sub([lx,ly,lz],inputID);
    zzshift=zeros(size(yyshift));
    for i = 1:iters
        idX = min(max(idX + xxshift(:)',1), lx);
        idY = min(max(idY + yyshift(:)',1),ly);
        idZ = idZ + zzshift(:)';
        outputID = sub2ind([lx,ly,lz],idX(:),idY(:),idZ(:));
        outputID = unique(outputID);
        [idX, idY, idZ] = ind2sub([lx,ly,lz], outputID);
    end
    
end