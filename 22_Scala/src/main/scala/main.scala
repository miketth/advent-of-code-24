import scala.annotation.tailrec
import scala.io.Source

//val filename = "input_sample.txt"
val filename = "input.txt"

@main
def main(): Unit =
  val nums = readFile(filename)

  val finalSecrets = nums.map(n => nthSecretNum(n, 2000))
  val sum = finalSecrets.sum()
  println(sum)

  val prices = nums.map(n => pricesForNIter(n, 2000))
  val diffs = prices.map(p => calcDiffs(p));

  val value = bruteForce(prices, diffs)

  println(value)

def bruteForce(prices: List[List[Int]], diffs: List[List[Int]]): Int =
  val possible = -9 to 9
  val matchingRanges = (for (d1 <- possible) yield {
    println(s"Trying ${d1}")
    val rangesStartingWith1 = diffs.map(d => d.zipWithIndex.dropRight(3).filter((v, idx) => v == d1).map((v, idx) => idx))
    for (d2 <- possible) yield {
      val rangesStartingWith12 = diffs.zip(rangesStartingWith1).map((d, ranges) => {
        val goodRanges = ranges.filter(idx => d(idx+1) == d2)
        (d, goodRanges)
      })
      for (d3 <- possible) yield {
        val rangesStartingWith123 = rangesStartingWith12.map((d, ranges) => {
          val goodRanges = ranges.filter(idx => d(idx+2) == d3)
          (d, goodRanges)
        })
        for (d4 <- possible) yield {
          val indexesMatching1234 = rangesStartingWith123.map((d, ranges) => {
            val goodRanges = ranges.filter(idx => d(idx+3) == d4)
            if (goodRanges.isEmpty) {
              -1
            } else {
              goodRanges.head
            }
          })

          val pricePerVendor = prices
            .zip(indexesMatching1234)
            .filter((p, idx) => idx != -1)
            .map((p, idx) => p(idx+4))
          pricePerVendor.sum
        }
      }
    }.flatten
  }.flatten).flatten
  matchingRanges.max


def generateAllDiffs(): List[List[Int]] =
  val possible = -9 to 9
  (for (d1 <- possible)
    yield for (d2 <- possible)
      yield for (d3 <- possible)
        yield for (d4 <- possible)
          yield List(d1, d2, d3, d4)).flatten.flatten.flatten.toList

def checkSolution(prices: List[List[Int]], diffs: List[List[Int]], solution: List[Int]): Int =
  val indexes = diffs.map(d => d.indexOfSlice(solution))
  prices.zip(indexes).map((p, idx) => getWithIndexOrZero(p, idx, solution.length)).sum()

def getWithIndexOrZero(p: List[Int], idx: Int, offset: Int): Int =
  if (idx < 0) {
    return 0
  }

  p(idx+offset)

def pricesForNIter(start: BigInt, n: Int): List[Int] =
  val emptyList = List[Int]()
  val rev = pricesForNIterHelper(start, n, emptyList)
  rev.reverse

@tailrec
def pricesForNIterHelper(start: BigInt, n: Int, ret: List[Int]): List[Int] =
  if (n == 0) {
    return ret
  }

  val digit = start % 10
  val next = ret.prepended(digit.toInt)

  val current = nextSecretNum(start)
  pricesForNIterHelper(current, n-1, next)


def calcDiffs(prices: List[Int]): List[Int] =
  val pricesShifted = prices.prepended(0)
  pricesShifted.zip(prices).map((a, b) => b - a).drop(1)


@tailrec
def nthSecretNum(start: BigInt, n: Int): BigInt =
  if (n == 0) {
    return start
  }

  val next = nextSecretNum(start)
  nthSecretNum(next, n-1)

def readFile(filename: String): List[BigInt] =
  val src = Source.fromFile(filename)
  val nums = src
    .getLines()
    .map(s => BigInt(s.toInt))
    .toList
  src.close()
  nums

def nextSecretNum(n: BigInt): BigInt =
  val multiplied = n * 64
  val mixed = n ^ multiplied
  val pruned = mixed % 16777216
  val step1 = pruned

  val divided = step1 / 32
  val mixed_2 = step1 ^ divided
  val pruned_2 = mixed_2 % 16777216
  val step2 = pruned_2

  val multiplied_3 = step2 * 2048
  val mixed_3 = step2 ^ multiplied_3
  val pruned_3 = mixed_3 % 16777216

  pruned_3