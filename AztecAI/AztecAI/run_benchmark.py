import asyncio
import json
import os
from datetime import datetime

from scripts.benchmark.client    import AztecAIClient, ModelValidationError
from scripts.benchmark.evaluator import InfrastructureEvaluator, concurrency_sweep

# ── Configuration ──────────────────────────────────────────────────────────────

BASE_URL    = "https://aztecahub.azteca.tvazteca.com.mx"
ENDPOINT    = "/api/chat/completions"
API_KEY     = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjhmN2ZkMDA0LWI5MWItNGIxMC04YzI3LWJmMzllNTJlYzViOSIsImV4cCI6MTc3NTYwNTQwMiwianRpIjoiZTM3OTIwNzQtOGY4ZC00OWJkLWFjOWYtMmIyYjA2NTc3MjFiIn0.kQLFs6QfI7HzKMg1IoamT6hKSzfDSOc_UDASBouI3Ik"
MODEL       = "aztecai-v-231"
PROJECT_DIR = r"E:\Desarrollos\AztecaProjects\AztecAI"
SCRIPT_VERSION = "1.0.0"

# ── Run configuration (edit before each run) ───────────────────────────────────

RUN_CONFIG = {
    "environment"        : "prod",          # "prod" or "qa"
    "prompt"             : "Que es tv azteca y cuales son las empresas de grupo salinas?",
    "total_requests"     : 50,
    "concurrency_values" : [1, 2, 5, 10],
    "timeout_s"          : 300,
    "sleep_between_s"    : 30,

    # Infrastructure context (fill in manually before each run)
    "ollama_num_parallel": 4,
    "uvicorn_workers"    : 4,
    "pods"               : 2,
    "ollama_instances"   : 2,
    "redis_timeout_s"    : 60,

    # Free-form notes — describe what changed since last run
    "notes": "First Test with infrastucure base"
}

# ── Output directory setup ─────────────────────────────────────────────────────

def setup_output_dir(base_dir: str, timestamp: str) -> str:
    """
    Creates the base output directory for a benchmark run.

    Structure:
        <base_dir>/benchmarks/concurrency_tests/<timestamp>/

    Parameters:
        base_dir  : Root project directory
        timestamp : Run timestamp string (e.g. 20260323_132509)

    Returns:
        Path to the created base output directory
    """
    output_dir = os.path.join(base_dir, "benchmarks", "concurrency_tests", timestamp)
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
    and results. Useful for tracing and comparing runs across environments.

    Parameters:
        output_dir  : Directory where metadata.json will be saved
        timestamp   : Run timestamp string
        started_at  : ISO datetime string when the run started
        finished_at : ISO datetime string when the run finished
        df_results  : Summary DataFrame with one row per concurrency level
    """
    # Build per-level results summary
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
        "total_requests"      : RUN_CONFIG["total_requests"],
        "concurrency_values"  : RUN_CONFIG["concurrency_values"],
        "timeout_s"           : RUN_CONFIG["timeout_s"],
        "sleep_between_s"     : RUN_CONFIG["sleep_between_s"],

        # Infrastructure context
        "infrastructure": {
            "ollama_num_parallel" : RUN_CONFIG["ollama_num_parallel"],
            "uvicorn_workers"     : RUN_CONFIG["uvicorn_workers"],
            "pods"                : RUN_CONFIG["pods"],
            "ollama_instances"    : RUN_CONFIG["ollama_instances"],
            "redis_timeout_s"     : RUN_CONFIG["redis_timeout_s"],
        },

        # Notes
        "notes": RUN_CONFIG["notes"],

        # Results
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
    print(f"Model            : {MODEL}")
    print(f"Concurrency      : {RUN_CONFIG['concurrency_values']}")

    # ── Client & evaluator setup ───────────────────────────────────────────────
    client = AztecAIClient(
        base_url=BASE_URL,
        endpoint=ENDPOINT,
        api_key=API_KEY,
        model=MODEL,
        timeout=RUN_CONFIG["timeout_s"]
    )

    # ── Validate model before running benchmark ────────────────────────────────
    try:
        await client.validate_model()
    except ModelValidationError as e:
        print(f"\nModel validation failed: {e}")
        print("Fix the MODEL configuration in run_benchmark.py and try again.")
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
    csv_path = os.path.join(output_dir, f"stress_test_summary_{timestamp}.csv")
    df_stress.to_csv(csv_path, index=False)
    print(f"\nSummary saved to : {csv_path}")

    # ── Save metadata ──────────────────────────────────────────────────────────
    write_metadata(output_dir, timestamp, started_at, finished_at, df_stress)


if __name__ == "__main__":
    asyncio.run(main())