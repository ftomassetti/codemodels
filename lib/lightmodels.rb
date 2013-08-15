curr_dir = File.dirname(__FILE__)

Dir[curr_dir+"/lightmodels/*.rb"].each do |rb|
	require rb
end
