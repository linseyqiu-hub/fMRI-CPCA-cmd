function set_callback( javaObject, varargin )

  hObj = handle(javaObject, 'callbackProperties');
  for i = 1:2:length(varargin)
    set(hObj, varargin{i}, varargin{i+1});
  end


