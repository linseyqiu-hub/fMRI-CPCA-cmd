function create_residual_as_Images(model, pop)
global Zheader scan_information process_information

  if nargin < 1
    model = 'G';
  end;
  if ( nargin < 2 )  pop = [];  end;
  if ~strcmp( class(pop), 'cpca_progress' )
    pop = []; 
  end

  var_prefix = 'E';
  dest = 'Residual_Images';
  if ~exist( dest, 'dir' )
    mkdir Residual_Images
  end
  
  if ~isempty(pop)
    pop.setWindowTitle( 'Residual Images' );
    pop.setMessages( 'Creating Residual images', '', '' );
    iters = iteration_rule( 'Iterations', 'Residual Images', {'primary'} );
    pop.setIterations( iters.primary, pop.PRIMARY );    
    pop.show();
  end

  load( Zheader.Model.path, 'Gheader' );
  
  for subjectNo = 1:Zheader.num_subjects

    grp = '';
    run = '';
    sbj = subject_id( subjectNo );
    ftag = '';

    if ~isempty(pop)
      iters = iteration_rule( 'Iterations', 'Residual Images', {'secondary'}, ...
                 struct( 'Subj', subjectNo ) );
      pop.setIterations( iters.secondary, pop.SECONDARY );    
      pop.setParticipant( subjectNo, Zheader.num_subjects, sbj );
    end
    
    for FrequencyNo = 1:max(scan_information.frequencies, 1)
      ftag = frequency_tag(FrequencyNo) ;
      fdir = strrep( ftag, '_', '' );

      if ~isempty(pop)
        if scan_information.isMulFreq
          pop.setFrequency( FrequencyNo, scan_information.frequencies, fdir );
        end
      end
      
      dest = 'Residual_Images';

      for RunNo = 1:size( Zheader.timeseries.subject(subjectNo).run, 1 )

        if isEncodedRun( subjectNo, RunNo ) 
          if ~isempty(pop)
            pop.setRun( RunNo, size( Zheader.timeseries.subject(subjectNo).run, 1 ) );
          end
        

          GC = load_subject_GC_run( Gheader, subjectNo, RunNo, ftag, model );
          Z = load_subject_run_Z( subjectNo, RunNo, ftag );
          E = Z - GC;

          clear GC Z

          scans = size(E, 1);

          if ( Zheader.num_runs > 1 )  run = ['_run' num2str(RunNo)];  end

          str = scan_information.scandir_format;
          str = strrep( str, '{run_dir}', run );
          str = strrep( str, '{group_dir}', grp );
          str = strrep( str, '{frequency_dir}', fdir );
          str = strrep( str, '{subject_dir}', sbj );

          output_path = [ dest filesep str filesep ];
          eval( ['mkdir ' output_path ] );
        
          if ~isempty(pop)
            pop.setIterations( scans );
          end
        
          for scanidx = 1:scans

            if ~isempty(pop)
              pop.increment();
            end
          
            scanno = sprintf( '_%04d', scanidx );
            filename = [ 'residual_' char(scan_information.SubjectID(subjectNo)) run ftag scanno '.img' ] ;

            img = scan_information.mask; 
            img.image = zeros( prod( img.vol.dim ), 1);	% --- storage area for finale written image --
            eval( [ 'img.image( img.ind ) = E(scanidx,:);' ] );	% --- placing data vector into proper positions of mask ---
            img.image = reshape( img.image ,img.vol.dim);	% --- and reshaping the result to the mask volume dimensions ---

            dtyp = cpca_data_type( 'double' ); 
            src_prec = dtyp.analyse; 
            if isempty( src_prec ) 
              src_prec = dtyp.nifti; 
            end % --= 
            if isBigendian()  en = 'LE'; else en = 'BE'; end 
            dtype = [src_prec '-' en]; 

            img.vol.dt = [dtyp.conversion isBigendian()];		% --- we default data type to signed double (float 64 )
            img.header.datatype = dtyp.conversion; 
            img.header.bitpix = dtyp.bits; 
            img.vol.fname = [output_path filename]; 

            if isfield( img.header, 'scl_slope') 
              img.header.scl_slope = 1; 
            end 

            img.vol.pinfo(1) = 1; 
            img.vol.private.dat.dtype = dtype; 

            err = cpca_write_vols( img ); 
            if ( ~isempty( err ) )
              errmessage( 'String', err );
              return;
            end

          end
    
      end  % --- run is encoded
      end  % --- each run

    end  % --- each frequency

  end  % --- each subject
  
  if ~isempty(pop)
    pop.hide();
  end
  
  if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
    cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
    eval( cmd );
  end
 
