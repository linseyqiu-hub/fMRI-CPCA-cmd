function retrieve_subject_C_cmd( Zheader, SubjectNo, ftag, varname, model )

% -- Basic C subject retrieval - single frequency only for Multi freq data set
% --- for full multi frrquenct subject data use retrieve_full_subject_V  ( TBD )

  if nargin < 4
    varname = 'C';
  end
  if nargin < 3
    ftag = '';
  end
  if nargin < 5
    model = 'G';
  end

  Gpath = '';
  if ~isempty(Zheader.Model.path)
      load( Zheader.Model.path, 'Gheader' );
  else
      disp('Gheader.mat does not exist!');
      return
  end
  if ~strcmp( model, 'G' ) & ~strcmp( model, 'ROI' )
    load( Zheader.Contrast.path );
    eval( [ 'Gpath = Aheader.model( Aheader.Aindex).path_to_' model ';' ] );
  else
    eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );
  end
  
  evalin( 'caller', [ varname ' = [];' ] );
  fn = [ 'GC_S' num2str(SubjectNo) ftag '.mat'];
  vname = [ 'C_S' num2str(SubjectNo) ftag ];
 
  
  if ~isempty( ftag )
    n = matfile_vars( Gpath, fn, vname );
    if isempty(n)
      GCName = [ Gpath 'GC_S' num2str(SubjectNo) '.mat'];
      vname = [ 'C_S' num2str(SubjectNo) ];
    end
  end

  n = matfile_vars( Gpath, fn, vname );
  if ~isempty(n)

    x = n(1).sz_x;
    y = n(1).sz_y;
        
    evalin( 'caller', [ varname ' = zeros(' num2str(x) ',' num2str(y) ');' ] );
    evalin( 'caller', [ 'load( ''' [Gpath fn] ''', ''' vname ''');' ] );
    evalin( 'caller', [ varname ' = ' vname ';' ] );
    evalin( 'caller', [ ' clear ' vname ';' ] );
      
  end
  
    
%   eval ( [ 'load( GCName, ''C_S' num2str(SubjectNo) ftag ''');'] );
%   eval ( [ 'C = C_S' num2str(SubjectNo) ftag ';' ] );
% 
%   clear C_S*;
% 
%end


