from assembler_src.instr_arr import *
from assembler_src.parse import *
from os.path import exists

__all__ = ['converter']

class converter:

	def __init__(self, output_mode : str = 'a', nibble_mode : bool = False, hex_mode : bool = False) -> None:
		self.__output_mode = self.__check_output_mode(output_mode)
		self.__nibble_mode = self.__check_nibble_mode(nibble_mode)
		self.__hex_mode = self.__check_hex_mode(hex_mode)

	def __str__(self):
		return "Output: {output_mode}, Nibble: {nibble_mode}, Hex: {hex_mode}".format(
			output_mode = self.__output_mode,
			nibble_mode = self.__nibble_mode,
			hex_mode = self.__hex_mode
		)

	def __repr__(self):
		return "Output: {output_mode}, Nibble: {nibble_mode}, Hex: {hex_mode}".format(
			output_mode = self.__output_mode,
			nibble_mode = self.__nibble_mode,
			hex_mode = self.__hex_mode
		)

	def clone(self):
		return converter(
			output_mode = self.__output_mode,
			nibble_mode = self.__nibble_mode,
			hex_mode = self.__hex_mode
		)

	def __call__(self, *args):
		return self.convert(*args)

	def __check_output_mode(self, x) -> str:
		mod = ''.join(sorted(x.split()))
		assert mod in ['a', 'f', 'p', None], "Output Mode needs to be one of a(rray), f(ile), p(rint), or None."
		return x

	def __check_nibble_mode(self, x) -> str:
		assert type(x) == bool, "Nibble mode needs to be a boolean."
		return x

	def __check_hex_mode(self, x) -> str:
		assert type(x) == bool, "Hex mode needs to be a boolean."
		return x

	'''
		Property: the way to output machine code
			Options: 'a', 'f', 'p'
	'''
	@property
	def output_mode(self) -> str:
		return self.__output_mode

	@output_mode.setter
	def output_mode(self, x : str) -> None:
		self.__output_mode = x

	'''
		Property: whether to print in nibbles (only applicable for text or print)
			True = nibble
			False = full number
	'''
	@property
	def nibble_mode(self) -> str:
		return self.__nibble_mode

	@nibble_mode.setter
	def nibble_mode(self, x : str) -> None:
		self.__nibble_mode = x

	'''
	Property: whether to return as hex or not
		True = hex
		False = binary
	'''
	@property
	def hex_mode(self) -> str:
		return self.__hex_mode

	@hex_mode.setter
	def hex_mode(self, x : str) -> None:
		self.__hex_mode = x

	'''
		Put it all together. Need to modify for output type.

		Input is either a file name or string of assembly.
	'''
	def convert(self, input : str, file : str = None):
		output = Parser(input)
		assert len(output) > 0, "Provided input yielded nothing from parser. Check input."
		output = self.mod(output) # apply nibble mode, hex mode

		if self.__output_mode == 'a':
			return output
		elif self.__output_mode == 'f':
			prov_dir = '/'.join(file.split('/')[:-1])
			assert file != None, "For output mode to file, need to provided file name."
			assert exists(prov_dir if prov_dir != '' else '.'), "Directory of provided file name does not exist."

			if self.__hex_mode and file[-4:] == '.bin':
				# change back to binary
				print('Warning: hex mode overrided in over to output to binary file.')
				output = [format(int(elem, 16), '032b') for elem in output]
			converter.write_to_file(output, file)
			return
		elif self.__output_mode == 'p':
			print('\n'.join(output))
			return

		raise NotImplementedError()

	@staticmethod
	def write_to_file(output : list, file : str) -> None:
		extension = file[-4:]

		if extension == '.bin':
			with open(file, 'wb') as f:
				for instr in output:
					byte_array = [instr[i:i+8] for i in range(0,len(instr),8)]
					byte_list = [int(b,2) for b in byte_array]
					f.write(bytearray(byte_list))
			return

		elif extension == '.txt':
			with open(file, 'w') as f:
				for instr in output:
					f.write(instr + "\n")

			return

		elif extension == '.csv':
			raise NotImplementedError()

		elif extension == '.dat':
			raise NotImplementedError()

		raise NotImplementedError()

	def mod(self, output : list) -> list:
		if self.__nibble_mode:
			output = converter.apply_nibble(output)
		elif self.__hex_mode:
			output = converter.apply_hex(output)
		return output

	@staticmethod
	def apply_nibble(output : list) -> list:
		return ['\t'.join([elem[i:i+4] for i in range(0, len(elem), 4)]) for elem in output]

	@staticmethod
	def apply_hex(output : list) -> list:
		return ['0x' + '{:08X}'.format(int(elem, 2)).lower() for elem in output]