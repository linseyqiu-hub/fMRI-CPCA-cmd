function retrieve_subject_GC( Gheader, SubjectNo, ftag )

  if nargin < 3
    ftag = '';
  end

  assignin( 'caller', 'GC', [] );

  % --- GC variable may not have been preserved, load in G and C and calc if possible
  retrieve_subject_G( Gheader, SubjectNo );
  C = load_subject_C( Gheader, SubjectNo, ftag );
  if ~isempty(G) && ~isempty( C )
    assignin( 'caller', 'GC', G * C );
  end
  clear G C;
    
end


