function X = calculate_hrf_shape(  onsets, nscans, TR )

      fMRI_T = 16; % --= 
      fMRI_T0 = 1; % --= 
      % --= 
      SPM.xBF.T = fMRI_T; % --= 
      SPM.xBF.T0 = fMRI_T0; % --= 
      % --= 
      SPM.xBF.RT = TR; % --= 
      % --= 
      SPM.nscan = nscans; % --= 
      % --= 
      SPM.xBF.dt = SPM.xBF.RT / SPM.xBF.T; % --= 
      % --= 
      SPM.xBF.UNITS = 'scans'; % --= 
      SPM.xBF.name = 'hrf'; % --= 
      % --= 
      SPM.xBF = spm_5_get_bf( SPM.xBF ); % --= 

      % --= 
%      num_events = size( onsets, 1 ); % --= 
      num_events = 1; % --= 

      % --= 
      SPM.xBF.Volterra = 1; % --= 
      s = length(SPM.nscan(1)); % --= 
      v = num_events; % --= 

      SPM.Sess(1).U(1).name = {'test name'};  % --= 
      SPM.Sess(1).U(1).ons = onsets(:, 1)/TR;  % --= 
      SPM.Sess(1).U(1).dur = onsets(:, 2)/TR;  % --= 
      SPM.Sess(1).U(1).P.name = 'none';  % --= 

      % --= 
      U = spm_5_get_ons(SPM,s);  % --= 
      [X, Xn, Fc] = spm_5_Volterra( U, SPM.xBF.bf, SPM.xBF.Volterra );  % --= 
        % --= 
      try  % --= 
        X = X([0:(SPM.nscan-1)] * fMRI_T + fMRI_T0 + 32,:);  % --= 
      end  % --= 

      % --= 
      % orthogonalize (within trial type)  % --= 
      for ii = 1:length(Fc)  % --= 
        X(:,Fc(ii).i) = spm_5_orth( X(:,Fc(ii).i) );  % --= 
      end;  % --= 
      if exist( 'CON', 'var')  % --= 
        if ( length(CON) > 0 )  % --= 
          X = X * CON;  % --= 
        end;  % --= 
      end;  % --= 

%      X = ( X - ones(size(X,1),1) * mean(X) ) ./ ( ones(size(X,1),1) * std(X) );
%      G = blkdiag( G, X );

