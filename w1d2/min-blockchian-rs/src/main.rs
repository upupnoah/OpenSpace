// use axum::{
//     routing::{get, post},
//     Json, Router,
// };
// use serde::{Deserialize, Serialize};
// use std::{net::SocketAddr, sync::Arc};
// use tokio::{net::TcpListener, sync::RwLock};
// use uuid::Uuid;

// #[derive(Serialize, Deserialize, Debug, Clone)]
// struct Transaction {
//     sender: String,
//     recipient: String,
//     amount: usize,
// }

// #[derive(Serialize, Deserialize, Debug, Clone)]
// struct Block {
//     index: usize,
//     timestamp: f64,
//     transactions: Vec<Transaction>,
//     proof: usize,
//     previous_hash: String,
// }

// #[derive(Clone)]
// struct Blockchain {
//     current_transactions: Vec<Transaction>,
//     chain: Vec<Block>,
//     nodes: Vec<String>,
// }

// impl Blockchain {
//     fn new() -> Self {
//         let mut blockchain = Blockchain {
//             current_transactions: vec![],
//             chain: vec![],
//             nodes: vec![],
//         };
//         blockchain.new_block(100, Some("1".to_string()));
//         blockchain
//     }

//     fn new_block(&mut self, proof: usize, previous_hash: Option<String>) -> Block {
//         let block = Block {
//             index: self.chain.len() + 1,
//             timestamp: now_as_f64(),
//             transactions: self.current_transactions.clone(),
//             proof,
//             previous_hash: previous_hash.unwrap_or_else(|| self.hash(self.chain.last().unwrap())),
//         };
//         self.current_transactions.clear();
//         self.chain.push(block.clone());
//         block
//     }

//     fn new_transaction(&mut self, sender: String, recipient: String, amount: usize) -> usize {
//         self.current_transactions.push(Transaction {
//             sender,
//             recipient,
//             amount,
//         });
//         self.last_block().unwrap().index + 1
//     }

//     fn last_block(&self) -> Option<&Block> {
//         self.chain.last()
//     }

//     fn hash(&self, block: &Block) -> String {
//         let block_string = serde_json::to_string(block).unwrap();
//         format!("{:x}", md5::compute(block_string))
//     }
// }

// async fn mine_handler(blockchain: Arc<RwLock<Blockchain>>) -> Json<Block> {
//     let mut blockchain = blockchain.write().await;
//     let last_block = blockchain.last_block().unwrap().clone();
//     let proof = blockchain.proof_of_work(last_block.proof);
//     let new_block = blockchain.new_block(proof, None);
//     Json(new_block)
// }

// #[tokio::main]
// async fn main() {
//     let blockchain = Arc::new(RwLock::new(Blockchain::new()));
//     let app = Router::new()
//         .route("/mine", get(mine_handler));
//         // 添加其他路由处理程序
//         // .layer(Extension(blockchain));
//     let addr = SocketAddr::from(([127, 0, 0, 1], 10500));
//     let listener = TcpListener::bind(addr).await.unwrap();
//     println!("Listening on {addr}");
//     axum::serve(listener, app.into_make_service()).await.unwrap();
// }

mod error;
mod model;
fn main() {
    
}
