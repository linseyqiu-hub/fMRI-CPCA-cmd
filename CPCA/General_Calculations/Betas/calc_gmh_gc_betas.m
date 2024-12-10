function betas = calc_gmh_gc_betas(Zheader, scan_information, fn, Gheader, Hheader, pos )

  if ( nargin < 6 ) pos = 0; end	% --- send pos = 1 to calculate positive values ---


  % --= 
  % --= load mat_fil VR ep
  evalc( ['load( ''' fn ''', ''VR'', ''ep'' )'] );
  nconds = Gheader.conditions; % --= 
  nbins = Gheader.bins; % --= 
  ncomps = size(VR,2); % --= 
  % --= 
  bin_start = 3;	% --= % cut off the first 2 bins in beta calcs 
			% to restore full bin length, set this var to 1 
  % ---------------------------------------------------------
  % --- as of V 4.0 C matrix saved as C in GC.mat,        ---
  % --- previously B in GB.mat                            ---
  % ---------------------------------------------------------
  
  [H_ID H_Segments] = H_path_spec( Hheader, 'GMH' );

  
  % --= % -----------------------------------
  % --= % betas - pos/neg voxels for component flip checking
  % --= % -----------------------------------
  betas = [];
  thrbetas = struct( 'betas', [] ); 
  compbetas = struct( 'threshold', [] ); 

  SubjectVector =  1:Zheader.num_subjects ;

  x = exist( 'ep' ); % --= 
  if ( x ~= 1 )   % --= % variable ep does not exist
    ep = calc_ext_Pos_Neg( VR ); % --= % recalculate extreme pos/neg values
  end % --= 
  % --= 

  % if ~isempty(pop)
  %   pop.setIterations( ncomps * nconds * nbins * Zheader.num_subjects * size( ep(1).percentiles, 1 ) );
  % end;

  for comp = 1:ncomps % --= 

    compbetas.threshold = []; 

    vr_cmp = VR(:,comp); % --= 

    for thr = 1:size( ep(comp).percentiles, 1 )

      thrbetas.betas = []; 

      threshold = ep(comp).percentiles( thr ).threshold; % --= % top 5% of component weights
      voxels = ep(comp).percentiles( thr).voxels; % --= 

      if ( pos == 1 ) % --= 
        x = find( vr_cmp > threshold ); % --= 
      else % --= 
        x = find( vr_cmp < ( threshold * -1 ) ); % --= 
      end % --= 

      comp_voxels = size(x,1); % --= 
      vr_comp = vr_cmp(x); % --= 

      if ( size(x,1) > 1 ) % --= % ensure that there are loadings 
  
        for cond = 1:nconds % --= 
          C_avg = []; % --= 

          for time=1:nbins % --= 

            C_temp=[]; % --= 
            for s=1:size(SubjectVector,2) % --= 

              C = [];
              % --- load each subject Hsegs/GMH/C_Sn data and concatenate frequencies together
              for FrequencyNo=1:max(scan_information.frequencies, 1)
                ftag = frequency_tag(FrequencyNo) ;

                for columnno = 1:Hheader.model(Hheader.Hindex).partitions.count
                  eval ( [ 'load( ''' H_Segments 'GnotH_C_S' num2str(s) '.mat'', ''C_C' num2str(columnno) ftag ''');'] );
                  eval ( [ 'C = [C C_C' num2str(columnno) ftag '];'] );
                  eval ( [ 'clear C_C' num2str(columnno) ftag ';'] );
                end
      
              end

              C_comp = C(:,x); % --=
 
              row=((cond-1)*nbins)+time; % --= 
              % --= C_temp = [C_temp; C_comp(row,:);
              eval( [ 'C_temp = [C_temp; C_comp(' int2str(row) ',:)];' ] );
            end% --= 
            if ( size(SubjectVector,2) > 1 ) % --= 
              C_avg(time,:)=mean(C_temp); % --= 
            else % --= 
              C_avg(time,:)=C_temp; % --= 
            end	% --= % avoid mean of data on single subject

            beta_avg_timecourses{cond}.avg_of_voxels=transpose(mean(C_avg')); % --= 

          end % --= 

          thrbetas.betas = [thrbetas.betas beta_avg_timecourses{cond}.avg_of_voxels ];

        end % --= % each condition

      else  % --= % --- there are no loadings ---

        thrbetas.betas = zeros( nbins, nconds ); % --= 

      end % --= 	

      compbetas.threshold = [compbetas.threshold; thrbetas ];

    end

    betas = [betas; compbetas ];% --= 

  end	% --= % --- each component ---

