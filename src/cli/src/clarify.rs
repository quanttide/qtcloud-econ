//! clarify：需求澄清——从模糊的业务描述提取机制设计骨架
//!
//! 依据 context/default/clarify-models.md 的思维模式：
//! 识别直觉语言之下的机制设计要素（代理人类型、委托人目标、信号空间、内部货币）。

use crate::llm;

/// 输出：结构化需求
#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct ClarifiedRequirement {
    pub problem: String,
    pub agent_types: Vec<AgentType>,
    pub principal_objective: String,
    pub signal_space: String,
    pub incentive_tools: Vec<String>,
    pub constraints: Vec<String>,
    pub closed_loop: Vec<String>,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct AgentType {
    #[serde(rename = "type")]
    pub type_name: String,
    pub private_info: String,
    pub utility: String,
}

const SYSTEM_PROMPT: &str = r#"你是机制设计专家。从用户模糊的业务描述中，识别其语言之下已经成型的机制设计骨架，并显性化为结构化 JSON。

只输出 JSON，结构如下：
{
  "problem": "重构后的问题（从局部问题提升为系统/价值交换问题）",
  "agent_types": [
    {"type": "代理人类型名", "private_info": "私有信息（真实动机）", "utility": "效用函数（图什么）"}
  ],
  "principal_objective": "委托人目标函数（可观测的行为锚点）",
  "signal_space": "信号空间设计（昂贵且能暴露深层特质的信号）",
  "incentive_tools": ["激励工具列表（如内部货币：边际成本低、对方价值高的载体）"],
  "constraints": ["约束及如何放松"],
  "closed_loop": ["闭环步骤（识别异质性→设计信号→创造激励→实现分离→价值闭环）"]
}"#;

/// 澄清：模糊描述 → 结构化需求
pub fn clarify(input_md: &str) -> Result<ClarifiedRequirement, String> {
    let user = format!("请分析以下业务描述，提取机制设计骨架：\n\n{input_md}");
    let content = llm::llm_json(SYSTEM_PROMPT, &user)?;
    serde_json::from_str(&content).map_err(|e| format!("需求解析失败：{e}\n原始输出：{content}"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn clarify_parse_roundtrip() {
        let req = ClarifiedRequirement {
            problem: "测试问题".into(),
            agent_types: vec![AgentType {
                type_name: "白嫖型".into(),
                private_info: "想免费学".into(),
                utility: "学习资源".into(),
            }],
            principal_objective: "招到留得住的人".into(),
            signal_space: "微型创业".into(),
            incentive_tools: vec!["培训额度".into()],
            constraints: vec!["预算约束".into()],
            closed_loop: vec!["识别→分离".into()],
        };
        let json = serde_json::to_string(&req).expect("序列化");
        let back: ClarifiedRequirement = serde_json::from_str(&json).expect("反序列化");
        assert_eq!(back.agent_types[0].type_name, "白嫖型");
    }
}
