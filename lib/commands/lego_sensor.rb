module LegoEv3::Commands::LegoSensor
  extend LegoEv3::Commands::CommandBuilder

  base_path '/sys/class/lego-sensor'
  has_list
  get :port_name
  get :driver_name
  get :decimals, Integer
  get :num_values, Integer
  get :value0, Integer
  get :value1, Integer
  get :value2, Integer
  get :value3, Integer
  get :value4, Integer
  get :value5, Integer
  get :value6, Integer
  get :value7, Integer
end