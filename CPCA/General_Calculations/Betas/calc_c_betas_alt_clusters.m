function comp_betas = calc_c_betas_alt_clusters( rotation_params, Gheader, nd, thresh )
global Zheader scan_information

  % ---------------------------------------------------------
  % --- returns a structue containing
  % --- components (1-n)
  % ---    label           tabbed top label 	1_pos_1		1_pos_2 	etc...
  % ---    mni             tabbed mni display   24_-22_17  	32_12_-71 	etc...
  % ---    avg		   the mean betas for each cluster
  % ---    med		   the median betas for each cluster
  % ---------------------------------------------------------

  if ( nargin < 4 )  thresh = 500; end;

  noParms = struct( 'empty', 1 );
  p = fs_path( 'subject_vr', 'output', 5, 0, rotation_params.method );
  v = fs_filename( 'alt_vr', 'G', rotation_params.method, rotation_params.defaults );

  i = fs_path( 'rotated', 'images', 5, 0, rotation_params.method );
  m = fs_filename( 'loadings', 'G', rotation_params.method, rotation_params.defaults );

  evalc( ['load( ''' i m ''', ''MNI'' )'] );

  nconds = Gheader.conditions;

  % ---------------------------------------------------------
  % --- as of V 4.0 C matrix saved as C in GC.mat,        ---
  % --- previously B in GB.mat                            ---
  % ---------------------------------------------------------
  gc_file = [ Gheader.GZheader.path_to_segs 'GC.mat' ];
  c_matrix = 'C';

  x = exist( gc_file, 'file' );
  if x ~= 2 				
    gc_file = [ Gheader.GZheader.path_to_segs 'BG.mat' ];
    c_matrix = 'B';
  end;

  eval( ['load( ''' gc_file ''' )'] );

  % -----------------------------------
  % betas - pos/neg voxels for component flip checking
  % -----------------------------------

  comp_betas = struct( 'component', [] );

  for comp = 1:nd

    component = struct( 'avg', [], 'med', [], 'label', [], 'mni', [] );
    component.label = 'S#';
    component.mni = '';

    for subjectNo = 1:Zheader.num_subjects

      cluster_avg = [];
      cluster_med = [];

      clear VR ep
      
      VR = [];
      ep = [];

      % -----------------------------------
      % load in the subject alt VR and extremes pos/neg for threshold
      % -----------------------------------
      evalc( ['load( ''' p v ''', ''alt_VR_S' num2str(subjectNo) ''', ''ep_' num2str(subjectNo) ''' )'] );
      eval( ['VR = alt_VR_S' num2str(subjectNo) ';' ] );
      eval( ['ep = ep_' num2str(subjectNo) ';' ] );
      eval( ['clear alt_VR_S' num2str(subjectNo) ' ep_' num2str(subjectNo) ] );

      threshold = ep(comp).percentiles(  constant_define( 'PREFERENCES', 'threshold.default', 3 ) ).threshold;	% top 5% of component weights
      voxels = ep(comp).percentiles(  constant_define( 'PREFERENCES', 'threshold.default', 3 ) ).voxels;

      if size(MNI(comp).pos, 1 ) > 0

        for clno = 1:size(MNI(comp).pos, 1 )

          if ( MNI(comp).pos(clno).mm3 >= thresh )

            if ( subjectNo == 1 )
              hlabel = sprintf( '\t%d_pos_%d',comp, clno );
              component.label = [component.label hlabel];
              hpos = sprintf( '\t%d_%d_%d', ...
                MNI(comp).pos(clno).peak.mni(1), ...
                MNI(comp).pos(clno).peak.mni(2), ...
                MNI(comp).pos(clno).peak.mni(3) );
              component.mni = [component.mni hpos];
            end;

            % ------------------------------------------------
            % load the single cluster component
            % ------------------------------------------------
            vr_cmp = VR(comp,:)';

            % ------------------------------------------------
            % are there positive clusters
            % ------------------------------------------------
            vr_cmp = vr_cmp(MNI(comp).pos(clno).Masks.Zindex);
            x = find( vr_cmp > threshold );

            vr_comp = vr_cmp(x);
            eval( ['  C_comp = ' c_matrix '(:,x);' ] );

                                                % ------------------------------------------------
            if ( size(x,1) > 1 )		% ensure that there are loadings above threshold
                                                % ------------------------------------------------
              avg_conditions = [];
              med_conditions = [];

              for cond = 1:nconds
                C_avg = [];

                for timebin=1:Gheader.bins
            
                  C_temp=[];
                  row=(cond-1)*Gheader.bins+timebin;
                  eval( [ 'C_temp = [C_temp; C_comp(' int2str(row) ',:)];' ] );
                  C_avg(timebin,:)=mean(C_temp);
                  C_med(timebin,:)=median(C_temp);
             
                  beta_avg_timecourses{cond}.avg_of_voxels=transpose(mean(C_avg'));
                  beta_avg_timecourses{cond}.med_of_voxels=transpose(median(C_avg'));
                                                % ------------------------------------------------
               end;                             % --- each time bin
                                                % ------------------------------------------------
                avg_conditions = [avg_conditions beta_avg_timecourses{cond}.avg_of_voxels ];
                med_conditions = [med_conditions beta_avg_timecourses{cond}.med_of_voxels ];
                                                % ------------------------------------------------
              end;                              % --- each condition
                                                % ------------------------------------------------
              cluster_avg = [cluster_avg mean(avg_conditions) ];
              cluster_med = [cluster_med median(med_conditions) ];
                                                % ------------------------------------------------
            else				% if no loadings above threshold, enter 0 for that column
                                                % ------------------------------------------------
              cluster_avg = [cluster_avg 0 ];
              cluster_med = [cluster_med 0 ];

            end;  % --- loadings above threshold      

          end; % --- positive cluster over 500 cubic mm

        end; % --- each positive cluster

      end; % --- positive clusters exist


      % ------------------------------------------------
      % as above for negative clusters
      % ------------------------------------------------
      if size(MNI(comp).neg, 1 ) > 0

        for clno = 1:size(MNI(comp).neg, 1 )

          if ( MNI(comp).neg(clno).mm3 > thresh )

            if ( subjectNo == 1 )
              hlabel = sprintf( '\t%d_neg_%d',comp, clno );
              component.label = [component.label hlabel];
              hpos = sprintf( '\t%d_%d_%d', ...
                MNI(comp).neg(clno).peak.mni(1), ...
                MNI(comp).neg(clno).peak.mni(2), ...
                MNI(comp).neg(clno).peak.mni(3) );
              component.mni = [component.mni hpos];
            end;

            % ------------------------------------------------
            % load the single cluster component
            % ------------------------------------------------
            vr_cmp = VR(comp,:)';

            % are there positive clusters
            vr_cmp = vr_cmp(MNI(comp).neg(clno).Masks.Zindex);
            x = find( vr_cmp < (threshold * -1) );

            vr_comp = vr_cmp(x);
            eval( ['  C_comp = ' c_matrix '(:,x);' ] );

            if ( size(x,1) > 1 )		% ensure that there are loadings above threshold

              avg_conditions = [];
              med_conditions = [];

              for cond = 1:nconds
                C_avg = [];

                for timebin=1:Gheader.bins
            
                  C_temp=[];
                  row=(cond-1)*Gheader.bins+timebin;
                  eval( [ 'C_temp = [C_temp; C_comp(' int2str(row) ',:)];' ] );
                  C_avg(timebin,:)=mean(C_temp);
                  C_med(timebin,:)=median(C_temp);
             
                  beta_avg_timecourses{cond}.avg_of_voxels=transpose(mean(C_avg'));
                  beta_avg_timecourses{cond}.med_of_voxels=transpose(median(C_avg'));

                end;  % --- each time bin

                avg_conditions = [avg_conditions beta_avg_timecourses{cond}.avg_of_voxels ];
                med_conditions = [med_conditions beta_avg_timecourses{cond}.med_of_voxels ];
              end;  % each condition

              cluster_avg = [cluster_avg mean(avg_conditions) ];
              cluster_med = [cluster_med median(med_conditions) ];

            else
              cluster_avg = [cluster_avg 0 ];
              cluster_med = [cluster_med 0 ];

            end;  % --- loadings above threshold 

          end; % --- positive cluster over 500 cubic mm

        end; % --- each positive cluster

      end; % --- positive clusters exist

      component.avg = [component.avg; cluster_avg];    
      component.med = [component.med; cluster_med];    

    end;  % --- each subject

    comp_betas.component = [comp_betas.component; component];

  end; % --- each component




