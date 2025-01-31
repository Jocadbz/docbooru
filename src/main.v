module main

import os
import rand

fn has_all_matching_tags(user_input string, content string) bool {
	// Split the user input and content tags into arrays
	user_tags := user_input.split(' ')
	content_tags := content.split(' ')

	// Check if all user inputted tags are in content tags
	for user_tag in user_tags {
		if user_tag !in content_tags {
			return false // Found a tag that is not in content tags
		}
	}

	return true // All tags are found
}

fn generate_random_id(length int) !string {
	// Define the characters to choose from
	charset := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	mut id := []u8{len: length}

	for i in 0 .. length {
		// Get a random index from the charset
		random_index := rand.intn(charset.len)!
		id[i] = charset[random_index]
	}

	return id.bytestr() // Return the ID as a string
}

fn save_file(file_path string) !bool {
	mut id := generate_random_id(8)!
	id_list := os.ls("${os.config_dir()!}/docbooru/booru'")!
	for {
		if id !in id_list {
			break
		}
		id = generate_random_id(8)!
	}
	// The hardest thing of this program btw
	booru_directory := '${os.config_dir()!}/docbooru/booru'
	// We print this because user testing showed people panic when we move files.
	println('ATTENTION: DOCBOORU >>>WILL MOVE YOUR FILES<<<. SO THEY WILL VANISH FROM THEIR CURRENT LOCATION.')
	mut tags := os.input('Type the tags associated with this file (separated by spaces): ')
	if tags == '' {
		println('You typed no tags. Defaulting to tagme')
		tags = 'tagme'
	}
	os.mkdir_all('${booru_directory}/${id}')!
	mut name := os.open_file('${booru_directory}/${id}/name', 'w')!
	name.write_string('${os.file_name(file_path)}')!
	mut tags_file := os.open_file('${booru_directory}/${id}/tags', 'w')!
	tags_file.write_string('${tags}')!
	os.mkdir_all('${booru_directory}/${id}/file')!
	os.mv(file_path, '${os.real_path('${booru_directory}/${id}/file/')}/${os.file_name(file_path)}')!
	println('${os.file_name(file_path)} was sucessfully added to the database.')
	return true
}

fn search_file(search_params string) !bool {
	mut final_string := ''
	booru_directory := '${os.config_dir()!}/docbooru/booru'
	all_files := os.ls(booru_directory)!
	for id in all_files {
		file_name := os.read_file('${booru_directory}/${id}/name')!
		file_tags := os.read_file('${booru_directory}/${id}/tags')!
		file_path := '${booru_directory}/${id}/${file_name}'
		if has_all_matching_tags(search_params, file_tags) == true {
			final_string += '-----------------
ID: ${id} - Name: ${os.read_file('${booru_directory}/${id}/name')!}
Tags: ${os.read_file('${booru_directory}/${id}/tags')!}\n'

			final_string += 'Full path ${file_path}\n'
		}
	}
	if final_string == '' {
		println('No document matching your tags was found')
		exit(0)
	}
	println(final_string)
	return true
}

fn edit_file(filename string) !bool {
	booru_directory := '${os.config_dir()!}/docbooru/booru'
	all_files := os.ls(booru_directory)!
	if filename !in all_files {
		println("That file does not exist.")
		exit(0)
	}

	println('Previous tags: ${os.read_file('${booru_directory}/${filename}/tags')!}')
	new_tags := os.input('Input your new tags (separated by spaces): ')
	if new_tags == '' {
		println("You didn't add any tags. Aborting...")
		exit(1)
	}
	os.write_file('${booru_directory}/${filename}/tags', new_tags)!
	println('New tags applied.')
	exit(0)

	return false
}

fn remove_file(filename string) !bool {
	booru_directory := '${os.config_dir()!}/docbooru/booru'
	all_files := os.ls(booru_directory)!
	if filename !in all_files {
		println("That file does not exist.")
		exit(0)
	}
	selection := os.input('Docbooru will PERMANENTLY DELETE ${os.read_file('${booru_directory}/${filename}/name')!}, ARE YOU SURE? [yes/no]')
	if selection == 'yes' {
		os.rmdir_all('${booru_directory}/${filename}')!
		println('File ${filename} deleted.')
		exit(0)
		}
	println('Docbooru could not find a file with that name.')
	exit(1)
	return false
}

fn list_file() !bool {
	mut final_string := ''
	booru_directory := '${os.config_dir()!}/docbooru/booru'
	all_files := os.ls(booru_directory)!
	for id in all_files {
		file_name := os.read_file('${booru_directory}/${id}/name')!
		file_path := '${booru_directory}/${id}/${file_name}'
		final_string += '-----------------
ID: ${id} - Name: ${os.read_file('${booru_directory}/${id}/name')!}
Tags: ${os.read_file('${booru_directory}/${id}/tags')!}\n'

		final_string += 'Full path ${file_path}\n'
	}
	if final_string == '' {
		println('You have no files.')
		exit(0)
	}
	println(final_string)
	return true
}

fn main() {
	data_directory := '${os.config_dir()!}/docbooru'
	if os.exists(data_directory) == false {
		os.mkdir_all(data_directory)!
	}
	booru_directory := '${os.config_dir()!}/docbooru/booru'
	if os.exists(booru_directory) == false {
		os.mkdir_all(booru_directory)!
	}
	if os.args[1..] == [] {
		println('Use the help command for more information')
		exit(0)
	}
	if os.args[1] == 'help' {
		println("Docbooru - Command list
- add <file>
Uploads a file to the database

- search <tags separated by spaces>
Search the database based on input tags

- edit <id>
Apply new tags for a existing file

- remove <id>
Removes a file from the database

- list
List all files on the database
")
		exit(0)
	}
	if os.args[1] == 'add' {
		if os.args[2..] == [] {
			println('You need to supply a file path.')
			exit(1)
		}
		if os.exists(os.real_path(os.args[2])) == false {
			println("Error: docbooru can't find your file.")
			exit(1)
		}
		save_file(os.real_path(os.args[2]))!
	} else if os.args[1] == 'search' {
		if os.args[2..] == [] {
			println('You need to supply at least one tag')
			exit(1)
		}
		search_file(os.args[2..].join(' '))!
	} else if os.args[1] == 'edit' {
		if os.args[2..] == [] {
			println('You need to input a file')
			exit(1)
		}
		edit_file(os.args[2])!
	} else if os.args[1] == 'remove' {
		if os.args[2..] == [] {
			println('You need to input a file')
			exit(1)
		}
		remove_file(os.args[2])!
	} else if os.args[1] == 'list' {
		list_file()!
	}
}
