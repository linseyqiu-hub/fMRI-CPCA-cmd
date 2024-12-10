function rno = revision_value( rvsn )

  if mod(uint32( rvsn.major ), rvsn.major )
    rno = rvsn.major * 100000 + rvsn.minor * 1000 +rvsn.edit;
  else
    rno = rvsn.major * 10000 + rvsn.minor * 1000 +rvsn.edit;
  end;
  


