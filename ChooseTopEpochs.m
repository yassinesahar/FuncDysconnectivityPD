function ChooseTopEpochs(subjDirectory,nbNeededEpochs,twd)

%This function choose the top nbNeededEpochs epochs in terms of automagic
%quality metrics to use for the rest of the analysis, it also choose a bad
%epoch to compute the noice covariance matrix later
%Inputs: -SubjectDirectory: path of the directory of all subjects with preprocessed epochs
%        -nbNeeded epochs: number of needed epochs for the analysis
%        -twd: the directory where to save the chosen epochs
%
% This code was originally developped by Sahar Yassine
% contact: saharyassine94@gmail.com
%
%%
Chansthreshold=0.15; %maximum percentage of interpolated channels
foldersPath=[subjDirectory '/C*'];%pattern of folders
subjects=dir(foldersPath);
for i=1:length(subjects)
    i
    subName=subjects(i).name;
    subPath=[subjDirectory '/' subName '/*p_*.mat'];%pattern of the preprocessed files
    newSubName=[twd '/' subName];
    if ~exist(newSubName, 'dir')
       mkdir(newSubName)
    end
   ppfiles=dir(subPath); 
   mav=[];
   rbc=[];
   oha=[];
   epochs={};
   epNames={};
   count=1;
   hasNoisyEpoch=false;
   for f=1:length(ppfiles)
       fname=[ppfiles(f).folder '/' ppfiles(f).name];
       load(fname); % loaded as EEG and automagic 
       if automagic.selectedQualityScore.RBC<Chansthreshold
           epochs{count,1}=EEG.data;
           epNames{count,1}=ppfiles(f).name;
           oha(count,1)=automagic.selectedQualityScore.OHA;
           mav(count,1)=automagic.selectedQualityScore.MAV;
           rbc(count,1)=automagic.selectedQualityScore.RBC;
           count=count+1;
       else 
           if(hasNoisyEpoch==false)
               %save it as bad Epoch For computing Noise Cov later
               epoch=EEG.data;
               badEpName=[newSubName '/BadEpoch_' ppfiles(f).name];
               save(badEpName,'epoch');
               hasNoisyEpoch=true;
           end
       end
   end
   %sort according to chosen metric
   [ohaSorted,indx]=sort(oha);
   if(length(oha)<=nbNeededEpochs)
       ne=length(oha)-1;
   else
       ne=nbNeededEpochs;
   end
   idxNoisyEpoch=length(oha);
   for f=1:ne
       newFname=[newSubName '/BestN' int2str(f) '_' epNames{indx(f),1}];
       epoch=epochs{indx(f),1};
       save(newFname,'epoch');
   end
   if (hasNoisyEpoch==false)
       epoch=epochs{indx(idxNoisyEpoch),1};
       badEpName=[newSubName '/BadEpoch_' epNames{indx(idxNoisyEpoch),1}];
       save(badEpName,'epoch');
   end
    
   
end

end