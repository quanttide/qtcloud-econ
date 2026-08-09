use clap::{Parser, Subcommand};
use qtcloud_econ_cli::clarify;
use qtcloud_econ_cli::design;
use qtcloud_econ_cli::mechanism::{self, Mechanism};
use std::path::{Path, PathBuf};
use std::process;

#[derive(Parser)]
#[command(
    name = "qtcloud-econ",
    about = "量潮经济云 — 机制设计与经济建模",
    version,
    disable_help_subcommand(true)
)]
struct Cli {
    /// 机制种子数据路径（默认 src/cli/data/mechanisms.json）
    #[arg(long, global = true)]
    path: Option<PathBuf>,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// 机制设计命令集
    Mechanism {
        #[command(subcommand)]
        action: MechanismAction,
    },
    /// 需求澄清——模糊业务描述 → 结构化需求
    Clarify {
        /// 输入描述文件（Markdown）
        #[arg(long)]
        input: PathBuf,
        /// 输出需求文件（JSON，默认 stdout 同内容）
        #[arg(long)]
        output: Option<PathBuf>,
    },
    /// 机制设计——结构化需求 → 机制规格（players/strategies/rules/objectives）
    Design {
        /// 输入需求文件（JSON）
        #[arg(long)]
        input: PathBuf,
        /// 输出规格文件（JSON）
        #[arg(long)]
        output: Option<PathBuf>,
    },
}

#[derive(Subcommand)]
enum MechanismAction {
    /// 列出全部机制
    List,
    /// 显示机制详情
    Show {
        /// 机制 id
        id: String,
    },
}

fn main() {
    let cli = Cli::parse();
    let path = cli
        .path
        .unwrap_or_else(|| PathBuf::from(mechanism::default_path()));

    let result = match cli.command {
        Commands::Mechanism { action } => match action {
            MechanismAction::List => run_list(&path),
            MechanismAction::Show { id } => run_show(&path, &id),
        },
        Commands::Clarify { input, output } => run_clarify(&input, output.as_deref()),
        Commands::Design { input, output } => run_design(&input, output.as_deref()),
    };

    if let Err(e) = result {
        eprintln!("错误：{e}");
        process::exit(1);
    }
}

fn run_clarify(input: &Path, output: Option<&Path>) -> Result<(), String> {
    let md = std::fs::read_to_string(input)
        .map_err(|e| format!("读取 {} 失败：{e}", input.display()))?;
    let req = clarify::clarify(&md)?;
    let json = serde_json::to_string_pretty(&req).map_err(|e| format!("序列化失败：{e}"))?;
    write_output(output, &json)?;
    Ok(())
}

fn run_design(input: &Path, output: Option<&Path>) -> Result<(), String> {
    let req_json = std::fs::read_to_string(input)
        .map_err(|e| format!("读取 {} 失败：{e}", input.display()))?;
    let spec = design::design(&req_json)?;
    let json = serde_json::to_string_pretty(&spec).map_err(|e| format!("序列化失败：{e}"))?;
    write_output(output, &json)?;
    Ok(())
}

fn write_output(output: Option<&Path>, content: &str) -> Result<(), String> {
    if let Some(path) = output {
        std::fs::create_dir_all(path.parent().unwrap_or(path))
            .map_err(|e| format!("mkdir: {e}"))?;
        std::fs::write(path, content).map_err(|e| format!("write: {e}"))?;
    }
    println!("{content}");
    Ok(())
}

fn run_list(path: &PathBuf) -> Result<(), String> {
    let mechanisms = mechanism::load(path)?;
    if mechanisms.is_empty() {
        println!("暂无机制（{}）", path.display());
        return Ok(());
    }
    println!("机制列表（{}）：", path.display());
    println!();
    for m in &mechanisms {
        println!("  {}", mechanism::summarize(m));
    }
    Ok(())
}

fn run_show(path: &PathBuf, id: &str) -> Result<(), String> {
    let mechanisms = mechanism::load(path)?;
    let m = mechanisms
        .iter()
        .find(|m| m.id == id)
        .ok_or_else(|| format!("机制不存在：{id}（可用 mechanism list 查看）"))?;
    print_detail(m);
    Ok(())
}

fn print_detail(m: &Mechanism) {
    println!("{} — {}", m.id, m.name);
    println!("{}", m.description);
    println!();
    println!("参与者：");
    for p in &m.players {
        println!("  · {}（{}）", p.name, p.role);
    }
    println!();
    println!("策略空间：");
    for s in &m.strategies {
        println!("  · {}：{}", s.name, s.description);
    }
    println!();
    println!("规则（结果函数）：");
    for r in &m.rules {
        println!("  · {}：{}", r.name, r.description);
    }
    println!();
    println!("设计目标：");
    for o in &m.objectives {
        println!("  · {}：{}", o.name, o.description);
    }
}
