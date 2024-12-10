function retrieve_full_subject_C( Gheader, SubjectNo, varname )
global Zheader scan_information
% --- Basic C subject retrieval - multiple frequency only 
% --- for full non frequency subject data use retrieve_subject_C 

  if nargin < 3
    varname = 'C';
  end;
  ftag = frequency_tag(1) ;              % --- only used to test for C existence

  evalin( 'caller', [ varname ' = [];' ] );
  fn = [ 'GC_S' num2str(SubjectNo) ftag '.mat'];
  vname = [ 'C_S' num2str(SubjectNo) '*' ];

  if ~isempty( ftag )
    n = matfile_vars( Gheader.GZheader.path_to_segs, fn, vname );
    if isempty(n)
      GCName = [ Gheader.GZheader.path_to_segs 'GC_S' num2str(SubjectNo) '.mat'];
    end;
  end;

  n = matfile_vars( Gheader.GZheader.path_to_segs, fn, vname );
  if ~isempty(n)

    x = n(1).sz_x;
    y = Zheader.total_columns * max( scan_information.frequencies, 1);
    
    evalin( 'caller', [ varname ' = zeros(' num2str(x) ',' num2str(y) ');' ] );
    
    ec = 0;
    for fno = 1:max( scan_information.frequencies, 1)
      sc = ec + 1;
      ec = sc + Zheader.total_columns - 1;
      ftag = frequency_tag(fno) ;  
      vname = [ 'C_S' num2str(SubjectNo) ftag ];
      fn = [ 'GC_S' num2str(SubjectNo) ftag '.mat'];

      evalin( 'caller', [ 'load( ''' [Gheader.GZheader.path_to_segs fn] ''', ''' vname ''');' ] );
      evalin( 'caller', [ varname '(:,' num2str(sc) ':' num2str(ec) ') = ' vname ';' ] );
      evalin( 'caller', [ ' clear ' vname ';' ] );
      
      
    end
    
  end
  
    


