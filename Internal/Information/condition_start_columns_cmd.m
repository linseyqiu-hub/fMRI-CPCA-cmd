function sp = condition_start_columns_cmd(Zheader, nconds, nbins )

  sp = [];
  x = zeros(1,nconds); 
  p = [];

  for s=1:Zheader.num_subjects
    fprintf('Subject %d: condition length = %d\n', s, length(Zheader.conditions.encoded(s).condition));
    p = [p; Zheader.conditions.encoded(s).condition];

    y = find( Zheader.conditions.encoded(s).condition == 1 );

    x = zeros(1,nconds); 
    for c = 1:size(y,2) 
      if s > 1
        x(y(c)) = sum(sum(p(1:s-1,:))) * nbins + (c-1)*nbins; 
      else
        x(y(c)) = (c-1)*nbins; 
      end
    end
    fprintf('Subject %d: x length = %d, sp rows = %d\n', s, length(x), size(sp,2));
    sp = [sp; x ];
  end



