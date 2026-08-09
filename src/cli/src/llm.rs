//! LLM 调用——DeepSeek API（OpenAI 兼容）

use serde::{Deserialize, Serialize};

const API_URL: &str = "https://api.deepseek.com/chat/completions";
const DEFAULT_MODEL: &str = "deepseek-v4-flash";

#[derive(Serialize)]
struct ChatRequest {
    model: String,
    messages: Vec<Message>,
    temperature: f64,
    #[serde(rename = "response_format")]
    response_format: ResponseFormat,
}

#[derive(Serialize)]
struct Message {
    role: String,
    content: String,
}

#[derive(Serialize)]
struct ResponseFormat {
    #[serde(rename = "type")]
    format_type: String,
}

#[derive(Deserialize)]
struct ChatResponse {
    choices: Vec<Choice>,
}

#[derive(Deserialize)]
struct Choice {
    message: ResponseMessage,
}

#[derive(Deserialize)]
struct ResponseMessage {
    content: String,
}

/// 调用 LLM，要求返回 JSON 对象
pub fn llm_json(system: &str, user: &str) -> Result<String, String> {
    let api_key =
        std::env::var("DEEPSEEK_API_KEY").map_err(|_| "DEEPSEEK_API_KEY 未设置".to_string())?;

    let req = ChatRequest {
        model: DEFAULT_MODEL.to_string(),
        messages: vec![
            Message {
                role: "system".into(),
                content: system.to_string(),
            },
            Message {
                role: "user".into(),
                content: user.to_string(),
            },
        ],
        temperature: 0.1,
        response_format: ResponseFormat {
            format_type: "json_object".into(),
        },
    };

    let client = reqwest::blocking::Client::new();
    let resp = client
        .post(API_URL)
        .bearer_auth(&api_key)
        .json(&req)
        .send()
        .map_err(|e| format!("llm 请求失败：{e}"))?;

    if !resp.status().is_success() {
        return Err(format!(
            "llm 返回 {}：{}",
            resp.status(),
            resp.text().unwrap_or_default()
        ));
    }

    let body: ChatResponse = resp.json().map_err(|e| format!("llm 响应解析失败：{e}"))?;
    body.choices
        .first()
        .map(|c| c.message.content.trim().to_string())
        .ok_or_else(|| "llm 无输出".to_string())
}
