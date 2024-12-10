function retrieve_subject_GC_cmd(Zheader, Gheader, SubjectNo, ftag )

  if nargin < 3
    ftag = '';
  end

  assignin( 'caller', 'GC', [] );

  % --- GC variable may not have been preserved, load in G and C and calc if possible
  retrieve_subject_G_cmd( Gheader, Zheader,  SubjectNo );
  C = load_subject_C_cmd(  Gheader, Zheader, SubjectNo, ftag );
  if ~isempty(G) && ~isempty( C )
    assignin( 'caller', 'GC', G * C );
  end
  clear G C;
    
end


