from assembler_src.instr_arr import *
from types import FunctionType as function
from os.path import exists
__all__ = ['Parser']

class _Parser:

	def __call__(self, *args) -> list:
		
		if type(args[0]) == list:
			return _Parser.interpret_arr(*args)
		elif exists(*args): # input is file
			return _Parser.interpret_arr(_Parser.read_file(*args))
		elif type(args[0]) == str: # input is single line
			return _Parser.interpret_arr(args[0].split('\n'))

		raise Exception('''Bad Input provided, 
			make sure its either a valid file name, 
			single-line instruction as a string, 
			or a list of instructions as strings.''')

	'''
		In read_file(), Check if the inputted line is appropriate before
		parsing it.
	'''
	@staticmethod
	def valid_line(x : str, allow_colon : bool = False) -> bool:
		if x[0][0] == "#" or x[0][0] == "\n" or x[0][0] == "" or x[0][0] == ".":
			return False

		if not allow_colon and x[-1] == ":" :
			return False
		return True

	'''
		In interpret(), remove any comments in the line.
	'''
	@staticmethod
	def handle_inline_comments(x : str) -> str:
		if "#" in x:
			pos = x.index("#")
			if pos != 0 and pos != len(x)-1:
				return x[0:pos].replace(',', ' ')
		return x.replace(',', ' ')

	@staticmethod
	def handle_specific_instr(x : list) -> list:
		# for sw, lw, lb, lh, sb, sh
		if len(x[0]) == 2 and (x[0] in S_instr or x[0] in I_instr):
			y = x[-1].split('('); y[1] = y[1].replace(')','')
			return x[0:-1] + y
		elif 'requires jump' == 5:
			...

		return x

	'''
		Read the .s file provided and parse it completely.
	'''
	@staticmethod
	def read_file(file : str) -> list:
		with open(file) as f:
			return [x.strip() for x in f.readlines() if x != '\n']

	@staticmethod
	def interpret_arr(code : list) -> list:
		int_code = []
		code = [e.strip() for e in code]
		for line_num, line in enumerate(code):
			tokens = _Parser.tokenize(line, line_num, code)
			int_code += [_Parser.interpret(tokens) for _ in range(1) if len(tokens) != 0]

		return int_code

	'''
		Tokenize a given line
	'''
	@staticmethod
	def tokenize(line : str, line_num: int = None, code : list = None) -> list:
		line = line.strip()
		if len(line) > 0 and _Parser.valid_line(line):
			tokens = _Parser.handle_inline_comments(line).split()
			tokens = _Parser.handle_specific_instr(tokens)
			return tokens + [line_num, code] if line_num != None and code != None else tokens
		return []

	'''
		In read_file(), parse and return the machine code.
	'''
	@staticmethod
	def interpret(tokens : list) -> str:
		f = _Parser.determine_type(tokens[0])
		return f(tokens)

	'''
		In interpret(), determine which instruction set is being used
		and return the appropriate parsing function.
	'''
	@staticmethod
	def determine_type(tk : str) -> function:
		instr_sets = [R_instr, I_instr, S_instr, SB_instr, U_instr, UJ_instr, pseudo_instr]
		parsers = [Rp, Ip, Sp, SBp, Up ,UJp, Psp]
		for i in range(len(instr_sets)):
			if tk in instr_sets[i]:
				return parsers[i]
		raise Exception("Bad Instruction Provided: " + tk + "!")

Parser = _Parser()