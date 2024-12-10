function pca_summary( sumDiag, model, S, fid, tsums )
global Zheader

isROI = strcmp( model, 'GCr' );

if nargin < 5,   tsums = Zheader.tsum;  end

if length(model) == 1
  Alg = 'Z';

else
  if strcmp( model, 'GMH' ) || strcmp( model(1:2), 'GC' ) || strcmp( model, 'BH' )
    Alg = 'Z';
  else
    Alg = char(model(1));
    if isROI
      Alg = 'Zt';
    end
  end;

end;

Divisor = Zheader.total_scans;
nfreq = max( 1, Zheader.num_Z_arrays );

fprintf( fid, '\n----------------------------------------------------------------------------------------\n' );
fprintf( fid, '%% Basic PCA summary\n' );
fprintf( fid, '----------------------------------------------------------------------------------------\n' );

ssZ = sprintf( '%15.2f', tsums);
varZ = sprintf( '%15.2f', tsums/Divisor);
sd = sprintf( '%15.2f', sumDiag );
  na = '         ';
full = '(100.00%)';

if Zheader.num_Z_arrays > 1
  hdr =  ['              Sum of Squares         variance   % of ' model '    % of ' Alg '     % of freq' ];
else
  hdr =  ['              Sum of Squares         variance   % of ' model '    % of ' Alg ' ' ];
end;
ln  =  ['         ' Alg '   ' ssZ '  ' varZ '  ' na  '  ' full ];
if isROI
  ln  =  ['        ' Alg '   ' ssZ '  ' varZ '  ' na  '  ' full ];
end

fprintf( fid, '\n%s\n', hdr);
fprintf( fid, '%s\n', ln );

GCZ = sprintf( '%7.2f%%', sumDiag/tsums * 100);
if Zheader.num_Z_arrays > 0
  fGCZ = sprintf( '%7.2f%%', sumDiag/(tsums/nfreq) * 100);
else
  fGCZ = na;
end;

varGC = sprintf( '%15.2f', sumDiag/Divisor);
GCpZ = sprintf( '%7.2f%%', sumDiag/tsums * 100);
gcvar = sprintf( '%10s', model );
ln  =  [ gcvar '   ' sd '  ' varGC '  ' full  '  ' GCpZ '  '  ];
fprintf( fid, '%s\n', ln );

SSQ = [];

if Zheader.num_Z_arrays > 0
  if strcmp( model, 'GC' )
      
    load( Zheader.Model.path, 'Gheader' );
    SSQ = load_GC_var( Gheader, 'SSQ' );
    
  else
    if strcmp( model, 'GMH' ) || strcmp( model, 'GnotH' ) || strcmp( model, 'HnotG' )
      load( Zheader.Limits.path );
      SSQ = load_GMH_var( Hheader, model, 'SSQ' );
    end;
  end;
  
  if ~isempty( SSQ )

    fprintf( fid, '\n' );
    for freq = 1:max( 1, Zheader.num_Z_arrays )

      ftag = frequency_tag( freq );
      ftag = strrep( ftag, '_', '' );
        
      fsd = sprintf( '%15.2f', SSQ.Fsd(freq) );
      GCZ = sprintf( '%7.2f%%', SSQ.Fsd(freq)/tsums * 100);
      GCpZ = sprintf( '%7.2f%%', SSQ.Fsd(freq)/(tsums/nfreq) * 100);
      varGC = sprintf( '%15.2f', SSQ.Fsd(freq)/Divisor);
      GCP = sprintf( '%7.2f%%', SSQ.Fsd(freq)/sumDiag * 100 );
      gcvar = sprintf( '%10s', ftag );
      ln  =  [ gcvar '   ' fsd '  ' varGC '  ' GCP '   ' GCZ '  ' GCpZ ];
      fprintf( fid, '%s\n', ln );

    end;
      
    fprintf( fid, '%s\n', '----------------------------------------------------------------------------------------' );
      
      
  end;
end;

fprintf( fid, '\n' );

for comp = 1:size( S.component_variance, 2 )
 cmpno = sprintf( '   comp %02d', comp );
 GCsd = sprintf( '%15.2f', sumDiag * (S.percent_explained_in_GC(comp) / 100) );
 GCP = sprintf( '%7.2f%%', S.percent_explained_in_GC(comp) );
 GCZ = sprintf( '%7.2f%%', S.percent_explained_in_Z(comp) );
 varGC = sprintf( '%15.2f', S.component_variance(comp) );
% GCpGC = sprintf( '%7.2f%%',  S.percent_explained_in_GC(comp) );
% GCpZ = sprintf( '%7.2f%%',  S.percent_explained_in_Z(comp) );
 ln  =  [ cmpno '   ' GCsd '  ' varGC '  ' GCP  '   ' GCZ ];
 fprintf( fid, '%s\n', ln );
end;

fprintf( fid, '%s\n', '----------------------------------------------------------------------------------------' );

GCsd = sprintf( '%15.2f', sumDiag * (sum(S.percent_explained_in_GC) / 100) );
GCP = sprintf( '%7.2f%%', sum(S.percent_explained_in_GC) );
GCZ = sprintf( '%7.2f%%', sum(S.percent_explained_in_Z) );
varGC = sprintf( '%15.2f', sum(S.component_variance) );
%GCpGC = sprintf( '%7.2f%%',  sum(S.percent_explained_in_GC) );
%GCpZ = sprintf( '%7.2f%%',  sum(S.percent_explained_in_Z) );
ln  =  [ '             ' GCsd '  ' varGC '  ' GCP  '   ' GCZ ];
fprintf( fid, '%s\n', ln );


