use chrono::prelude::*;
use sha2::{Digest, Sha256};

fn main() {
    let nickname = "Noah";
    let mut nonce = 0;
    let start_time = Utc::now();

    loop {
        let data = format!("{}{}", nickname, nonce);
        // println!("Data: {}", data);
        let mut hasher = Sha256::new();
        hasher.update(data.as_bytes());
        let result = hasher.finalize();
        let hex_result = format!("{:x}", result); // 将字节序列转换为十六进制字符串

        // 检查是否以四个0开头
        if hex_result.starts_with("0000") {
            let duration = Utc::now() - start_time;
            println!(
                "Time taken for 4 leading zeros: {} ms", // 毫秒
                duration.num_milliseconds()
            );
            println!("Hash content: {}", data);
            println!("Hash value: {}", hex_result);
            break;
        }

        nonce += 1;
    }

    let start_time_five_zeros = Utc::now();
    loop {
        let data = format!("{}{}", nickname, nonce);
        let mut hasher = Sha256::new();
        hasher.update(data.as_bytes());
        let result = hasher.finalize();
        let hex_result = format!("{:x}", result);

        // 检查是否以五个零开头
        if hex_result.starts_with("00000") {
            let duration = Utc::now() - start_time_five_zeros;
            println!(
                "Time taken for 5 leading zeros: {} ms", // 毫秒
                duration.num_milliseconds()
            );
            println!("Hash content: {}", data);
            println!("Hash value: {}", hex_result);
            break;
        }

        nonce += 1;
    }
}
