function [T, PR, VR, UR] = compute_facs_cmd(Zheader, P, U, V,nd,tsum,nr,nc, Gheader, rotation_specs, GAtyp )

% -------------------------------------------------
% notes:
%  GA used by rotations based on hrf 
%   hrfmax, procrustes
%
% as the size of G and potentially GA can be extreme, we replaced 
% the G/GA parameter with the G/GA header structure which is placed
% in the processed G/GA_values.mat file.
% -------------------------------------------------

% --- Primary Iterations
% --- N/A setPong(1)

  if nargin < 11,  GAtyp = '';  end

  T  = [];
  UR = [];
  VR = [];
  PR = [];
%  Cor = [];
  
  format compact

  shapes = [];

  ermsg = '';

  if (rotation_specs.defaults.normalize) normalize = 'on'; else normalize = 'off'; end
  reltol = sqrt(eps);

  Txt = sprintf( 'Rotating %d components from GZ (%s)',nd, rotation_specs.method );
 
  % -------------------------------------------------
  % make sure shapes are defined if required
  % -------------------------------------------------
  
  if ( rotation_specs.parameters.HRF )	

      if ~isempty( rotation_specs.defaults.hrf_file )
        eval( [ 'load( ''' rotation_specs.defaults.hrf_file ''', ''' rotation_specs.defaults.hrf_mat ''' )' ] );
        eval ( [ 'shapes = ' rotation_specs.defaults.hrf_mat ' ;' ] );
      end

      if isempty( shapes ) && isempty(rotation_specs.defaults.T_mat)
        disp('Unable to perform hrfmax rotation as there are no estimated HRF shapes to process with.');
        % disp( 'Unable to rotate', ermsg );
        return;
      end

      if ~isempty( shapes ) 
        % ensure shapes are proper size
        % -------------------------------------------------
%        iter = floor(size(P,1)/size(shapes,2));
%        if ( iter*size(shapes,2)~=size(P,1) )
        if ( size(shapes,2)~=Gheader.bins ) && strcmpi( rotation_specs.method, 'hrfmax' )
          disp('Unable to perform hrf based rotation as the given shapes are of the wrong dimension.');
          %show_message( 'Unable to rotate',ermsg );
          return;
        end
      end

%     else
%         
%       if isempty( rotation_specs.defaults.hrf_file )
%         ermsg = 'No target VR selected';
%         show_message( 'Unable to rotate',ermsg );
%         return;
%       else
%         eval( [ 'load( ''' rotation_specs.defaults.hrf_file ''', ''' rotation_specs.defaults.hrf_mat ''' )' ] );
%         eval ( [ 'shapes = ' rotation_specs.defaults.hrf_mat ' ;' ] );
%       end;
%         
%     end; 

  end


  % -------------------------------------------------
  % make sure iteration count is valid if required
  % -------------------------------------------------
  if ( rotation_specs.parameters.iterations )	
    if ( rotation_specs.defaults.iterations <= 0 )	
      disp('Unable to perform rotation as the number of iterations is zero (or less).');
      %show_message( 'Unable to rotate',ermsg );
      return;
    end
  end


  % -------------------------------------------------
  % removed: recomputation of loadings
  % -------------------------------------------------


  switch lower(rotation_specs.method)
  case 'hrfmax'
    
    % -------------------------------------------------
    % hrfmax by itself is an orthogonal rotation
    % -------------------------------------------------

    T = rotation_specs.defaults.T_mat; 
    if ( isempty( T ) )

      load_state = 0;
      if isfield( rotation_specs.parameters, 'load_state' )
        load_state = rotation_specs.parameters.load_state;
      end
      T = hrfmax(P, U, shapes, rotation_specs.defaults.iterations, load_state);
      if isempty(T)
        return;
      end
    end

    PR = P * inv(T');


    % -------------------------------------------------
    % --- preserve an unambiguous copy of the shapes used
    % -------------------------------------------------
    component_directory = fs_path( 'rotated', 'output', nd, 0, rotation_specs );
    shapes_file = [pwd filesep 'hrfmax_shapes_used.mat'];
    eval( ['save ''' shapes_file ''' shapes '] );

    % -------------------------------------------------
    % perform oblique rotation if requested
    % -------------------------------------------------
    if ( rotation_specs.defaults.oblique )

      B0=V*T; 
      Target = sign(B0) .* abs(B0) .^ rotation_specs.defaults.power; % keep it real, respect sign
 
      % -------------------------------------------------
      % Oblique rotation to target .. this will allow correlated components but keep the basic hrfmax structure
      % -------------------------------------------------
      [VR, T] = proc_todd( V, Target, 'oblique');
      PR = P*inv(T');


      % -------------------------------------------------
      % T VR and UR recomputed for oblique hrfmax
      % -------------------------------------------------

    else 
      % -------------------------------------------------
      % T and UR computed from orthogonal hrfmax - compute new VR
      % -------------------------------------------------
      VR = V*T;
    end

    % -------------------------------------------------
    % UR needs recomputing from either orthogonal or oblique
    % -------------------------------------------------
    UR = U*inv(T');



  case 'hrf-procrustes'

    if rotation_specs.defaults.oblique
      [ PR, T, Cor] = hrf_oblique_procrustes( P, shapes', rotation_specs, rotation_specs.defaults.apply_to_ur );
    else
      [ PR, T, Cor] = hrf_procrustes( P, shapes', rotation_specs, rotation_specs.defaults.apply_to_ur, GAtyp );
    end

    if ~isempty( PR )
      VR = V * T;
      UR = U*inv(T');
%      UR = apply_partitioned_to_matrix( Gheader, PR );
    end


  case 'procrustes'
    if  isempty( rotation_specs.defaults.hrf_file) || isempty( rotation_specs.defaults.hrf_mat)
      disp('Unable to perform rotation as the target VR is not specified.');
      %show_message( 'Unable to rotate',  ermsg );
      return;
    end

    rot_type = 'orthogonal';
    if rotation_specs.defaults.oblique
      rot_type = 'oblique';
    end
    
    targetVR = load( rotation_specs.defaults.hrf_file, rotation_specs.defaults.hrf_mat );
    eval( [ '[ VR, T] = procrustes( V, targetVR.' rotation_specs.defaults.hrf_mat ', rot_type );' ] );
      
    if ( isempty(T) )  return; end		% orthomax error exit point

    PR = P*inv(T');
    if ~strcmp( GAtyp, 'GAA' )
      UR = apply_partitioned_to_matrix( Gheader, PR, GAtyp );
    else
      UR = [];  
      for SubjectNo=1:Zheader.num_subjects
        load( [ 'GAAZsegs' filesep 'GAA_S' num2str(SubjectNo) ], 'GAA' );
        UR = [UR; GAA * PR];
      end    
    end
    

  otherwise

    % -------------------------------------------------
    % Create target matrix from orthomax (defaults to varimax) solution
    % -------------------------------------------------
    [VR, T] = orthomax(V, rotation_specs.defaults.gamma, normalize, reltol, rotation_specs.defaults.iterations);
    if ( isempty(T) )  return; end		% orthomax error exit point


    % -------------------------------------------------
    % Oblique rotation to target
    % -------------------------------------------------
    if ( rotation_specs.defaults.oblique == 1 )

      if ( rotation_specs.defaults.power > 1 )
        Target = sign(VR) .* abs(VR).^rotation_specs.defaults.power; 	% keep it real, respect sign
        VR = Target;
      end

      [VR, T] = proc_todd(V, VR, 'oblique' );
    end

    UR = U*inv(T');
    PR = P*inv(T');


  end


   
