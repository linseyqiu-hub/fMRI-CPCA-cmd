function p = fs_filename( typ, model, method, params )

  p = '';
  tpl = [];

  if ( nargin < 3 ), return; end;

  tpl = constant_define( 'OUTPUT_FT', typ);
%   study_path = study_filesys_arch();
%   pth = ['tpl = study_path.filetype.' typ ];
%   eval( [ pth ';' ] );

  if ( ~isempty(tpl) )
    tpl = strrep( tpl, '{model}', [model '_'] );
    tpl = strrep( tpl, '{method}', [method '_'] );
    tpl = strrep( tpl, '{rotation}', [method '_'] );

    str = '';
    if strcmp( method, 'procrustes' )  % --- uses UR flag as single shape flag
      if isfield( params, 'apply_to_ur' )
        if ( params.apply_to_ur == 1 )
          str = 'single_shape_';
        end;
      end;
    end;
    tpl = strrep( tpl, '{shape}', str );

    if ( ~isempty( params ) )

      str = '';
      if (isfield( params, 'iterations' ) && strcmp(method,'hrfmax')), str = ['i' num2str(params.iterations) '_' ]; end;
      tpl = strrep( tpl, '{iterations}', str );

      str = '';
      if isfield( params, 'var' ), str = [ params.var '_']; end;
      tpl = strrep( tpl, '{var}', str );

      str = '';
      if isfield( params, 'component' )
        if params.component > 0,       str = ['C' num2str(params.component) '_' ]; end;
      end;
      tpl = strrep( tpl, '{component}', str );

      str = '';
      if isfield( params, 'subject' ), str = ['Subject_' num2str(params.subject) '_' ]; end;
      tpl = strrep( tpl, '{subject}', str );

      str = '';
      if isfield( params, 'cluster' )
        if ischar(params.cluster), str = params.cluster; else str = [ 'Cluster_' num2str(params.cluster) '_']; end;
      end;
      tpl = strrep( tpl, '{cluster}', str );

      str = '';
      if isfield( params, 'posneg' ), str = params.posneg; end;
      tpl = strrep( tpl, '{posneg}', str );


      str = '';
      if isfield( params, 'reg' )
%        regTags = [ {'_Gray'}, {'_White'} ];
        if params.reg > 0,       str = [strrep(constant_define( 'REGISTRATION_TYPE', params.reg ), ' ', '_' ) '_'] ; end;
      end;
      tpl = strrep( tpl, '{matter}', str );

      if isfield( params, 'text' )
        str = ['_' params.text '.'];
        tpl = strrep( tpl, '.mat', [str 'mat'] );
        tpl = strrep( tpl, '.txt', [str 'txt'] );
        tpl = strrep( tpl, '.img', [str 'img'] );
        tpl = strrep( tpl, '.png', [str 'png'] );
      end;

    else
      str = '';
      tpl = strrep( tpl, '{iterations}', str );
      tpl = strrep( tpl, '{power}', str );
      tpl = strrep( tpl, '{gamma}', str );
      tpl = strrep( tpl, '{style}', str );
      tpl = strrep( tpl, '{var}', str );
      tpl = strrep( tpl, '{component}', str );
      tpl = strrep( tpl, '{subject}', str );
      tpl = strrep( tpl, '{cluster}', str );
      tpl = strrep( tpl, '{posneg}', str );
      tpl = strrep( tpl, '_n_', str );
      tpl = strrep( tpl, '_s_', str );
      tpl = strrep( tpl, '_c_', str );
      tpl = strrep( tpl, '{matter}', str );     % --- white gray matter separation

    end;

    % --- there is potential for double underscores within file names - remove
    tpl = strrep( tpl, '__', '_' );
    tpl = strrep( tpl, '_.', '.' );
    p = tpl;

  end;
