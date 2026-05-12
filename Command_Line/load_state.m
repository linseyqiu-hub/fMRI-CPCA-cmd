function state = load_state(state_file)
% load_state - Load pipeline state from pipeline_state.mat
% Returns the state struct
 
if ~exist(state_file, 'file')
    error('State file not found: %s\nRun stage1 first to initialize the pipeline.', state_file);
end
 
loaded = load(state_file, 'state');
state = loaded.state;
 
end

