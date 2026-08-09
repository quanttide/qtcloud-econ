//! 机制（Mechanism）领域模型与数据访问——对齐 Studio 的 mechanisms.json 种子数据

use serde::Deserialize;
use std::path::Path;

/// 机制：完整博弈结构
#[derive(Debug, Clone, Deserialize)]
pub struct Mechanism {
    pub id: String,
    pub name: String,
    pub description: String,
    pub players: Vec<Player>,
    pub strategies: Vec<Strategy>,
    pub rules: Vec<Rule>,
    pub objectives: Vec<Objective>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Player {
    pub id: String,
    pub name: String,
    pub role: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Strategy {
    pub id: String,
    #[serde(rename = "player_id")]
    pub player_id: String,
    pub name: String,
    pub description: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Rule {
    pub id: String,
    pub name: String,
    pub description: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Objective {
    pub id: String,
    pub name: String,
    pub description: String,
}

/// 从 JSON 种子数据加载机制列表
pub fn load(path: &Path) -> Result<Vec<Mechanism>, String> {
    let raw =
        std::fs::read_to_string(path).map_err(|e| format!("读取 {} 失败：{e}", path.display()))?;
    let doc: MechanismDoc =
        serde_json::from_str(&raw).map_err(|e| format!("解析 {} 失败：{e}", path.display()))?;
    Ok(doc.mechanisms)
}

#[derive(Debug, Deserialize)]
struct MechanismDoc {
    mechanisms: Vec<Mechanism>,
}

/// 默认种子数据路径：CLI 独立维护的 mechanisms.json（src/cli/data/）
pub fn default_path() -> String {
    "src/cli/data/mechanisms.json".to_string()
}

/// 列出机制摘要
pub fn summarize(m: &Mechanism) -> String {
    format!(
        "{}  {}  参与者 {} · 策略 {} · 规则 {} · 目标 {}",
        m.id,
        m.name,
        m.players.len(),
        m.strategies.len(),
        m.rules.len(),
        m.objectives.len()
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample() -> Mechanism {
        Mechanism {
            id: "recruitment-game".into(),
            name: "招聘博弈机制".into(),
            description: "与招聘者的动态博弈".into(),
            players: vec![Player {
                id: "candidate".into(),
                name: "候选人".into(),
                role: "博弈方".into(),
            }],
            strategies: vec![Strategy {
                id: "s1".into(),
                player_id: "candidate".into(),
                name: "提供增量".into(),
                description: "在系统内找到目标".into(),
            }],
            rules: vec![Rule {
                id: "r1".into(),
                name: "市场化微型创业".into(),
                description: "拉进池子自己找题".into(),
            }],
            objectives: vec![Objective {
                id: "o1".into(),
                name: "招到留得住的人".into(),
                description: "宁缺毋滥".into(),
            }],
        }
    }

    #[test]
    fn summarize_shows_metadata() {
        let s = summarize(&sample());
        assert!(s.contains("recruitment-game"));
        assert!(s.contains("参与者 1"));
        assert!(s.contains("策略 1"));
    }

    #[test]
    fn load_parses_seed_data() {
        // CLI 独立种子数据：src/cli/data/mechanisms.json
        let path = Path::new(env!("CARGO_MANIFEST_DIR")).join("data/mechanisms.json");
        let mechanisms = load(&path).expect("种子数据应可解析");
        assert!(!mechanisms.is_empty());
        assert_eq!(mechanisms[0].id, "recruitment-game");
    }
}
