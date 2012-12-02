require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'copperegg'

# Get a @metrics object:
config_file = "config.yml"
@config = YAML.load(File.open(config_file))
apikey = @config["copperegg"]["apikey"]
@copper = CopperEgg::Metrics.new(apikey)



group_name = "my_metric_group"
mg = @copper.metric_group(group_name)
instance = 'ip-10-35-99-201'
loop = 10

if mg.nil?
  puts "metric group not found, creating and bailing..."
  # check
  groupcfg = {}
  groupcfg["name"] = group_name
  groupcfg["label"] = "Cool New Group Visible Name"
  groupcfg["frequency"] = "30"  # data is sent every 60s
  groupcfg["metrics"] = [{"ce_counter" => "counter_test_value", "unit" => "SomeApp"},
    {"ce_gauge" => "gauge_test_value", "unit" => "SomeApp"}]
  res = @copper.create_metric_group(group_name, groupcfg)
else
  @metrics = {}
  puts "looping and setting random metrics..."
  loop.times do |x|
    count = rand(20)
    gauge = rand(30)
    sleep 30
    metrics['counter_test_value'] = count
    metrics['gague_test_value'] = gauge
    @copper.store_sample(group_name, instance, Time.now.to_i, metrics)
  end
end

