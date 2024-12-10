%% Called by significance_test.m %%

function [Fmx d2 dd] = pcaptspecial1_Todd(GA, Z)

[np nc]=size(GA);
A=GA'*GA;
[u1 d1 v1]=svd(A);
Aisq=u1*sqrt(inv(d1))*v1';
U=GA*Aisq;%U is such that UU' is P_{GA}
B=U'*Z;
BBp=B*B';
[P d2 v2]=svd(BBp);%d2 has dominant eigenvalues
u=U*P; %u is a matrix of left singular vectors of P_{GA}Z

Ns=100;
pb=0;
ls=0;
Fmx=[];
D3M=[];
Rmxc=[];
GB=zeros(np,nc);
a=zeros(np,1);
%pb<.05 & 
while ls<nc
    ls=ls+1;
    rmxc=d2(ls,ls);%The ls-th largest eigenvalue of Z'P_{GA}Z
    Rmxc=[Rmxc;rmxc];
    fmx=0;    
    D3m=[];
    for k=1:Ns
        a=randperm(np);
        GB=GA(a,:);
        UU=GB*Aisq;
        Bt=UU'*Z;
        BBt=Bt*Bt';
        d3=svd(BBt);
        %eigenvalue from a permuted matrix
       D3m=[D3m; d3(1,1)];
       [rmxc d3(1,1)];
        if d3(1)>rmxc
            fmx=fmx+1;%Counts the number of times
%d3(1) exceeds the ls-th largest eigenvalue from
%the original data
        end
        dd(k,ls)=d3(1);
    end
    D3M=[D3M D3m];
    pb=fmx/Ns;%the p-value
    [ls pb]
    Temp=[ls fmx pb];
    Fmx=[Fmx;Temp];
    save temp_perm.mat Fmx D3M Rmxc
    u(:,ls)=zeros(np,1);%Deflation
    B=u'*Z;
%    Z=u*(u'*Z);%
end

