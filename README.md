# symfix
Symfix is a cygwin symbolic link fixer for Microsoft Windows

Usage: symfix [OPTION]... [DIRECTORY]...

### Example:
  symfix -f .\

Scans the current directory and all child folders for symbolic links
and restore the system attribute bit for proper functionality. It is
common for the attribute to be lost after zipping/un-zipping this
utility can restore functionality. The output will be a list of
found symbolic links with their complete path.

Startup:
  -h, --help                 print this help
  -f, --fix (default)        finds symbolic link files & sets system attribute
  -u, --unset                finds symbolic links & unsets system attribute
  -q, --quiet                quiet (no output)
