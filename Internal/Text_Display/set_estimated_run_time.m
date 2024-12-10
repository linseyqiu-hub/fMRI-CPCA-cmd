function set_estimated_run_time( handles )
global Zheader scan_information

  estimated_time = Zheader.total_scans * scan_information.image_read_average;
  estimated_time = estimated_time + (Zheader.total_scans / scan_information.normalize_average) * max(scan_information.frequencies, 1);
  estimated_time = estimated_time + (Zheader.total_scans / scan_information.save_average) * max(scan_information.frequencies, 1);

  set(handles.txt_EstimatedTime,'String',format_toc( estimated_time, '' ));
