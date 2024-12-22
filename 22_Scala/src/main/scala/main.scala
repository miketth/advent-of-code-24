import scala.annotation.tailrec
import scala.io.Source

//val filename = "input_sample.txt"
val filename = "input.txt"

@main
def main(): Unit =
  val nums = readFile(filename)

  val finalSecrets = nums
    .map(n => nthSecretNum(n, 2000))
  val sum = finalSecrets.sum()
  println(sum)

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