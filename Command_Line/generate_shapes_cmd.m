function shapes = generate_shapes_cmd(events, bins, TR)
% GENERATE_SHAPES_CMD  Generate HRF shape templates from cognitive event definitions.
%
%   shapes = generate_shapes_cmd(events, bins, TR)
%
%   events  - struct array with fields:
%               onset    (ms)
%               duration (ms)
%   bins    - number of time bins (= config.bins)
%   TR      - repetition time in seconds (= config.TR)
%
%   Returns shapes [n_events x bins] — ready for hrfmax

shapes = [];

for i = 1:length(events)
    onsets = [events(i).onset/1000, events(i).duration/1000];  % ms → seconds
    X = calculate_hrf_shape(onsets, bins, TR);
    shapes = [shapes, X];
end

shapes = shapes';   % [n_events x bins]

