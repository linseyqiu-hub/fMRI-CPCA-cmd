%%%%%%%%%  script written by Jen Whitman to convert UR into a format usable in excel	%%%%%%%%%%%%%

nconds=input('Please enter the number of conditions: \n');
numsubj=input('Please enter the number of subjects:  \n');
nbins=input('Please enter the number of timebins modeled:   \n');
numcomps=input('Please enter the number of components extracted:   \n');
q1=input('Would you like to zero-center the beginning of each UR timecourse? 1=yes or 2=no:, \n');
clear cond*
clear comp*


for cmp=1:numcomps
 clear cond*
 eval(['comp' int2str(cmp) '=[];']);

 graphdata=[];
 
for cond=1:nconds
    
    for s=1:numsubj
            
            startrow=(s-1)*nbins*nconds+(cond-1)*nbins+1;
            endrow=startrow+nbins-1;
            temp=UR(startrow:endrow,cmp);

            eval(['cond' int2str(cond) '(:,s)=temp;'])

            
    end
            eval(['cond' int2str(cond) '=transpose(cond' int2str(cond) ');'])
            [rows cols]=size(cond1);
            eval(['firstcol=cond' int2str(cond) '(:,1);']);
	    	if q1==1;
            		for col=1:cols
               		eval(['cond' int2str(cond) '(:,col)=cond' int2str(cond) '(:,col)-firstcol;'])            
            		end
	    	
	    	else q1==2;

	    	end
    
    %eval(['comp' int2str(cmp) '=[cond' int2str(cond) ' comp' int2str(cmp) '];'])
    eval(['comp' int2str(cmp) '=[comp' int2str(cmp) ' cond' int2str(cond) ' ];'])
    eval(['graphdata=[transpose(mean(cond' int2str(cond) ')) graphdata];'])
    
     
end

    figure
    plot(graphdata)
    	if q1==1;
    	eval(['save fakecomp' int2str(cmp) '_zeroed.txt -ascii comp' int2str(cmp)]);
    	else q1==2;

	eval(['save fakecomp' int2str(cmp) '.txt -ascii comp' int2str(cmp)]);
    	end
end	

        
