// const fileName = "input_sample.txt"
const fileName = "input.txt"
const verbose = false

async function main() {
    const data = await loadFile(fileName)
    if (verbose) {
        console.log(data)
    }
    const source = transpile(data.program)
    if (verbose) {
        console.log(source)
    }
    const program = eval(source)

    let asm = data.program.map((it) => BigInt(it))

    // get lower 10 bits
    let candidates = []
    let a = 0n
    while (a < 2n**10n) {
        let state = { ...data, a }
        const out = program(state)
        if (asm[0] === out[0]) {
            candidates.push(a)
        }
        a++
    }

    // prepend 3 bits a time
    for (let output = 1n; output < asm.length; output++) {
        let bitsFixed = (output*3n+7n)
        let increment = 1n << (bitsFixed - 1n);
        let nextCandidates = [];
        for (let i = 0; i < candidates.length; i++) {
            let a = candidates[i]
            while (a < 2n**(bitsFixed+3n)) {
                let state = { ...data, a }
                const out = program(state)
                if (arrayEqual(out, asm, output+1n)) {
                    if (!nextCandidates.includes(a)) {
                        nextCandidates.push(a)
                    }
                }
                a += increment
            }
        }
        candidates = nextCandidates

        if (verbose) {
            console.log(`Got ${output + 1n} bits`)
        }
    }

    candidates.sort((a, b) => Number(a - b))

    if (verbose) {
        console.log(candidates)
    }

    console.log(candidates[0].toString())
}

function arrayEqual(a, b, until) {
    if (!until) {
        until = b.length
    }
    for (let i = 0; i < until; i++) {
        if (a[i] !== b[i]) return false
    }
    return true
}

function transpile(program){
    let cpu = {
        a: 0,
        b: 0,
        c: 0,
        instruction: 0,
        out: [],
    }

    let instructions = []
    for (let i = 0; i < program.length; i+=2) {
        let opcode = program[i]
        let arg = program[i+1]

        instructions.push(genCode(cpu, opcode, arg))
    }

    let cases = instructions.map((instr, i) => {
        return `
            case ${i*2}:
                ${instr}
                break
        `
    }).join("\n")

    return `
({ a, b, c }) => {
    let instruction = 0
    let out = []
    while (instruction < ${program.length}) {
        switch (instruction) {
            ${cases}
            default:
                throw Error("segmentation fault")
        }
        instruction += 2
    }
    return out
}
    `

    return (startState) => {
        cpu.a = startState.a
        cpu.b = startState.b
        cpu.c = startState.c

        while (cpu.instruction < instructions.length * 2) {
            instructions[cpu.instruction / 2]()
            cpu.instruction += 2
        }

        return cpu.out
    }
}

function combo(cpu, arg) {
    if (arg >= 0 && arg <= 3) {
        return `${arg}n`
    }
    if (arg === 4) {
        return "a"
    }
    if (arg === 5) {
        return "b"
    }
    if (arg === 6) {
        return "c"
    }
    throw new Error("illegal combo argument")
}

function genAdv(cpu, arg) {
    return `a = a / (2n ** ${combo(cpu, arg)})`
}

function genBxl(cpu, arg) {
    return `b = b ^ ${arg}n`
}

function genBst(cpu, arg) {
    return `b = ${combo(cpu, arg)} % 8n`
}

function genJnz(cpu, arg) {
    return `if (a != 0) { instruction = ${arg} - 2 }`
}

function genBxc(cpu, arg) {
    return "b = b ^ c"
}

function genOut(cpu, arg) {
    return `out.push(${combo(cpu, arg)} % 8n)`
}

function genBdv(cpu, arg) {
    return `b = a / (2n ** ${combo(cpu, arg)})`
}

function genCdv(cpu, arg) {
    return `c = a / (2n ** ${combo(cpu, arg)})`
}

function genCode(cpu, opcode, arg) {
    switch (opcode) {
        case 0:
            return genAdv(cpu, arg)
        case 1:
            return genBxl(cpu, arg)
        case 2:
            return genBst(cpu, arg)
        case 3:
            return genJnz(cpu, arg)
        case 4:
            return genBxc(cpu, arg)
        case 5:
            return genOut(cpu, arg)
        case 6:
            return genBdv(cpu, arg)
        case 7:
            return genCdv(cpu, arg)
        default:
            return () => { throw Error("unknown opcode") }
    }
}

async function loadFile(fileName) {
    const decoder = new TextDecoder("utf-8")
    const data = await Deno.readFile(fileName)
    const text = decoder.decode(data)

    const regex = /Register A: ([0-9]+)\nRegister B: ([0-9]+)\nRegister C: ([0-9]+)\n\nProgram: ([0-7,]+)/
    const result = regex.exec(text)
    if (!result) {
        throw new Error(`Parsing failed`)
    }

    return {
        a: BigInt(result[1]),
        b: BigInt(result[2]),
        c: BigInt(result[3]),
        program: result[4].split(",").map(e => Number(e)),
    }
}

await main()
