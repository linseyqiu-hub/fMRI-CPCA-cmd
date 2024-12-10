function pfac = calc_regression_stats()
global Zheader scan_information

  Normalized_Z_Dir = Z_Directory();

  pfac = zeros(1, 4 );

  SSErr = [];
  SSP = [];

  % --- variables for defines
  linear_trend = 1;
  quadratic_trend = 2;
  headmove_trend = 3;
  user_trend = 4;

  for SubjectNo=1:Zheader.num_subjects

%    if scan_information.isMulFreq

      for FrequencyNo = 1:max(scan_information.frequencies, 1)
        ftag = frequency_tag(FrequencyNo) ;

        SS_E = load_subject_Z_var( SubjectNo, 'SS_E' );
        x = size(SS_E, 1);
        if x > 1
          SSErr = [SSErr; sum(SS_E(:,1:4))];
          SSP = [SSP; sum(SS_E(:,5:8))];
       else
          SSErr = [SSErr; SS_E(1:4)];
          SSP = [SSP; SS_E(5:8)];
        end;
        clear SS_E;
      end;

  end;

  for r = 1:size( SSErr,1)
    for c = 1:size(SSErr,2)
      if SSP(r,c) > 0
        SSP(r,c) = 100 - SSErr(r,c) / SSP(r,c) * 100;
      end;
    end;
  end;


  if size( SSErr, 1 ) > 1

    SSP = mean( SSP );
    if SSP(quadratic_trend) > 0 
      SSP(quadratic_trend) = SSP(quadratic_trend) - SSP(linear_trend);
    end;
    if SSP(headmove_trend) > 0 
      SSP(headmove_trend) = SSP(headmove_trend) - SSP(quadratic_trend)- SSP(linear_trend);
    end;
    if SSP(user_trend) > 0 
      SSP(user_trend) = SSP(user_trend) - SSP(headmove_trend) - SSP(quadratic_trend)- SSP(linear_trend);
    end;

  end;

  pfac = SSP;

