# DocBooru

A terminal-based booru-like app, focusing on documents and files

## Running

You will need the [V](https://vlang.io) compiler.
```sh
v .
./docbooru help
```

## Manual

```
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
```

## FAQ

- **HELP, I uploaded my file and it vanished from my folder!**
Yeah, we kind warn that it will happen. `docbooru list` will list your file and it's new location.

- **I want to edit/remove a file, but it keeps saying that it doesn't exist!**
Both remove/edit commands take the file ID as the argument.

- **But how do I know my file's ID?**
Running `docbooru list/search` will show you. For example:
```
ID: Wsm0NjLx - Name: example_2
Tags: second example test
Full path /blah/blah/blah/example_2
```
In this case, example_2's ID is Wsm0NjLx.