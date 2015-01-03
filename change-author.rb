#!/bin/ruby
# encoding: utf-8 

require 'date'
require 'fileutils'
require 'json'

DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'
$config = {}

def load_config(path)
	open(path, 'r:utf-8') { |file|
		json = file.readlines.join('')
		$config = JSON.load(json)
	}
end

def change_author_for_dir(dir_path, last_modified)
	Dir.glob(dir_path + "/**/*.m").each { |file_path|
		change_author_for_file(file_path, last_modified)
	}
	Dir.glob(dir_path + "/**/*.h").each { |file_path|
		change_author_for_file(file_path, last_modified)
	}
end

def change_author_for_file(file_path, last_modified)
	mtime = File.mtime(file_path)
	mtime = DateTime.parse(mtime.strftime(DATETIME_FORMAT))
	src_author = $config['src_author']
	dst_author = $config['dst_author']

	return if (last_modified != nil) && (mtime <= last_modified)

	lines = nil
	open(file_path, 'r:utf-8') { |f|
		lines = f.readlines
	}

	is_change_author = false
	lines.each { |line|
		if line =~ /^\/\/\s+Created\s+by\s+#{src_author}\s+on/
			line.sub!(/#{src_author}/, dst_author)
			is_change_author = true
		end
	}
	return if ! is_change_author

	puts 'Changed author: ' + file_path
	open(file_path + '.tmp', 'w:utf-8') { |f|
		lines.each { |line|
			f.write line
		}
	}
	FileUtils.cp(file_path + '.tmp', file_path)
end

def read_timestamp(path)
	if File.exists?(path)
		open(path, 'r') { |file|
			datestr = file.gets
			date = DateTime.parse(datestr)
			puts 'Last modified: ' + date.strftime(DATETIME_FORMAT)
			return date
		}
	end

	return nil
end

def write_timestamp(path)
	open(path, 'w') { |file|
		date = DateTime.now
		file.puts date.strftime(DATETIME_FORMAT)
	}
end

begin
	target_dir = ARGV[0]
	timestamp_path = target_dir + '/change_author.timestamp'
	config_path = target_dir + '/change_author.config'

	raise "#{target_dir} is not found." if ! File.exists?(target_dir)
	raise "#{config_path} is not found." if ! File.exists?(config_path)

	load_config(config_path)
	last_modified = read_timestamp(timestamp_path)
	change_author_for_dir(target_dir, last_modified)
	write_timestamp(timestamp_path)
end
