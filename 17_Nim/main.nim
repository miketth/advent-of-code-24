import re, strutils, os, options, sequtils, math

# const inputFile = "input_sample.txt"
const inputFile = "input.txt"
let pattern = re(r"Register A: ([0-9]+)\nRegister B: ([0-9]+)\nRegister C: ([0-9]+)\n\nProgram: ([0-7,]+)")

type CPU = object
  registerA: int
  registerB: int
  registerC: int
  program: seq[int]
  instruction: int
  outputs: seq[int]

proc parseFile(path: string): Option[CPU] =
  let text = readFile(path)
  var matches: array[4, string]
  if text.find(pattern, matches) == 0:
    let cpu = CPU(
      registerA: parseInt(matches[0]),
      registerB: parseInt(matches[1]),
      registerC: parseInt(matches[2]),
      program: matches[3].split(',').map(parseInt),
      instruction: 0,
      outputs: @[],
    )
    return some(cpu)
  else:
    return none(CPU)

proc combo(cpu: var CPU, arg: int): int =
  case arg:
    of 0..3:
      return arg
    of 4:
      return cpu.registerA
    of 5:
      return cpu.registerB
    of 6:
      return cpu.registerC
    else:
      return -1

proc op_adv(cpu: var CPU, arg: int) =
  let numerator = cpu.registerA
  let denominator = 2 ^ cpu.combo(arg)
  cpu.registerA = numerator div denominator
proc op_bxl(cpu: var CPU, arg: int) =
  cpu.registerB = cpu.registerB xor arg
proc op_bst(cpu: var CPU, arg: int) =
  cpu.registerB = cpu.combo(arg) mod 8
proc op_jnz(cpu: var CPU, arg: int) =
  if cpu.registerA == 0:
    return
  cpu.instruction = arg - 2 # subtract 2 for normal progression
proc op_bxc(cpu: var CPU, arg: int) =
  cpu.registerB = cpu.registerB xor cpu.registerC
proc op_out(cpu: var CPU, arg: int) =
  let val = cpu.combo(arg) mod 8
  cpu.outputs.add(val)
proc op_bdv(cpu: var CPU, arg: int) =
  let numerator = cpu.registerA
  let denominator = 2 ^ cpu.combo(arg)
  cpu.registerB = numerator div denominator
proc op_cdv(cpu: var CPU, arg: int) =
  let numerator = cpu.registerA
  let denominator = 2 ^ cpu.combo(arg)
  cpu.registerC = numerator div denominator

proc run(cpu: var CPU): bool =
  while cpu.instruction < cpu.program.len:
    let instruction = cpu.program[cpu.instruction]
    let arg = cpu.program[cpu.instruction+1]
    case instruction:
      of 0:
        cpu.op_adv(arg)
      of 1:
        cpu.op_bxl(arg)
      of 2:
        cpu.op_bst(arg)
      of 3:
        cpu.op_jnz(arg)
      of 4:
        cpu.op_bxc(arg)
      of 5:
        cpu.op_out(arg)
      of 6:
        cpu.op_bdv(arg)
      of 7:
        cpu.op_cdv(arg)
      else:
        return false
    cpu.instruction += 2
  return true

proc main() =
  let parsed = parseFile(inputFile)
  if parsed.isSome:
    var cpu = parsed.get()
    if cpu.run():
      echo cpu.outputs.join(",")
    else:
      echo "CPU failed"

when isMainModule:
  main()