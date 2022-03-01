function [NI,NIPos,NINeg,pmask,sigMats,cor,pv]=CorrelationWithMoca(mat,maskmatrix,MocaScores,pthresh)
%this function find the connections where the connectivity correlate with moca
%score, to search for the edges where the change of connectivity correlates
%with the change of moca score, the input should be the difference of
%connecctivity matrices and Moca scores between the timepoints.
%
%Inputs: -mat: the connectivity matrix of dimension [ROI*ROI*NSub] (or the difference in connectivity between timepoints)
%        -maskmatrix: the mask matrix of dimension [ROI*ROI] containing 1 for significant connections and 0 for non-significant edges 
%        -MocaScores: the Moca score of dimension [NSub*1] (or the difference in Moca between timepoints)
%        -pthresh: the p-value of the statistical significance for the correlation
%
%Outputs:-NI: Network Index for all significant edges where the connectivity correlates with Moca    %-NIPos: Network Index for significant edges where the connectivity correlates positively the Moca
%        -NINeg: Network Index for significant edges where the connectivity correlates negatively with Moca
%        -pmask: mask of the significance of correlations,contains 1 if significant and 0 otherwise
%        -cor: The pearson's coefficient of the correlation of each edge
%        -pv: the p-value of the correlation of each edge
%
% This code was originally developped by Sahar Yassine
% contact: saharyassine94@gmail.com
%

%%
NI=nan(size(MocaScores));
NIPos=nan(size(MocaScores));
NINeg=nan(size(MocaScores));

%ignore subjects with Nan scores
ind=(isnan(MocaScores)==0);
MocaScores_new=MocaScores(ind);
mat_new=mat(:,:,ind);

% check only significant connections
for j=1:size(mat_new,3)
    mat_new(:,:,j)=squeeze(mat_new(:,:,j)).*maskmatrix;
end
reshapedAvg=ReshapeMat(mat_new);

[r,p]=corr(reshapedAvg',MocaScores_new);
pmask=(+(r>0))-(+(r<0));
pmask=pmask.*(+(p<pthresh));
reshapedAvg=reshapedAvg.*abs(pmask);

% Split into edges with positive and negative correlation
matSigPos=reshapedAvg((pmask>0),:);
matSigNeg=reshapedAvg((pmask<0),:);
matSig=reshapedAvg((pmask>0)|(pmask<0),:);
spos=sum(pmask>0);
sneg=sum(pmask<0);
if (spos>1)
    NIPos(ind)=mean(matSigPos);
elseif (spos==1)
    NIPos(ind)=matSigPos';
end
if (sneg>1)
    NINeg(ind)=mean(matSigNeg);
elseif (sneg==1)
    NINeg(ind)=matSigNeg';
end
if(spos+sneg>1)
    NI(ind)=mean(matSig);
elseif(spos+sneg==1)
    NI(ind)=matSig';
end


%%plotting 

x=min(MocaScores_new)-1:max(MocaScores_new)+1;
popos=polyfit(MocaScores_new,NIPos(ind),1);
ffpos=polyval(popos,x);
[rpos,ppos]=corr(NIPos(ind),MocaScores_new);

poneg=polyfit(MocaScores_new,NINeg(ind),1);
ffneg=polyval(poneg,x);
[rneg,pneg]=corr(NINeg(ind),MocaScores_new);

figure,subplot(2,1,1)
plot(MocaScores_new,NIPos(ind)','x');
hold on, plot(x,ffpos,'-r');
caption=sprintf('R= %.3f, NEPos=%d',rpos,spos);
title(caption,'fontsize',15);
cor(1)=rpos;pv(1)=ppos;

subplot(2,1,2)
plot(MocaScores_new,NINeg(ind)','x');
hold on, plot(x,ffneg,'-r');
caption=sprintf('R= %.3f, NENeg=%d',rneg,sneg);
title(caption,'fontsize',15);
cor(2)=rneg;pv(2)=pneg;

sigMats=reshapedToOrig(pmask);

end

function reshaped=ReshapeMat(allAvg)
N=size(allAvg,1);
nsub=size(allAvg,3);
nbEdges=(N*(N-1))/2;
reshaped=zeros(nbEdges,nsub);

for k=1:nsub
    count=1;
    for i=1:N
        for j=i+1:N
            reshaped(count,k)=allAvg(i,j,k);
            count=count+1;
        end
    end
end

end

function orig=reshapedToOrig(reshaped)
nsub=size(reshaped,2);
N=210;
orig=zeros(N,N,nsub);

for k=1:nsub
    count=1;
    for i=1:N
        for j=i+1:N
            orig(i,j,k)=reshaped(count,k);
            count=count+1;
        end
    end
end

end