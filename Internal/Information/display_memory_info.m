function display_memory_info()

  x = check_memory();
  fprintf( '  total: %.2f Gb    used: %.2f    free: %.2f    cached:  %.2f\n\n', ...
      x.user.total/1000, x.user.used/1000, x.user.free/1000, x.user.cache/1000);
