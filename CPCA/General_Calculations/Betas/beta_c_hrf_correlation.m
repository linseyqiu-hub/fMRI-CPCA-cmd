function bstats = beta_c_hrf_correlation( VR, HRF, betas_pos, betas_neg, Gheader, comp  )

  bstats = struct( 'pos_vox', 0, 'neg_vox', 0, 'pos_corr', 0, 'neg_corr', 0 );

  x = find( VR(:,comp) >= 0 );
  bstats.pos_vox = size(x,1);
  x = find( VR(:,comp) < 0 );
  bstats.neg_vox = size(x,1);

%  bur = ur_component_stats( HRF, Gheader, 1 );
  nconds = Gheader.conditions;
  nbins = Gheader.bins;

  eval(['hrf_comp' int2str(comp) '=[];']);
  beta_hrf=[];

  for cond = 1:nconds

    eval(['hrf_cond' int2str(cond) '=[];']);

    for subject = 1:Zheader.num_subjects

      startrow=(subject-1)*nbins*nconds+(cond-1)*nbins+1;
      endrow=startrow+nbins-1;
      temp=UR(startrow:endrow,comp);
      eval(['hrf_cond' int2str(cond) '(:,subject)=temp;']);

    end;  % each subject

    eval(['hrf_cond' int2str(cond) '= hrf_cond' int2str(cond) ''';']);
     
    eval(['hrf_comp' int2str(comp) '=[hrf_comp' int2str(comp) ' hrf_cond' int2str(cond) '];']);
    
    if ( Zheader.num_subjects > 1 )
      eval(['beta_hrf=[beta_hrf transpose(mean(hrf_cond' int2str(cond) '))];']);
    else
      eval(['beta_hrf=[beta_hrf transpose(hrf_cond' int2str(cond) ')];']);
    end;

  end;	% each condition

  x = mean( betas_pos(comp).beta_c, beta_hrf );
  bstats.pos_corr = x(1,2);


  x = corrcoef( betas_neg(comp).beta_c, beta_hrf );
  bstats.neg_corr = x(1,2);


