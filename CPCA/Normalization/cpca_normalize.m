function mtx = cpca_normalize( mtx, pb )
% mean center and standardize given matrix

if ( nargin < 2 )  pb = struct( 'pb', 0 );  end

[ngr ngc]=size(mtx);

if ( strcmp( class(pb ), 'progress_display' ) )
    pb.setIterations( ngc * 2 );
end

xx=0;

for jj=1:ngc
    ga=mtx(:,jj);
    gam=sum(ga)/ngr;
    for ii=1:ngr
        mtx(ii,jj)=ga(ii)-gam;
    end

    if ( strcmp( class(pb ), 'cpca_progress' ) )
        pb.increment()
    end

end


for j=1:ngc
    ga=mtx(:,j);
    sdg=sqrt((ga'*ga)/ngr);
    for i=1:ngr
        if sdg ~= 0
            mtx(i,j)=ga(i)/sdg;
        end
    end

    if ( strcmp( class(pb ), 'cpca_progress' ) )
        pb.increment()
    end

end


