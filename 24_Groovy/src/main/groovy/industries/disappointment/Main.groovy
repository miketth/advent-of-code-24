package industries.disappointment

static ParsedFile readFile(String filename) {
    var contents = new File(filename).text.split("\n\n")
    var initialValuesString = contents[0].split("\n")
    var networkString = contents[1].split("\n")

    var initial = new HashMap<String, Integer>()

    initialValuesString.each {
        var parts = it.split(": ")
        initial[parts[0]] = parts[1].toInteger()
    }

    var calculated = new HashMap<String, CalculatedWire>()

    networkString.each {
        var parts = it.split(" ")
        var source1 = parts[0]
        var op = parts[1]
        var source2 = parts[2]
        var name = parts[4]

        var wire = new CalculatedWire(
                source1,
                source2,
                Operation.toOperation(op)
        )
        calculated[name] = wire
    }

    return new ParsedFile(initial, calculated)
}

static Long solve(ParsedFile data) {
    while (!data.remaining().isEmpty()) {
        var toRemove = new ArrayList<String>()
        data.remaining().each { k, v ->
            if (data.solved().containsKey(v.source1()) && data.solved().containsKey(v.source2())) {
                var a = data.solved()[v.source1()]
                var b = data.solved()[v.source2()]
                var s = v.operation().doOp(a, b)
                data.solved()[k] = s
                toRemove.add(k)
            }
            return
        }
        toRemove.each {
            data.remaining().remove(it)
        }
    }

    var zs = new ArrayList<String>()
    data.solved().each { k, v ->
        if (k[0] == 'z') {
            zs.add(k)
        }
        return
    }

    zs = zs.sort()
    zs = zs.reverse()

    var ret = 0l

    zs.each { k ->
        var v = data.solved()[k]
        ret <<= 1
        ret += v
    }

    return ret
}


static void main(String[] args) {
//    var filename = "input_sample.txt"
    var filename = "input.txt"
    var data = readFile(filename)
    var solution = solve(data)
    println(solution)
}
