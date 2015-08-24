module LegoEv3::Commands::LegoPort
  extend LegoEv3::Commands::CommandBuilder

  base_path '/sys/class/lego-port'
  has_list
  get :port_name
  get :status
end