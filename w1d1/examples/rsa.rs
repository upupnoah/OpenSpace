use rsa::pkcs1v15::SigningKey;
use rsa::sha2::{Digest, Sha256};
use rsa::signature::{Keypair, RandomizedSigner, SignatureEncoding, Verifier};
use rsa::RsaPrivateKey;

fn main() {
    let mut rng = rand::thread_rng();

    let bits = 2048;
    let private_key = RsaPrivateKey::new(&mut rng, bits).expect("failed to generate a key");
    let signing_key = SigningKey::<Sha256>::new(private_key);
    let verifying_key = signing_key.verifying_key();

    // Sign
    let (_, data) = find_valid_nonce("Noah");
    let signature = signing_key.sign_with_rng(&mut rng, &data);
    assert_ne!(signature.to_bytes().as_ref(), data.as_slice());

    // Verify
    match verifying_key.verify(&data, &signature) {
        Ok(_) => println!("Verification successful! 🎉"),
        Err(e) => println!("Verification failed: {}", e),
    }
}

// 计算符合 POW 的 nonce
fn find_valid_nonce(nickname: &str) -> (usize, Vec<u8>) {
    let mut nonce = 0;
    loop {
        let data = format!("{}{}", nickname, nonce).into_bytes();
        let digest = Sha256::digest(&data);
        let hex_digest = format!("{:x}", digest);
        if hex_digest.starts_with("0000") {
            return (nonce, data);
        }
        nonce += 1;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use log::{debug, info};

    // 在测试前运行日志初始化
    pub fn setup() {
        let _ = env_logger::builder().is_test(true).try_init();
    }

    #[test]
    fn test_find_valid_nonce() {
        setup();
        let nickname = "Noah";
        let (nonce, data) = find_valid_nonce(nickname);
        let digest = Sha256::digest(&data);
        let hex_digest = format!("{:x}", digest);

        // 使用日志记录输出
        info!("Nonce found: {}", nonce);
        // info!("Data: {}", data);

        assert!(hex_digest.starts_with("0000"));
    }
}
