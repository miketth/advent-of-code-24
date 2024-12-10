def main():
    data = read_file("input.txt").strip("\n")
    blocks = process(data)
    blocks = merge_free(blocks)
    defrag(blocks)
    check = checksum(blocks)
    print(check)


def read_file(filename):
    with open(filename) as f:
        return f.read()


def process(data):
    out = []
    for i, item in enumerate(list(data)):
        num = int(item)
        if num > 0:
            if i % 2 == 0:
                out.append({"type": "file", "file_id": int(i/2), "size": int(item)})
            else:
                out.append({"type": "free", "size": int(item)})

    return out


def merge_free(blocks):
    out = []

    prev = blocks[0]
    for block in blocks[1:]:
        if block["type"] == "free" and prev["type"] == "free":
            prev["size"] += block["size"]
        else:
            out.append(prev)
            prev = block
    out.append(prev)
    return out

def defrag(blocks):
    used_blocks = []
    for block in blocks:
        if block["type"] != "free":
            used_blocks.append(block)

    used_blocks = reversed(used_blocks)

    for to_be_moved in used_blocks:
        index = blocks.index(to_be_moved)
        for block_idx, block in enumerate(blocks):
            if block["type"] == "free" and block["size"] >= to_be_moved["size"] and index > block_idx:
                blocks.pop(index)
                blocks.insert(index, {"type": "free", "size": to_be_moved["size"]})
                blocks.insert(block_idx, to_be_moved)
                block["size"] -= to_be_moved["size"]
                #print_blocks(blocks)
                break


def checksum(blocks):
    block_flat = []
    for block in blocks:
        block_flat += [block]*block["size"]

    blocks_sum = 0
    for i, block in enumerate(block_flat):
        if block["type"] == "file":
            blocks_sum += block["file_id"] * i

    return blocks_sum

def print_blocks(blocks):
    for block in blocks:
        if block["type"] == "free":
            print("."*block["size"], end='')
        else:
            print(str(block["file_id"])*block["size"], end='')
    print()

if __name__ == '__main__':
    main()