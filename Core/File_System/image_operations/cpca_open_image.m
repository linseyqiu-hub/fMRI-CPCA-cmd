function [fid endian] = cpca_open_image( P )

  std_hdr_size = 348;
  endian = [];


  % -----------------------------------------------
  % open the input file in native endian format
  % -----------------------------------------------
  fid   = fopen(P,'r','native');

  if (fid > 0)

    % -----------------------------------------------
    % first dword of file is structure length - test for endian type  
    % structure length = 348 endian will be this value swapped
    % -----------------------------------------------
   
    if isBigendian()
      endian	= 'ieee-be';			
    else,
      endian	= 'ieee-le';
    end;

    sizeof_hdr	= fread(fid,1,'int32');
    fseek(fid,0,'bof');                     	% reset to beginning of file

    if sizeof_hdr ~= std_hdr_size		% Appears to be other-endian

      % -----------------------------------------------
      % Reopen the file in it's written endian
      % -----------------------------------------------
      fclose(fid);
      if isBigendian()
        endian	= 'ieee-le';			% little endian file on big endian machine			
      else,
        endian	= 'ieee-be';			% big endian file on little endian machine
      end;

      fid = fopen(P,'r',endian);		
      if ( fid )
        sizeof_hdr = fread(fid,1,'int32');
        fseek(fid,0,'bof');                 	% reset to beginning of file
        if sizeof_hdr ~= std_hdr_size		% other endian also improper header size flag
          fclose(fid);
          fid = -1;				% flag as corrupted file
          endian	= [];			
        end;
      end;

    end;  % reopen in different endian 

  end;  % valid file pointer

