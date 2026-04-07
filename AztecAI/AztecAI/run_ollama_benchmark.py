import asyncio
import json
import os
from datetime import datetime

from scripts.benchmark.ollama_client import OllamaClient
from scripts.benchmark.evaluator     import InfrastructureEvaluator, concurrency_sweep

# ── Project directory — auto-detected from script location ─────────────────────
# This allows the script to be run from any directory on the server.
PROJECT_DIR    = os.path.dirname(os.path.abspath(__file__))
SCRIPT_VERSION = "1.0.0"

# ── Configuration ──────────────────────────────────────────────────────────────

BASE_URL = "http://10.64.126.15:11434"   # Ollama server IP and port
MODEL    = "qwen2.5:32b"                 # Model to benchmark

# ── Run configuration (edit before each run) ───────────────────────────────────

RUN_CONFIG = {
    "environment"        : "ollama-direct",   # identifies this as a direct Ollama test
    "prompt"             : "Resume la historia de TV Azteca en tres frases.",
    "total_requests"     : 50,
    "concurrency_values" : [1, 2, 5, 10],
    "timeout_s"          : 300,
    "sleep_between_s"    : 30,

    # Infrastructure context
    "ollama_num_parallel": 8,
    "ollama_instances"   : 2,

    # Free-form notes — describe what this run is measuring
    "notes": "Direct Ollama benchmark to isolate inference latency from middleware overhead."
}

# ── Output directory setup ─────────────────────────────────────────────────────

def setup_output_dir(base_dir: str, timestamp: str) -> str:
    """
    Creates the base output directory for a benchmark run.

    Structure:
        <script_dir>/benchmarks/ollama_direct/<timestamp>/

    Parameters:
        base_dir  : Root directory (same folder as this script)
        timestamp : Run timestamp string

    Returns:
        Path to the created base output directory
    """
    output_dir = os.path.join(base_dir, "benchmarks", "ollama_direct", timestamp)
    os.makedirs(output_dir, exist_ok=True)
    return output_dir


# ── Metadata generation ────────────────────────────────────────────────────────

def write_metadata(
    output_dir: str,
    timestamp: str,
    started_at: str,
    finished_at: str,
    df_results
) -> None:
    """
    Writes a metadata.json file summarizing the benchmark run configuration
    and results.

    Parameters:
        output_dir  : Directory where metadata.json will be saved
        timestamp   : Run timestamp string
        started_at  : ISO datetime string when the run started
        finished_at : ISO datetime string when the run finished
        df_results  : Summary DataFrame with one row per concurrency level
    """
    results_summary = []
    for _, row in df_results.iterrows():
        results_summary.append({
            "concurrency"         : int(row["concurrency"]),
            "total_requests"      : int(row["total_requests"]),
            "total_time_s"        : float(row["total_time_s"]),
            "avg_latency_s"       : float(row["avg_latency_s"]) if row["avg_latency_s"] else None,
            "max_latency_s"       : float(row["max_latency_s"]) if row["max_latency_s"] else None,
            "errors"              : int(row["errors"]),
            "success_rate"        : float(row["success_rate"]),
            "requests_per_second" : float(row["requests_per_second"]),
        })

    metadata = {
        "run_id"         : timestamp,
        "script_version" : SCRIPT_VERSION,
        "started_at"     : started_at,
        "finished_at"    : finished_at,

        # Endpoint info
        "environment"    : RUN_CONFIG["environment"],
        "base_url"       : BASE_URL,
        "model"          : MODEL,
        "prompt"         : RUN_CONFIG["prompt"],

        # Run parameters
        "total_requests"     : RUN_CONFIG["total_requests"],
        "concurrency_values" : RUN_CONFIG["concurrency_values"],
        "timeout_s"          : RUN_CONFIG["timeout_s"],
        "sleep_between_s"    : RUN_CONFIG["sleep_between_s"],

        # Infrastructure context
        "infrastructure": {
            "ollama_num_parallel" : RUN_CONFIG["ollama_num_parallel"],
            "ollama_instances"    : RUN_CONFIG["ollama_instances"],
        },

        "notes"  : RUN_CONFIG["notes"],
        "results": results_summary,
    }

    path = os.path.join(output_dir, "metadata.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)

    print(f"Metadata saved to : {path}")


# ── Entry point ────────────────────────────────────────────────────────────────

async def main():
    timestamp   = datetime.now().strftime("%Y%m%d_%H%M%S")
    started_at  = datetime.now().isoformat()
    output_dir  = setup_output_dir(PROJECT_DIR, timestamp)

    print(f"Output directory : {output_dir}")
    print(f"Environment      : {RUN_CONFIG['environment']}")
    print(f"Ollama URL       : {BASE_URL}")
    print(f"Model            : {MODEL}")
    print(f"Concurrency      : {RUN_CONFIG['concurrency_values']}")

    # ── Client & evaluator setup ───────────────────────────────────────────────
    client = OllamaClient(
        base_url=BASE_URL,
        model=MODEL,
        timeout=RUN_CONFIG["timeout_s"]
    )

    # ── Validate model before running benchmark ────────────────────────────────
    try:
        await client.validate_model()
    except ValueError as e:
        print(f"\n❌ Model validation failed: {e}")
        print("Fix the MODEL or BASE_URL configuration and try again.")
        return

    infra = InfrastructureEvaluator(client)

    # ── Run benchmark sweep ────────────────────────────────────────────────────
    df_stress = await concurrency_sweep(
        infra,
        prompt             = RUN_CONFIG["prompt"],
        total_requests     = RUN_CONFIG["total_requests"],
        concurrency_values = RUN_CONFIG["concurrency_values"],
        output_dir         = output_dir,
        timestamp          = timestamp,
        sleep_between_s    = RUN_CONFIG["sleep_between_s"],
    )

    finished_at = datetime.now().isoformat()

    print(df_stress)

    # ── Save summary CSV ───────────────────────────────────────────────────────
    csv_path = os.path.join(output_dir, f"ollama_benchmark_summary_{timestamp}.csv")
    df_stress.to_csv(csv_path, index=False)
    print(f"\nSummary saved to : {csv_path}")

    # ── Save metadata ──────────────────────────────────────────────────────────
    write_metadata(output_dir, timestamp, started_at, finished_at, df_stress)


if __name__ == "__main__":
    asyncio.run(main())
