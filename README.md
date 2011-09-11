Binary Finary
=============

Mixes in a _fluent interface_ to any IO entity.
Performs operations accepted by the following grammar:

		OP_INT ::= operation '_' integer_type bits ('_' endianness)?
		operation     ::= 'read' | 'write'
		integer_type  ::= 'uint' | 'int'
		bits          ::= '8' | '16' | '32' | '64' | '128' | '256'
		endianness    ::= 'native' | 'little' | 'big' | 'network'

		OP_STR ::= operation '_' (padding '_')? flavor '_of_' size '_' 'bytes'
		padding ::= 'null_padded' | 'c'
		flavor  ::= 'string' | 'fixed_string' | 'binary_string'
		size    ::= [0-9]+

Handles (de)serialization of:

  - Integer numbers
  - Null terminated strings
  - Fixed size strings


Requirements
------------

Binary Finary assumes that the stream where
is mixed in, provides the following methods:

	- read or read_nonblock
	- write or write_nonblock



It will run under Ruby version 1.8.7 or newer.


Examples
--------

	File.open(my_file.bin) do |f|
		f.extend(BinaryFinary)
	  version = f.read_uint16_big
		length  = f.read_uint32_little
	end



Install
-------

    $ gem install binary_finary


Contributing
------------

If you'd like to hack on, please follow these instructions.
To get all of the dependencies, install the gem first.

1. Fork the project and clone down your fork
2. Create a branch with a descriptive name to contain your change
4. Hack away
5. Add tests and make sure everything still passes by running rake
6. Do not change the version number, I will do that on my end
7. If necessary, rebase your commits into logical chunks, without errors
8. Push the branch up to GitHub
9. Send me (altamic) a pull request for your branch


Copyright
=========

© Copyright 2011 Michelangelo Altamore. See LICENSE for details.

