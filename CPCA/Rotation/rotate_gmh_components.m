function ab = rotate_gmh_components( funcs, process, this_model, log_fid, pop ) 
global Zheader scan_information 
  load( Zheader.Limits.path );

  [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );
  Hheader.model(Hheader.Hindex).path_to_segs.GMH = H_Segments;

  noParms = struct( 'model', 'H', 'mode', 'GMH', 'htype', this_model, 'hindex',  H_ID );

  ab = 0;
  if nargin < 5  pop = []; end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

    for ( comp_idx = 1:size(process.components, 2) )

      nd = process.components(comp_idx);
      if nd > 0 
        component_directory = fs_path( 'unrotated', 'output', nd, 0, noParms );

        % -----------------------------------------------------------
        % is there a processed .mat file for the non_rotated solution
        % -----------------------------------------------------------
        in_file = fs_filename( 'mat', this_model, 'unrotated', [] );
        in_file = [component_directory in_file];
        if ( exist( in_file, 'file' ) )

          % ----------------------------------
          % --- multiple rotations ---
          % ----------------------------------
          for idx = 1:size(process.rotation, 1)

            this_rotation = process.rotation(idx);
            this_rotation.model = 'H';
            this_rotation.fs = 'rotated';
            this_rotation.htype = this_model;
            this_rotation.mode = 'GMH';
            this_rotation.hindex = H_ID;
            
            Txt = [this_rotation.method ' rotation of ' num2str(nd) ' components from ' this_rotation.mode ':' this_rotation.htype];
            print_title( Txt, log_fid );

            if ~isempty(pop)
              pop.setProcess( ['GMH::' this_model ' Rotation'] );
              pop.setMessage( [this_rotation.method ' rotation : ' num2str(nd) ' components' ] );
            end;
            
            image_path = fs_path( 'rotated', 'images', nd, 0, this_rotation  );

            str = [ '--- ' process.rotation(idx).method ];
            if ( process.rotation(idx).defaults.oblique )  str = [ str ' oblique' ];  else str = [ str ' orthogonal' ];   end;
            str = [ str ' iter: ' num2str(process.rotation(idx).defaults.iterations) ];
            nm = sprintf( '%.2f', process.rotation(idx).defaults.power );
            str = [ str ' power: ' nm ];
            nm = sprintf( '%.2f', process.rotation(idx).defaults.gamma );
            str = [ str ' gamma: ' nm ' ---' ];
            fnm = fs_filename( 'mat', this_model, this_rotation.method, this_rotation.defaults );
            str2 = sprintf( '%s\n--- %s ---', str, fnm );
            print_title( str2, log_fid );

            if strcmp( this_rotation.htype, 'GnotH' )
              ab = rotate_components( funcs, this_rotation, nd, log_fid, pop );
              clear rotate_components
            else
              ab = rotate_h_components( funcs, this_rotation, nd, log_fid, pop );
              clear rotate_h_components
            end;
            
            if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(pop); funcs.memory_stats(); end;

            if ( ab == 0 )
              pop.hide();
              return;
            end;

            rstyle = '';
            rs = '';
            if ( process.rotation(idx).defaults.oblique )
              rstyle = '_oblique';
            else
              rstyle = '_orthogonal';
            end
            rs = rstyle(2:end);

            dt = date;
            rot = ['Rotate ' num2str(nd) ' components' ];
            meth = ['Method: ' process.rotation(idx).method ' ' rs ];
            src = [ ' from: ' pwd '/' in_file ];

            ofn = fs_filename( 'mat', this_model, this_rotation.method, this_rotation.defaults );
            out_file = ['Store: ' component_directory ofn ];

            img_dir = '';
            images_done = '';


            % -----------------------------------------------------------
            % Create images for rotated solution
            % -----------------------------------------------------------
            this_rotation.hindex = H_ID;
            component_directory = fs_path( 'rotated', 'output', nd, 0, this_rotation );

            mat_file = fs_filename( 'mat', this_rotation.htype, this_rotation.method, this_rotation.defaults );
            mat_file = [component_directory mat_file];

            if ( exist( mat_file, 'file' ) )

              if ~isempty(pop)
                pop.setIterations( nd * max(scan_information.frequencies, 1), pop.PRIMARY );
              end; 

              h_images_rotated( funcs, this_rotation, nd, log_fid, pop );
              clear h_images_rotated


              load_file = fs_filename( 'loadings', this_model, process.rotation(idx).method, process.rotation(idx).defaults );
              image_dir = fs_path( 'rotated', 'images', nd, 0, this_rotation  );

              input_file = [image_dir load_file ];


%              if ~scan_information.isMulFreq	% --- bypass cluster data on meg data for now
%                if ( exist( input_file, 'file' ) )
%                  eval( [ 'load( ''' Zheader.Model.path ''', ''Gheader'')' ] );
%                  write_c_betas_clusters( this_rotation, Gheader, nd )
%                end;
%              end;

              dt = date;
              img_dir = [ Zheader.Z_Directory 'Component_Images' ];
              images_done = 'Images created for rotated components';

            end;

            write_log( dt, rot, meth, src, out_file, images_done, img_dir );

          end;  % --- each rotation index ---

          funcs.memory_stats();

        end;  % --- non rotated input file exists ---
      end;  % --- valid number of components ---

    end;  % --- each component index ---

