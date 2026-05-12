function state = init_state(config)
% init_state - Initialize a fresh pipeline state from config
% Called when no pipeline_state.mat exists or user wants a fresh run
 
state.config = config;
 
state.stages = {'stage1', 'stage2', 'stage3', 'stage4'};
 
state.status.stage1 = 'not_started';
state.status.stage2 = 'not_started';
state.status.stage3 = 'not_started';
state.status.stage4 = 'not_started';
 
state.current_stage = 0;
 
state.timestamps.stage1_start = '';
state.timestamps.stage1_end   = '';
state.timestamps.stage2_start = '';
state.timestamps.stage2_end   = '';
state.timestamps.stage3_start = '';
state.timestamps.stage3_end   = '';
state.timestamps.stage4_start = '';
state.timestamps.stage4_end   = '';
 
end

