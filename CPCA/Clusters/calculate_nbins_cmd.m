function nbins = calculate_nbins_cmd(Zheader)


  nbins = 0; 

  if Zheader.Model.mat_y > 0
    x = 0;
    for ii = 1:size(Zheader.conditions.encoded,1)
      x = x + sum(Zheader.conditions.encoded(ii).condition); 
    end
    nbins = Zheader.Model.mat_y / x;
  end

