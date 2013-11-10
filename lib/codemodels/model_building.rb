# encoding: utf-8
require 'codemodels/serialization'

module CodeModels

class FilesSource
	
	def initialize(dir,extension)
		@dir = dir
		@extension = extension
	end

	def each(&block)
		Dir["#{@dir}/**/*.#{@extension}"].each do |f|
			block.call(f)
		end
	end
end

class FileMapper

	def initialize(src,dest,src_extension,dest_extension)
		@src  = src
		@dest = dest
		@src_ext = src_extension
		@dest_ext = dest_extension
	end

	def map(f)
		f_in_dest_dir = File.join(@dest,f.remove_prefix(@src))
		f_in_dest_dir.remove_postfix(@src_ext)+@dest_ext
	end

end

module ModelBuilding

class << self
	attr_accessor :verbose
	attr_accessor :max_nesting
end

@@verbose     = false
@@max_nesting = 500

def self.verbose_warn(msg)
	warn(msg) if verbose
end

def self.generate_models_in_dir(src,dest,src_extension,dest_extension,&model_creator)
	verbose_warn "== #{src} -> #{dest} =="
	FilesSource.new(src,src_extension).each do |f|		
		dest_name = FileMapper.new(src,dest,src_extension,dest_extension).map(f)
		verbose_warn "* #{f} --> #{dest_name}"
		generate_model_per_file(f,dest_name,&model_creator)
	end
end

def self.handle_model_per_file(src,model_handler,&models_generator)
	verbose_warn "<Model from #{src}>"
	
	m = models_generator.call(src)
	model_handler.call(src,m) if m
end

def self.generate_model_per_file(src,dest,&models_generator)
	if not File.exist? dest 
		verbose_warn "<Model from #{src}>"				
		m = models_generator.call(src)
		LightModels::Serialization.save_model(m,dest,@@max_nesting) if m			
	else
		verbose_warn "skipping #{src} because #{dest} found"
	end
end

end

end