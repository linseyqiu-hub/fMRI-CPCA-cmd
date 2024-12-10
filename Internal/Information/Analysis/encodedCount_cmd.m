function numEncoded = encodedCount_cmd(Zheader,scan_information, condition )

  numEncoded = 0;
  for s = 1:Zheader.num_subjects
    if isEncoded_cmd(Zheader,scan_information, s, condition )
      numEncoded = numEncoded + 1;
    end
  end


