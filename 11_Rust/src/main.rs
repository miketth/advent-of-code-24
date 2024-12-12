use std::fs::File;
use std::collections::HashMap;
use std::error::Error;
use std::io::{BufRead, BufReader};

type SolveMap = HashMap<u64, u64>;
type Memo = HashMap<u64, SolveMap>;


fn main() -> Result<(), Box<dyn Error>> {
    let nums = read_file("input.txt")?;
    let mut memo = HashMap::new();
    
    let sum_1: u64 = nums.iter()
        .map(|x| chain_len(*x, 0, 25, &mut memo))
        .sum();
    
    println!("{}", sum_1);

    let sum_2: u64 = nums.iter()
        .map(|x| chain_len(*x, 0, 75, &mut memo))
        .sum();

    println!("{}", sum_2);

    Ok(())
}

fn chain_len(num: u64, depth: u64, max_depth: u64, memo: &mut Memo) -> u64 {
    if depth > max_depth {
        panic!("oof")
    }
    
    if depth == max_depth {
        return 1;
    }

    let depth_to_go = max_depth - depth;
    
    match memo.get(&num) {
        None => {}
        Some(depth_map) => {
            match depth_map.get(&depth_to_go) {
                None => {}
                Some(solution) => {
                    return *solution;
                }
            }
        }
    }
    
    if num == 0 {
        let solution = chain_len(1, depth + 1, max_depth, memo);
        update_memo(num, depth_to_go, memo, solution);
        return solution;
    }
    
    let digs = digits(num);
    if digs % 2 == 0 {
        let exponent: u64 = 10_u64.pow(digs / 2);
        let left_half = num / exponent;
        let right_half = num % exponent;
        
        let left_len = chain_len(left_half, depth + 1, max_depth, memo);
        let right_len = chain_len(right_half, depth + 1, max_depth, memo);
        
        let soution = left_len + right_len;
        update_memo(num, depth_to_go, memo, soution);
        return soution;
    }
    
    let solution = chain_len(num*2024, depth + 1, max_depth, memo);
    update_memo(num, depth_to_go, memo, solution);
    return solution;
}

fn update_memo(num: u64, depth_to_go: u64, memo: &mut Memo, solution: u64) {
    let val = memo.entry(num).or_insert(SolveMap::new());
    val.insert(depth_to_go, solution);
}

fn digits(num: u64) -> u32 {
    if num == 0 {
        return 1
    }

    (num as f64).log10().floor() as u32 + 1
}

fn read_file(path: &str) -> Result<Vec<u64>, Box<dyn Error>> {
    let file = File::open(path)?;
    
    let mut reader = BufReader::new(file);
    let mut line = String::new();
    reader.read_line(&mut line)?;
    
    let nums = line
        .split_whitespace()
        .map(|item| item.parse::<u64>())
        .collect::<Result<_, _>>()?;
    Ok(nums)
}
