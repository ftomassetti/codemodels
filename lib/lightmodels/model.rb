module LightModels

# A light model. External objects contains a basic description (only type and attributes)
# of nodes referred by nodes in the proper model tree.
class Model
	attr_accessor :root
	attr_accessor :name
	attr_accessor :external_objects
end

end