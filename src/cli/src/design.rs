//! design：机制设计——从结构化需求生成机制规格
//!
//! 依据 context/default/design-models.md 的思维模式：
//! 设计者思维——把问题设计成"达到均衡的算法"（规则集），
//! 输出对齐 Mechanism 模型（players/strategies/rules/objectives）。

use crate::llm;
use serde::{Deserialize, Serialize};

/// 输出：机制设计规格（对齐 Mechanism 模型）
#[derive(Debug, Serialize, Deserialize)]
pub struct MechanismSpec {
    pub id: String,
    pub name: String,
    pub description: String,
    pub players: Vec<SpecPlayer>,
    pub strategies: Vec<SpecStrategy>,
    pub rules: Vec<SpecRule>,
    pub objectives: Vec<SpecObjective>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SpecPlayer {
    pub id: String,
    pub name: String,
    pub role: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SpecStrategy {
    pub id: String,
    #[serde(rename = "player_id")]
    pub player_id: String,
    pub name: String,
    pub description: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SpecRule {
    pub id: String,
    pub name: String,
    pub description: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SpecObjective {
    pub id: String,
    pub name: String,
    pub description: String,
}

const SYSTEM_PROMPT: &str = r#"你是机制设计工程师。把结构化需求设计为一套机制规则（"达到均衡的算法"）：让不同类型参与者在规则下各自最优决策时，系统收敛到设计者期望的均衡。

只输出 JSON，结构如下（对齐 Mechanism 模型）：
{
  "id": "机制 id（snake_case）",
  "name": "机制名",
  "description": "机制一句话描述",
  "players": [{"id": "player id", "name": "参与者名", "role": "角色（博弈方/机制设计者等）"}],
  "strategies": [{"id": "strategy id", "player_id": "所属参与者 id", "name": "策略名", "description": "策略描述"}],
  "rules": [{"id": "rule id", "name": "规则名", "description": "规则描述（策略组合→结果，含分离均衡设计）"}],
  "objectives": [{"id": "objective id", "name": "目标名", "description": "设计目标描述"}]
}

设计要求：
- 规则要能制造分离均衡（让不同类型自我暴露、各走其道）
- 激励工具（内部货币等）要落入规则
- 类型转化路径（如白嫖者→付费客户）要设计进规则"#;

/// 设计：需求 → 机制规格
pub fn design(req_json: &str) -> Result<MechanismSpec, String> {
    let user = format!("请基于以下需求设计机制规格：\n\n{req_json}");
    let content = llm::llm_json(SYSTEM_PROMPT, &user)?;
    serde_json::from_str(&content).map_err(|e| format!("规格解析失败：{e}\n原始输出：{content}"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn design_parse_roundtrip() {
        let spec = MechanismSpec {
            id: "test-mechanism".into(),
            name: "测试机制".into(),
            description: "测试".into(),
            players: vec![SpecPlayer {
                id: "p1".into(),
                name: "参与者1".into(),
                role: "博弈方".into(),
            }],
            strategies: vec![SpecStrategy {
                id: "s1".into(),
                player_id: "p1".into(),
                name: "策略A".into(),
                description: "描述".into(),
            }],
            rules: vec![SpecRule {
                id: "r1".into(),
                name: "规则A".into(),
                description: "描述".into(),
            }],
            objectives: vec![SpecObjective {
                id: "o1".into(),
                name: "目标A".into(),
                description: "描述".into(),
            }],
        };
        let json = serde_json::to_string(&spec).expect("序列化");
        let back: MechanismSpec = serde_json::from_str(&json).expect("反序列化");
        assert_eq!(back.players[0].name, "参与者1");
        assert_eq!(back.strategies[0].player_id, "p1");
    }
}
