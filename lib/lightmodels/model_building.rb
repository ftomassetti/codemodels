require 'lightmodels/serialization'

module LightModels

module ModelBuilding

class << self
	attr_accessor :verbose
end

def self.handle_serialized_models_in_dir(src,src_extension,error_handler=nil,model_handler,&model_creator)
	puts "== #{src} ==" if LightModels::ModelBuilding.verbose
	Dir["#{src}/*"].each do |fd|		
		if File.directory? fd
			basename = File.basename(fd)
			handle_serialized_models_in_dir("#{src}/#{basename}",src_extension,error_handler,model_handler,&model_creator)
		else
			if File.extname(fd)==".#{src_extension}"				
				handle_serialized_model_per_file(fd,error_handler,model_handler,&model_creator)
			end
		end
	end
end

def self.handle_models_in_dir(src,src_extension,error_handler=nil,model_handler,&model_creator)
	puts "== #{src} ==" if LightModels::ModelBuilding.verbose
	Dir["#{src}/*"].each do |fd|		
		if File.directory? fd
			basename = File.basename(fd)
			handle_models_in_dir("#{src}/#{basename}",src_extension,error_handler,model_handler,&model_creator)
		else
			if File.extname(fd)==".#{src_extension}"				
				handle_model_per_file(fd,error_handler,model_handler,&model_creator)
			end
		end
	end
end

def self.generate_models_in_dir(src,dest,src_extension,dest_extension,max_nesting=500,error_handler=nil,&model_creator)
	puts "== #{src} -> #{dest} ==" if LightModels::ModelBuilding.verbose
	Dir["#{src}/*"].each do |fd|		
		if File.directory? fd
			basename = File.basename(fd)
			generate_models_in_dir("#{src}/#{basename}","#{dest}/#{basename}",src_extension,dest_extension,max_nesting,error_handler,&model_creator)
		else
			if File.extname(fd)==".#{src_extension}"
				translated_simple_name = "#{File.basename(fd, ".#{src_extension}")}.#{dest_extension}"
				translated_name = "#{dest}/#{translated_simple_name}"
				puts "* #{fd} --> #{translated_name}" if LightModels::ModelBuilding.verbose
				generate_model_per_file(fd,translated_name,max_nesting,error_handler,&model_creator)
			end
		end
	end
end

def self.handle_model_per_file(src,error_handler=nil,model_handler,&models_generator)
	puts "<Model from #{src}>"
	
	if error_handler
		begin
			m = models_generator.call(src)
			model_handler.call(src,m)
		rescue Exception => e
			error_handler.call(src,e)
		rescue
			error_handler.call(src,nil)
		end
	else
		m = models_generator.call(src)
		model_handler.call(src,m)
	end
end

def self.handle_serialized_model_per_file(src,error_handler=nil,model_handler,&models_generator)
	puts "<Model from #{src}>"
	
	if error_handler
		begin
			m = models_generator.call(src)
			model_handler.call(src,m)
		rescue Exception => e
			error_handler.call(src,e)
		rescue
			error_handler.call(src,nil)
		end
	else
		m = models_generator.call(src)
		model_handler.call(src,m)
	end
end


def self.generate_model_per_file(src,dest,max_nesting=500,error_handler=nil,&models_generator)
	if not File.exist? dest 
		puts "<Model from #{src}>"
		
		if error_handler
			begin
				m = models_generator.call(src)
				LightModels::Serialization.save_model(m,dest,max_nesting)
			rescue Exception => e
				error_handler.call(src,e)
			rescue
				error_handler.call(src,nil)
			end
		else
			m = models_generator.call(src)
			LightModels::Serialization.save_model(m,dest,max_nesting)
		end
	else
		puts "skipping #{src} because #{dest} found" if LightModels::ModelBuilding.verbose 
	end
end

end

end