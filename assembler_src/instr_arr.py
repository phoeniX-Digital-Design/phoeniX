from pathlib import Path

__all__ = [
	'R_instr', 'I_instr', 'S_instr',
	'SB_instr', 'U_instr', 'UJ_instr','pseudo_instr',
	 'R', 'I', 'S', 'SB', 'U', 'UJ',
	 'Rp', 'Ip', 'Sp', 'SBp', 'Up', 'UJp', 'Psp']

class Instruction:
	def compute_instr(self, *args):
		raise NotImplementedError()

	def __call__(self, *args):
		return self.compute_instr(*args)

	def check_instr_valid(self, x, instr_set):
		assert x in instr_set, "{instr} is not the right instruction for this function.".format(instr = x)
		return x

	@staticmethod
	def immediate(*args):
		raise NotImplementedError()

	@staticmethod
	def reg(x):
		return format(int(x[1:]), '05b')

class _R(Instruction):
	def __repr__(self):
		return "R instruction"

	def __str__(self):
		return "R instruction"

	def compute_instr(self, instr, rs1, rs2, rd):
		instr = super().check_instr_valid(instr, R_instr)
		opcode, f3, f7 = 0, 1, 2

		return "".join([
			instr_map[instr][f7],
			super().reg(rs2),
			super().reg(rs1),
			instr_map[instr][f3],
			super().reg(rd),
			instr_map[instr][opcode]
		])

class _I(Instruction):
	def __repr__(self):
		return "I instruction"

	def __str__(self):
		return "I instruction"

	def compute_instr(self, instr, rs1, imm, rd):
		instr = super().check_instr_valid(instr, I_instr)
		opcode, f3 = 0, 1

		return "".join([
			_I.immediate(imm),
			super().reg(rs1),
			instr_map[instr][f3],
			super().reg(rd),
			instr_map[instr][opcode]
		])

	@staticmethod
	def immediate(imm):
		#return int(imm) - ((int(imm)>>12)<<12) # imm[11:0]
		return format(((1 << 12) - 1) & int(imm), '012b')
		#return format(int(imm), '012b')

class _S(Instruction):
	def __repr__(self):
		return "S instruction"

	def __str__(self):
		return "S instruction"

	def compute_instr(self, instr, rs1, rs2, imm):
		instr = super().check_instr_valid(instr, S_instr)
		opcode, f3 = 0, 1

		return "".join([
			_S.immediate(imm, 1),
			super().reg(rs2),
			super().reg(rs1),
			instr_map[instr][f3],
			_S.immediate(imm, 2),
			instr_map[instr][opcode]
		])

	@staticmethod
	def immediate(imm, n):
		'''mod_imm = (int(imm) - ((int(imm) >> 12) << 12)) >> 5 # imm[11:5]
								mod_imm_2 = int(imm) - ((int(imm) >> 5) << 5) # imm[4:0]
						
								return mod_imm, mod_imm_2'''
		mod_imm = format(((1 << 12) - 1) & int(imm), '012b')
		if n == 1:
			return mod_imm[0] + mod_imm[12-10 : 12-4]
		return mod_imm[12-4 : 12 - 0] + mod_imm[1]


class _SB(Instruction):
	def __repr__(self):
		return "SB instruction"

	def __str__(self):
		return "SB instruction"

	def compute_instr(self, instr, rs1, rs2, imm):
		instr = super().check_instr_valid(instr, SB_instr)
		opcode, f3 = 0, 1

		return "".join([
			_SB.immediate(imm, 1),
			super().reg(rs2),
			super().reg(rs1),
			instr_map[instr][f3],
			_SB.immediate(imm, 2),
			instr_map[instr][opcode]
		])

	@staticmethod
	def immediate(imm, n):
		mod_imm = format(((1 << 13) - 1) & int(imm), '013b')
		if n == 1:
			return mod_imm[12-12] + mod_imm[12-10:12-4]
		return mod_imm[12-4:12-0] + mod_imm[12-11]

class _U(Instruction):
	def __repr__(self):
		return "U instruction"

	def __str__(self):
		return "U instruction"

	def compute_instr(self, instr, imm, rd):
		instr = super().check_instr_valid(instr, U_instr)
		opcode = 0

		return "".join([
			_U.immediate(imm),
			super().reg(rd),
			instr_map[instr][opcode]
		])

	@staticmethod
	def immediate(imm):
		return format(int(imm) >> 12, '013b')

class _UJ(Instruction):
	def __repr__(self):
		return "UJ instruction"

	def __str__(self):
		return "UJ instruction"

	def compute_instr(self, instr, imm, rd):
		instr = super().check_instr_valid(instr, UJ_instr)
		opcode = 0
		
		return "".join([
			_UJ.immediate(imm),
			super().reg(rd),
			instr_map[instr][opcode]
		])

	@staticmethod
	def immediate(imm):
		mod_imm = format(((1 << 21) - 1) & int(imm), '021b')
		return mod_imm[20-20] + mod_imm[20-10:20-0] + mod_imm[20-11] + mod_imm[20-19:20-11]

class InstructionParser:
	def organize(self, *args):
		raise NotImplementedError()

	def __call__(self, *args):
		return self.organize(*args)

	@staticmethod
	def JUMP(tk : str, line_num : int, code: list) -> int:
		try:
			index, skip_labels = code.index(tk + ":"), 0
		except:
			raise Exception('''Address not found for {}! Provided assembly code could 
				be faulty, branch is expressed but not found in code.'''.format(tk))

		pos = 1
		if index > line_num: # forward search:
			skip_labels = sum([1 for i in range(line_num, index) if code[i][-1] == ":"])
		else: # backwards search
			skip_labels = -1 * sum([1 for i in range(index, line_num) if code[i][-1] == ":"])

		return (index - line_num - skip_labels) * 4 * pos

class _R_parse(InstructionParser):

	def __repr__(self):
		return "R Parser"

	def __str__(self):
		return "R Parser"

	def organize(self, tokens):
		instr, rs1, rs2, rd = tokens[0], reg_map[tokens[2]], reg_map[tokens[3]], reg_map[tokens[1]]
		return R(instr, rs1, rs2, rd)

class _I_parse(InstructionParser):

	def __repr__(self):
		return "I Parser"

	def __str__(self):
		return "I Parser"

	def organize(self, tokens):
		line_num, code = tokens[-2], tokens[-1]
		instr, rs1, imm, rd = tokens[0], None, None, None
		if instr == "jalr":
			if len(tokens) == 4+2:
				rs1, imm, rd = reg_map[tokens[2]], super().JUMP(tokens[3], line_num, code), reg_map[tokens[1]]
			else:
				rs1, imm, rd = reg_map[tokens[1]], 0, reg_map["x1"]
		elif instr == "lw":
			rs1, imm, rd = reg_map[tokens[3]], tokens[2], reg_map[tokens[1]]
		elif instr == 'ld':
			rs1, imm, rd = reg_map[tokens[3]], tokens[2], reg_map[tokens[1]]
		else:
			rs1, imm, rd = reg_map[tokens[2]], tokens[3], reg_map[tokens[1]]

		return I(instr, rs1, imm, rd)

class _S_parse(InstructionParser):

	def __repr__(self):
		return "S Parser"

	def __str__(self):
		return "S Parser"

	def organize(self, tokens):
		instr, rs1, rs2, imm = tokens[0], reg_map[tokens[3]], reg_map[tokens[1]], tokens[2]
		return S(instr, rs1, rs2, imm)

class _SB_parse(InstructionParser):

	def __repr__(self):
		return "SB Parser"

	def __str__(self):
		return "SB Parser"

	def organize(self, tokens):
		line_num, code = tokens[-2], tokens[-1]
		instr, rs1, rs2, imm = tokens[0], reg_map[tokens[1]], reg_map[tokens[2]], super().JUMP(tokens[3], line_num, code)
		return SB(instr, rs1, rs2, imm)

class _U_parse(InstructionParser):

	def __repr__(self):
		return "U Parser"

	def __str__(self):
		return "U Parser"

	def organize(self, tokens):
		instr, imm, rd = tokens[0], tokens[1], reg_map[tokens[2]]
		return U(instr, imm, rd)

class _UJ_parse(InstructionParser):

	def __repr__(self):
		return "UJ Parser"

	def __str__(self):
		return "UJ Parser"

	def organize(self, tokens):
		line_num, code = tokens[-2], tokens[-1]
		instr, imm, rd = tokens[0], None, None
		if len(tokens) == 3:
			imm, rd = super().JUMP(tokens[2], line_num, code), reg_map[tokens[1]]
		else:
			imm, rd = super().JUMP(tokens[1], line_num, code), reg_map["x1"]

		return UJ(instr, imm, rd)

class _Pseudo_parse(InstructionParser):

	def __repr__(self):
		return "Pseudo Parser"

	def __str__(self):
		return "Pseudo Parser"

	def organize(self, tokens):
		# better way to organize, express, abstract pseudo?
		instr = tokens[0]
		line_num, code = tokens[-2], tokens[-1]
		if instr == 'nop':
			rs1, imm, rd = reg_map["x0"], 0, reg_map["x0"]
			return I("addi", rs1, imm, rd)
		elif instr == "mv":
			rs1, imm, rd = reg_map[tokens[2]], 0, reg_map[tokens[1]]
			return I("addi", rs1, imm, rd)
		elif instr == "not":
			rs1, imm, rd = reg_map[tokens[2]], -1, reg_map[tokens[1]]
			return I("xori", rs1, imm, rd)
		elif instr == "neg":
			rs1, rs2, rd = reg_map["x0"], reg_map[tokens[2]], reg_map[tokens[1]]
			return R("sub", rs1, rs2, rd)
		elif instr == "j":
			return UJ("jal", super().JUMP(tokens[1], line_num, code), "x0")
		elif instr == "li":
			# This is missing addi rd rd -273
			return U("lui", tokens[2], reg_map[tokens[1]])
			# I("addi", reg_map[tokens[1]], reg_map[tokens[1]], tokens[2])

		raise Exception("Bad Instruction provided, {} does not exist or has not been implemented here yet.".format(instr))


def register_map():
	path = Path(__file__).parent / "data/reg_map.dat"
	rmap = {}

	f = open(path, "r")
	line = f.readline()
	while line != "":
		e = line.split()
		rmap[e[0]] = e[1] 
		line = f.readline()
	f.close()

	return rmap

def instruction_map():
	path = Path(__file__).parent / "data/instr_data.dat"
	imap = {}

	f = open(path, "r")
	line = f.readline()
	while line != "":
		e = line.split()
		imap[e[0]] = e[1:]
		line = f.readline()
	f.close()

	return imap


R, I, S, SB, U, UJ = _R(), _I(), _S(), _SB(), _U(), _UJ()
Rp, Ip, Sp, SBp, Up, UJp, Psp = _R_parse(), _I_parse(), _S_parse(), _SB_parse(), _U_parse(), _UJ_parse(), _Pseudo_parse()
reg_map, instr_map = register_map(), instruction_map()


R_instr = [
	"add","sub", "sll", 
	"sltu", "xor", "srl", 
	"sra", "or", "and",
	"addw", "subw", "sllw",
	"slrw", "sraw", "mul",
	"mulh", "mulu", "mulsu",
	"div", "divu", "rem",
	"remu"
]
I_instr = [
	"addi", "lb", "lw",
	"ld", "lbu", "lhu",
	"lwu", "fence", "fence.i", 
	"slli", "slti", "sltiu", 
	"xori", "slri", "srai",
	"ori", "andi", "addiw",
	"slliw", "srliw", "sraiw", 
	"jalr", "ecall", "ebreak", 
	"CSRRW", "CSRRS","CSRRC", 
	"CSRRWI", "CSRRSI", "CSRRCI" 
]
S_instr = [
	"sw", "sb", "sh", 
	"sd"
]
SB_instr = [
	"beq", "bne", "blt", 
	"bge", "bltu", "bgeu"
]

U_instr = ["auipc", "lui"]

UJ_instr = ["jal"]

pseudo_instr = [
	"beqz", "bnez", "li", 
	"mv", "j", "jr", 
	"la", "neg", "nop", 
	"not", "ret", "seqz", 
	"snez", "bgt", "ble"
]