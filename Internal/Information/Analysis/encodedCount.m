function numEncoded = encodedCount( condition )
  global Zheader

  numEncoded = 0;
  for s = 1:Zheader.num_subjects
    if isEncoded( s, condition )
      numEncoded = numEncoded + 1;
    end;
  end;


