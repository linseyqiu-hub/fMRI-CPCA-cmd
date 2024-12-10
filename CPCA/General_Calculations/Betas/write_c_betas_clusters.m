function write_c_betas_clusters( rotation_params, Gheader, nd, thresh )
% produce output of mean and median betas per cluster

global Zheader scan_information 

  if ( nargin < 4 )  thresh = 500; end;

  if isempty( rotation_params )
    rotation_params.method = 'unrotated';
    rotation_params.defaults = struct( 'empty', 1 );
    rotation_params.fs = 'unrotated';
%  else
%    rotation_params.fs = 'rotated';
  end;

  rotation_params.nd = nd;

  if ~isfield( rotation_params, 'model' )
    rotation_params.model = 'G';
  else
    if isempty(rotation_params.model)
      rotation_params.model = 'G';
    end;
  end;

  p = fs_path( rotation_params.fs, 'output', nd, 0, rotation_params );
  v = fs_filename( 'mat', rotation_params.model(1), rotation_params.method, rotation_params.defaults );

  i = fs_path( rotation_params.fs, 'images', nd, 0, rotation_params );
  m = fs_filename( 'loadings', rotation_params.model(1), rotation_params.method, rotation_params.defaults );

  evalc( ['load( ''' i m ''', ''MNI'' )'] );

  nconds = Gheader.conditions;
  nbins = Gheader.bins;

  % ---------------------------------------------------------
  % --- as of V 4.0 C matrix saved as C in GC.mat,        ---
  % --- previously B in GB.mat                            ---
  % ---------------------------------------------------------
   
  eval( ['load( ''' Gheader.GZheader.path_to_segs 'GC.mat'', ''C'');'] );

  % -----------------------------------
  % betas - pos/neg voxels for component flip checking
  % -----------------------------------

  comp_betas = struct( 'component', [] );

  if ( rotation_params.model == 'G' )
    evalc( ['load( ''' p v ''', ''VR'', ''AR'', ''ep*'' )'] );
  else
    evalc( ['load( ''' p v ''', ''AR'', ''ep'' )'] );
    VR = AR;
  end;

  for FrequencyNo = 1:scan_information.frequencies
    start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
    end_col = start_col + Zheader.total_columns - 1;
    ftag = frequency_tag(FrequencyNo) ;

    thisVR = VR(start_col:end_col,:);

    for comp = 1:nd

      rotation_params.defaults.component = comp;

      % ------------------------------------------------
      % function may be called by a component flip
      % ensure all files in component directory are removed to avoid confusion
      % ------------------------------------------------
      cp = fs_path( rotation_params.fs, 'cluster_txt', nd, 0, rotation_params );
      eval( ['delete ' cp '*;'] );

      component = struct( 'avg', [], 'med', [] );

      threshold = [];
      eval( ['threshold = ep' ftag '(comp).percentiles( Zheader.pct_threshold ).threshold;' ] );	% top 5% of component weights
      eval( ['voxels = ep' ftag '(comp).percentiles( Zheader.pct_threshold ).voxels;' ] );

      abs_cluster_no = 0;

      if isfield( MNI, 'component' )		
        threshhold_max = size(Zheader.pct_value, 2 );
      else
        threshhold_max = 1;
      end;

      for thresh_index = 1:threshhold_max

        if isfield( MNI, 'component' )		
          thisMNI = MNI.component(comp).threshold( thresh_index );
          rotation_params.threshold = Zheader.pct_value( thresh_index);
        else
          thisMNI = MNI((((FrequencyNo-1)*nd)+comp));
        end;

        if size(thisMNI.pos, 1 ) > 0

          abs_cluster_no = 0;

          rotation_params.defaults.posneg = 'Positive';

          for clno = 1:size(thisMNI.pos, 1 )

            if ( thisMNI.pos(clno).mm3 >= thresh )

              abs_cluster_no = abs_cluster_no + 1;
              rotation_params.defaults.cluster = sprintf('%03d', abs_cluster_no);

              % ------------------------------------------------
              % load the single cluster component
              % ------------------------------------------------
              vr_cmp = thisVR(:,comp);

              % ------------------------------------------------
              % are there positive clusters
              % ------------------------------------------------
              vr_cmp = vr_cmp(thisMNI.pos(clno).Masks.Zindex);
              x = find( vr_cmp >= threshold );

              vr_comp = vr_cmp(x);
              C_comp = C(:,x);

              if ( size(x,1) > 1 )		% ensure that there are loadings 

                avg_conditions = [];
                med_conditions = [];

                for s=1:Zheader.num_subjects

                  if s == 1 
                    sp = 0;
                  else
                    sp = ( sum(Gheader.subject_encoded(1:s-1) )*Gheader.bins );
                  end;

                  subject_avg_conditions = [];
                  subject_med_conditions = [];
                  for cond = 1:nconds

                    if any ( Zheader.conditions.subject(s).Run(1).conditions == cond )

                      thispos = find( Zheader.conditions.subject(s).Run(1).conditions == cond );
                      row=sp + ((thispos-1) * nbins) + 1;
                      r2 = row + nbins - 1;

                      C_avg = mean(C_comp(row:r2,:)');
                      C_med = median(C_comp(row:r2,:)');

                      subject_avg_conditions = [subject_avg_conditions C_avg];
                      subject_med_conditions = [subject_med_conditions C_med];
              
                    else   % --- condition non encoded pad out the array 
                      for ii = 1:nbins;
                        subject_avg_conditions = [subject_avg_conditions constant_define( 'NON_ENCODED_COND_FLAG' ) ];
                        subject_med_conditions = [subject_med_conditions constant_define( 'NON_ENCODED_COND_FLAG' ) ];
                      end;
                    end;

                  end  % --- each condition

                  avg_conditions = [avg_conditions; subject_avg_conditions ];
                  med_conditions = [med_conditions; subject_med_conditions ];

                end;  % --- each subject	

                write_this_info(rotation_params, avg_conditions, med_conditions, thisMNI.pos(clno), FrequencyNo );

              end;  % --- VR has loadings above 5% threshold

            end; % --- positive cluster over 500 cubic mm

          end; % --- each positive cluster

        end; % --- positive clusters exist


        if size(thisMNI.neg, 1 ) > 0
    
          abs_cluster_no = 0;

          rotation_params.defaults.posneg = 'Negative';

          for clno = 1:size(thisMNI.neg, 1 )

            if ( thisMNI.neg(clno).mm3 >= thresh )

              abs_cluster_no = abs_cluster_no + 1;
              rotation_params.defaults.cluster = sprintf('%03d', abs_cluster_no);

              % ------------------------------------------------
              % load the single cluster component
              % ------------------------------------------------
              vr_cmp = thisVR(:,comp);

              % ------------------------------------------------
              % are there negative clusters
              % ------------------------------------------------
              vr_cmp = vr_cmp(thisMNI.neg(clno).Masks.Zindex);
              x = find( vr_cmp <= ( threshold * -1 ) );
    
              vr_comp = vr_cmp(x);
              C_comp = C(:,x);

              if ( size(x,1) > 1 )		% ensure that there are loadings 

                avg_conditions = [];
                med_conditions = [];

                for s=1:Zheader.num_subjects

                  if s == 1 
                    sp = 0;
                  else
                    sp = ( sum(Gheader.subject_encoded(1:s-1) )*Gheader.bins );
                  end;

                 subject_avg_conditions = [];
                  subject_med_conditions = [];
                  for cond = 1:nconds
                    if any ( Zheader.conditions.subject(s).Run(1).conditions == cond )

                      thispos = find( Zheader.conditions.subject(s).Run(1).conditions == cond );
                      row=sp + ((thispos-1) * nbins) + 1;
                      r2 = row + nbins - 1;


                      C_avg = mean(C_comp(row:r2,:)');
                      C_med = median(C_comp(row:r2,:)');

                      subject_avg_conditions = [subject_avg_conditions C_avg];
                      subject_med_conditions = [subject_med_conditions C_med];

                    else   % --- condition non encoded pad out the array 
                      for ii = 1:nbins;
                        subject_avg_conditions = [subject_avg_conditions constant_define( 'NON_ENCODED_COND_FLAG' ) ];
                        subject_med_conditions = [subject_med_conditions constant_define( 'NON_ENCODED_COND_FLAG' ) ];
                      end;
                    end;

                  end  % --- each condition

                  avg_conditions = [avg_conditions; subject_avg_conditions ];
                  med_conditions = [med_conditions; subject_med_conditions ];

                end;  % --- each subject	

              end;  % --- VR has loadings above 5% threshold
    
              write_this_info(rotation_params, avg_conditions, med_conditions, thisMNI.neg(clno), FrequencyNo );
    
            end; % --- negative cluster over 500 cubic mm
    
          end; % --- each negative cluster

        end; % --- negative clusters exist
      end;  % --- each threshold

    end;  % --- each component
  end;  % --- each frequency range


function write_this_info(rotation_params, avg_conditions, med_conditions, mni, FrequencyNo )
global Zheader scan_information 

%  if ( length(char(scan_information.freq_names(FrequencyNo))) > 0 )  ftag = [char(scan_information.freq_names(FrequencyNo)) '_']; else ftag = ''; end;
  ftag = frequency_tag( FrequencyNo );
  
  [ok, p] = fs_create_path( rotation_params.fs, 'cluster_mean', rotation_params.nd, 0, rotation_params );
  [ok, q] = fs_create_path( rotation_params.fs, 'cluster_median', rotation_params.nd, 0, rotation_params );
  
  of = sprintf( '%s_%s_MNI_%d_x_%d_x%d_MM3_%d%s_mean.txt', rotation_params.defaults.posneg, rotation_params.defaults.cluster, mni.peak.mni(1), mni.peak.mni(2), mni.peak.mni(3), mni.mm3, ftag );
  mean_output = [p of];

  of = sprintf( '%s_%s_MNI_%d_x_%d_x%d_MM3_%d%s_median.txt', rotation_params.defaults.posneg, rotation_params.defaults.cluster, mni.peak.mni(1), mni.peak.mni(2), mni.peak.mni(3), mni.mm3, ftag );
  median_output = [q of];

  mean_fid = fopen( mean_output, 'w' );
  median_fid = fopen( median_output, 'w' );

  fprintf(  mean_fid, 'created: %s - cpca %s\n', date, constant_define( 'REVISION_NUMBER' ) );
  fprintf(  mean_fid, 'original location: %s\n', p );
  fprintf(  mean_fid, '------------------------------------------\n' );

  fprintf(  median_fid, 'created: %s - cpca %s\n', date, constant_define( 'REVISION_NUMBER' ) );
  fprintf(  median_fid, 'original location: %s\n', p );
  fprintf(  median_fid, '------------------------------------------\n' );

  hdr = sprintf( 'Voxels\t  MM^3\tPeak MNI   Value' );
  str = sprintf( '%5d\t%6d\t[%d %d %d] %.04f', mni.voxels, mni.mm3, mni.peak.mni(1), mni.peak.mni(2), mni.peak.mni(3), mni.peak.value );
  fprintf(  mean_fid, '%s\n%s\n', hdr, str );
  fprintf(median_fid, '%s\n%s\n', hdr, str );

  fprintf(  mean_fid, '\n' );
  fprintf(  median_fid, '\n' );

  for s = 1:size( avg_conditions, 1 )
    fprintf(    mean_fid, 'S%d', s );
    fprintf(  median_fid, 'S%d', s );

    if ( size( scan_information.SubjectID, 2 ) >= s )
      fprintf(    mean_fid, '\t%s', char(scan_information.SubjectID(s)) );
      fprintf(  median_fid, '\t%s', char(scan_information.SubjectID(s)) );
    end;

    for ii = 1:size( avg_conditions, 2 )

      if avg_conditions(s,ii) == constant_define( 'NON_ENCODED_COND_FLAG' )
        fprintf(    mean_fid, '\t --- ');
      else
        fprintf(    mean_fid, ['\t' constant_define( 'PREFERENCES', 'precision.log', '%.2f' )], avg_conditions(s,ii) );
      end;

      if med_conditions(s,ii) == constant_define( 'NON_ENCODED_COND_FLAG' )
        fprintf(  median_fid, '\t --- ');
      else
        fprintf(  median_fid, ['\t' constant_define( 'PREFERENCES', 'precision.log', '%.2f' )], med_conditions(s,ii) );
      end;

    end;
 
    fprintf(    mean_fid, '\n' );
    fprintf(  median_fid, '\n' );
  end;

  fclose(   mean_fid );
  fclose( median_fid );


