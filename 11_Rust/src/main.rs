use std::fs::File;
use std::{io, num};
use std::io::{BufRead, BufReader};

fn main() -> Result<(), FileParseError> {
    let nums = read_file("input.txt")?;
    
    let sum: u64 = nums.iter()
        .map(|x| chain_len(*x, 0, 25))
        .sum();
    
    println!("{}", sum);

    Ok(())
}

fn chain_len(num: u64, depth: u64, max_depth: u64) -> u64 {
    if depth > max_depth {
        panic!("oof")
    }
    
    if depth == max_depth {
        return 1;
    }
    
    
    if num == 0 {
        return chain_len(1, depth + 1, max_depth);
    }
    
    let digs = digits(num);
    if digs % 2 == 0 {
        let exponent: u64 = 10_u64.pow(digs / 2);
        let left_half = num / exponent;
        let right_half = num % exponent;
        
        let left_len = chain_len(left_half, depth + 1, max_depth);
        let right_len = chain_len(right_half, depth + 1, max_depth);
        return left_len + right_len;
    }
    
    return chain_len(num*2024, depth + 1, max_depth);
}

fn process(num: u64) -> Vec<u64> {
    if num == 0 {
        return vec![1]
    }

    let digs = digits(num);
    if digs % 2 == 0 {
        let exponent: u64 = 10_u64.pow(digs / 2);
        let left_half = num / exponent;
        let right_half = num % exponent;
        return vec![left_half, right_half];
    }

    vec![num * 2024]
}

fn digits(num: u64) -> u32 {
    if num == 0 {
        return 1
    }

    (num as f64).log10().floor() as u32 + 1
}

#[derive(Debug)]
enum FileParseError {
    IOError(io::Error),
    ParseError(num::ParseIntError),
} 

fn read_file(path: &str) -> Result<Vec<u64>, FileParseError> {
    let file = File::open(path)
        .map_err(|err| FileParseError::IOError(err))?;
    
    let mut reader = BufReader::new(file);
    let mut line = String::new();
    reader.read_line(&mut line)
        .map_err(|err| FileParseError::IOError(err))?;
    
    let nums = line
        .split_whitespace()
        .map(|item| item.parse::<u64>())
        .collect::<Result<_, _>>()
        .map_err(|err| FileParseError::ParseError(err))?;
    Ok(nums)
}
