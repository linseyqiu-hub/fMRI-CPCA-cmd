function p = flip_MNI_values( q )

  p = q;

  if ~isempty(p)
    for cl = 1:size( p,1)
      p(cl).peak.value = p(cl).peak.value * -1;
      p(cl).load = p(cl).load .* -1;

      if ~isempty( p(cl).region )
        for r = 1:size( p(cl).region,1)
          p(cl).region(r).value = p(cl).region(r).value * -1;
        end;  % --- each region of cluster of Negative threshold
      end;

    end;  % --- each cluster of Negative threshold
  end;

