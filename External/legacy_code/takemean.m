% function to remove mean activations for each subject
function [Z]=takemean(Z,NumScans,numsubs);

[nr nc]=size(Z); 

for loop=1:numsubs;
  OMult=ones(NumScans(loop),1);
  loop
  if loop==1
    start=1;
    endd=NumScans(1);
  else
    start=sum(NumScans(1:loop-1))+1;
    endd=sum(NumScans(1:loop));
  end
  ZSINGSUB=Z(start:endd,:);
  MTest=mean(ZSINGSUB);
  ZSD=std(ZSINGSUB);  % CHANGE: added this line to take SD of each subject's Z
  SUBMAT=OMult*MTest;
  ZSDSINGSUB=OMult*ZSD; % CHANGE: added this line to transform SD of each column of Z from a vector to a matrix
  ZSINGSUBNOMEAN=(ZSINGSUB-SUBMAT)./ZSDSINGSUB;  % CHANGE added '/ZSDSINGSUB' to normalize each subject's Z
  Z(start:endd,:)=ZSINGSUBNOMEAN;
end
