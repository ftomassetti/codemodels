curr_dir = File.dirname(__FILE__)

Dir[curr_dir+"/codemodels/*.rb"].each do |rb|
	require rb
end
