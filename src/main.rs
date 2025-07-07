use axum::{
  routing::get,
  Router,
};
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
  let app: Router = Router::new()
    .route("/", get(|| async {
      "Hello, world!"}
    ));

  let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();
  axum::serve(listener, app).await.unwrap();
}
