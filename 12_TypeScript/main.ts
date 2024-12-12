
// const inputPath = "input_sample.txt"
const inputPath = "input.txt"

async function main(): Promise<void> {
  const data = await loadFile(inputPath)
  const plots = convert(data)
  const regions = divideRegions(plots)
  const allCosts = regions
      .reduce((acc, item) => acc + item.cost, 0)
  console.log(allCosts)

  const allCosts2 = regions
      .reduce((acc, item) => acc + item.discountedCost, 0)
  console.log(allCosts2)
}

enum Side {
  Up, Down, Left, Right
}

class Fence {
  public x: number
  public y: number
  public side: Side
  constructor(x: number, y: number, side: Side) {
    this.x = x
    this.y = y
    this.side = side
  }
  neighbour(fence: Fence): boolean {
    if (this.x == fence.x && this.y == fence.y) {
      return false
    }
    if (this.side != fence.side) {
      return false
    }
    if (this.y == fence.y) {
      return Math.abs(this.x - fence.x) == 1
    }
    if (this.x == fence.x) {
      return Math.abs(this.y - fence.y) == 1
    }
    return false
  }
}

class Plot {
  public neighbours: Plot[] = []
  public name: string
  public x: number
  public y: number
  constructor(name: string, x: number, y: number) {
    this.name = name
    this.x = x
    this.y = y
  }

  get fenceCount(): number {
    return 4 - this.neighbours
        .filter(it => it.name === this.name)
        .length
  }

  get fences(): Fence[] {
    const [ x, y ] = [this.x, this.y]
    const neigbourPlots = [
          { x: x-1, y, side: Side.Left },
          { x: x+1, y, side: Side.Right },
          { x, y: y-1, side: Side.Up },
          { x, y: y+1, side: Side.Down },
    ].map(it => new Fence(it.x, it.y, it.side));

    return neigbourPlots
        .filter(fence => {
          return !this.neighbours
              .filter(it => it.name == this.name)
              .some(plot => plot.x == fence.x && plot.y == fence.y)
        })
  }
}

function convert(data: string[][]): Plot[] {
  const map: Plot[][] = []
  data.forEach((row, y) => {
    const mapRow: Plot[] = []
    map.push(mapRow)

    row.forEach((cell, x) => {
      const plot = new Plot(cell, x, y)
      if (y > 0) {
        const neighbour = map[y-1][x]
        plot.neighbours.push(neighbour)
        neighbour.neighbours.push(plot)
      }
      if (x > 0) {
        const neighbour = map[y][x-1]
        plot.neighbours.push(neighbour)
        neighbour.neighbours.push(plot)
      }
      mapRow.push(plot)
    })
  })

  return map.flat()
}

class Region {
  public plots: Plot[] = []
  public name: string
  constructor(name: string) {
    this.name = name;
  }

  get fence() {
    return this.plots
        .reduce((acc, it) => acc + it.fenceCount, 0)
  }
  get area() {
    return this.plots.length
  }
  get cost() {
    return this.fence * this.area
  }
  get discountedCost() {
    const allFences = this.plots.map(plot => plot.fences).flat()

    const fencesMerged: Fence[][] = [];
    const needJoin: number[][] = []
    allFences.forEach((fence) => {
      let merged = -1
      fencesMerged.forEach((line,i ) => {
        if (line.some(it => it.neighbour(fence))) {
          line.push(fence)
          if (merged != -1) {
            needJoin.push([merged, i])
          }
          merged = i
        }
      })
      if (merged == -1) {
        fencesMerged.push([fence])
      }
    })

    const needJoinPenalty = needJoin.reduce((acc, it) => acc + it.length - 1,0)

    const sides = fencesMerged.length - needJoinPenalty;
    return sides * this.area;
  }
}

function divideRegions(plots: Plot[]): Region[] {
  const regions: Region[] = []
  const checkedPlots: Plot[] = []

  plots.forEach((plot) => {
    if (checkedPlots.includes(plot)) {
      return
    }

    const region = new Region(plot.name)
    checkPlot(plot, region, checkedPlots)
    regions.push(region)
  })

  return regions
}

function checkPlot(plot: Plot, region: Region, checkedPlots: Plot[]): void {
  if (plot.name != region.name) {
    return
  }

  if (checkedPlots.includes(plot)) {
    return
  }

  region.plots.push(plot)
  checkedPlots.push(plot)

  plot.neighbours.forEach((neighbour) => {
    checkPlot(neighbour, region, checkedPlots)
  })
}

async function loadFile(path: string): Promise<string[][]> {
  const decoder = new TextDecoder("utf-8");
  const data = await Deno.readFile(path);
  return decoder
      .decode(data)
      .split(/\n/)
      .filter(l => l !== "")
      .map((line) => line.split(""));
}


if (import.meta.main) {
  await main()
}
