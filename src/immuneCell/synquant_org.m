function ZMap = synquant_org(input,minSZ,smoothingfactor,Mu,Sigma)
%%
imregion1 = double(input);
imregion1G = imgaussfilt(imregion1,smoothingfactor);

iters1 = 1;
xxshift1 = zeros(2*iters1+1, 2*iters1+1);
yyshift1 = zeros(2*iters1+1, 2*iters1+1);
for i = -iters1:iters1
    for j = -iters1:iters1
        xxshift1(i+iters1+1,j+iters1+1) = i;
        yyshift1(i+iters1+1,j+iters1+1) = j;
    end
end

[lenx, leny, lenz] = size(imregion1G);
ZMap = zeros(size(imregion1G));

% maxThres=(ceil(max(imregion1G(:)))-1);
% minThres=Mu;
maxThres=500;
minThres=150;
stepThres=2;
for i = maxThres:-stepThres:minThres
    disp(i);
    mask = double(imregion1G > i);
    maskroi = bwlabeln(mask);
    maskroiIDx = label2idx(maskroi);
    lengthx = cellfun(@length, maskroiIDx);
    maskroiIDx(lengthx < 10) = [];
    for j = 1:length(maskroiIDx)
        idxtmp = maskroiIDx{j};
        N=length(idxtmp);
        if(N>minSZ&&N<10000)
            idxtmpneiL1 = regionGrowxx_3D(idxtmp,smoothingfactor, lenx,leny,lenz,xxshift1, yyshift1);
            idxtmpnei = setdiff(idxtmpneiL1, idxtmp);
            if ~isempty(idxtmpnei)
                signal = imregion1(idxtmp);
                signalNei = imregion1(idxtmpnei);
                [mutmp, sigmatmp] = ksegments_orderstatistics_fin(signal, signalNei);
                meanDiff=mean(signal)-mean(signalNei);
                zscore = (meanDiff - mutmp*Sigma)/(sigmatmp*Sigma);
                if(zscore>max(ZMap(idxtmp)))
                    ZMap(idxtmp)=zscore;
                end
            end
        end
    end
end

end