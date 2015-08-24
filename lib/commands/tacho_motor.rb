module LegoEv3::Commands::TachoMotor
  extend LegoEv3::Commands::CommandBuilder

  base_path '/sys/class/tacho-motor'
  has_list
  get :port_name
  get :count_per_rot, Integer
  get :duty_cycle, Integer
  get :states, String, 'state', -> response { response.split(' ').map{ |s| s.strip.to_sym } }
  get_set :duty_cycle_sp, Integer
  get_set :position, Integer
  get_set :position_sp, Integer
  get_set :speed_sp, Integer
  get_set :polarity, Symbol
  get_set :time_sp, Integer
  get_set :stop_command, Symbol
  get_set :speed_regulation, Symbol, nil, -> (response) { response == :on }
  command :run_forever, 'run-forever'
  command :run_to_abs_pos, 'run-to-abs-pos'
  #command :run_to_rel_pos, 'run-to-rel-pos' # not used.
  command :run_timed, 'run-timed'
  command :run_direct, 'run-direct'
  command :stop
  command :reset
end
