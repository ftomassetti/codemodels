require 'lightmodels/serialization'

module LightModels

module ModelBuilding

class << self
	attr_accessor :verbose
end

def self.verbose_warn(msg)
	warn(msg) if verbose
end

def self.handle_serialized_models_in_dir(src,src_extension,error_handler=nil,model_handler,&model_creator)
	Dir["#{src}/**/*.#{src_extension}"].each do |fd|
		verbose_warn "== #{fd} =="
		handle_serialized_model_per_file(fd,error_handler,model_handler,&model_creator)		
	end
end

def self.handle_models_in_dir(src,src_extension,error_handler=nil,model_handler,&model_creator)
	Dir["#{src}/**/*.#{src_extension}"].each do |fd|	
		verbose_warn "== #{fd} =="			
		handle_model_per_file(fd,error_handler,model_handler,&model_creator)		
	end
end

def self.generate_models_in_dir(src,dest,src_extension,dest_extension,max_nesting=500,error_handler=nil,&model_creator)
	verbose_warn "== #{src} -> #{dest} =="
	Dir["#{src}/**/*.#{src_extension}"].each do |fd|		
		if File.directory? fd
			basename = File.basename(fd)
			generate_models_in_dir("#{src}/#{basename}","#{dest}/#{basename}",src_extension,dest_extension,max_nesting,error_handler,&model_creator)
		else
			if File.extname(fd)==".#{src_extension}"
				translated_simple_name = "#{File.basename(fd, ".#{src_extension}")}.#{dest_extension}"
				translated_name = "#{dest}/#{translated_simple_name}"
				verbose_warn "* #{fd} --> #{translated_name}"
				generate_model_per_file(fd,translated_name,max_nesting,error_handler,&model_creator)
			end
		end
	end
end

def self.handle_model_per_file(src,error_handler=nil,model_handler,&models_generator)
	verbose_warn "<Model from #{src}>"
	begin
		m = models_generator.call(src)
		model_handler.call(src,m)
	rescue => e
		if error_handler
			error_handler.call(src,e)
		else
			raise e
		end
	end
end

def self.generate_model_per_file(src,dest,max_nesting=500,error_handler=nil,&models_generator)
	if not File.exist? dest 
		verbose_warn "<Model from #{src}>"
		
		begin
			m = models_generator.call(src)
			LightModels::Serialization.save_model(m,dest,max_nesting)
		rescue Exception => e
			if error_handler
				error_handler.call(src,e)
			else
				raise e
			end
		end		
	else
		verbose_warn "skipping #{src} because #{dest} found"
	end
end

end

end