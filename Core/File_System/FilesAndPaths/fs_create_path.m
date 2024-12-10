function [created, p] = fs_create_path( fs, fs_typ, nd, sno, parms ) 

  p = '';
  created = 0;

  if ( nargin < 3 ), return; end;
  if ( nargin < 4 ), sno = 0; end;
  if ( nargin < 5 ), parms = struct( 'empty', 1 ); end;

  tpl = constant_define( 'OUTPUT_FS', fs, fs_typ );
%  study_path = study_filesys_arch();
%   pth = ['tpl = ' study_filesys_arch() '.' fs ];
%   if ( ~isempty(fs_typ) )
%     pth = [pth '.' fs_typ ];
%   end;
% 
%   eval( [pth ';'] );

  if ( ~isempty(tpl) )
    tpl = strrep( tpl, '_#_', num2str(nd) );
    if ( sno > 0 ) 
      tpl = strrep( tpl, '_s_', num2str(sno, '%03d') );
    end;

    tpl = strrep( tpl, '{sep}', filesep );
    tpl = strrep( tpl, '{shape}', '' );

    str = '';
    if isfield( parms, 'method' ), str = parms.method; end;
    tpl = strrep( tpl, '{method}', [str filesep] );

    str = '';
    if isfield( parms, 'defaults' )
      if isfield( parms.defaults, 'component' ), str = num2str(parms.defaults.component, '%02d'); end;
    end;
    tpl = strrep( tpl, '_n_', str );

    str = '';
    if isfield( parms, 'model' ), str = parms.model; end;
    tpl = strrep( tpl, '{model}', str );

    str = '';
    if isfield( parms, 'mode' ), str = parms.mode; end;
    tpl = strrep( tpl, '{mode}', str );

    str = '';
    if isfield( parms, 'threshold' ), str = [ num2str(parms.threshold, '%02d') '_percent']; end;
    tpl = strrep( tpl, '{thr}', str );

    str = '';
    if isfield( parms, 'hindex' ), str = parms.hindex; end;
    tpl = strrep( tpl, '{hindex}', str );
    
    while  ~isempty( strfind( tpl, [filesep filesep] ) )
      tpl = strrep( tpl, [filesep filesep], filesep );
    end
    if char(tpl(end)) ~= filesep,  tpl = [tpl filesep]; end;
    
  end;

  x = exist( tpl, 'dir' );
  if ( x ~= 7 )  % the directory does not exist
    eval( [' mkdir ''' tpl ''';' ] );
    x = exist( tpl, 'dir' );
  end;

  created = x == 7;
  if created,  p = tpl; end;

