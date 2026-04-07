import asyncio
import logging
import os
import time

import httpx
import pandas as pd
from tqdm.asyncio import tqdm_asyncio

from scripts.benchmark.client     import AztecAIClient
from scripts.benchmark.visualizer import BenchmarkVisualizer


class InfrastructureEvaluator:
    """
    Evaluates AztecAI infrastructure performance under concurrent load.
    Measures latency distribution, throughput and error rate.
    """

    def __init__(self, client: AztecAIClient):
        """
        Parameters:
            client : AztecAIClient instance configured with target environment
        """
        self.client = client

    async def run_stress_test(
        self,
        prompt: str,
        total_requests: int = 200,
        concurrency: int = 10,
        logger: logging.Logger = None
    ) -> dict:
        """
        Runs a stress test by firing total_requests with a fixed concurrency level.
        Uses a semaphore to cap the number of simultaneous in-flight requests.

        Parameters:
            prompt          : Prompt to send in every request
            total_requests  : Total number of requests to execute
            concurrency     : Maximum number of simultaneous requests
            logger          : Logger instance for per-request logging

        Returns:
            Dictionary with aggregated metrics:
                total_requests, concurrency, total_time_s, avg_latency_s,
                max_latency_s, errors, success_rate
        """
        sem                = asyncio.Semaphore(concurrency)
        latencies          = []
        errors             = 0
        active_connections = 0

        async with httpx.AsyncClient() as http_client:

            async def single_call(i: int):
                nonlocal errors, active_connections
                try:
                    async with sem:                           # wait in queue until slot is free
                        active_connections += 1
                        if logger:
                            logger.info(
                                f"request={i} concurrency={concurrency} "
                                f"active_connections={active_connections}"
                            )
                        start   = time.perf_counter()         # start timer inside semaphore
                        await self.client.ask(http_client, prompt)
                        elapsed = time.perf_counter() - start
                        active_connections -= 1

                    latencies.append(elapsed)

                    if logger:
                        logger.info(
                            f"request={i} concurrency={concurrency} "
                            f"latency={round(elapsed, 3)}s "
                            f"active_connections={active_connections}"
                        )

                except Exception as e:
                    active_connections -= 1
                    errors += 1
                    if logger:
                        logger.error(
                            f"request={i} concurrency={concurrency} "
                            f"error={type(e).__name__}: {e} "
                            f"active_connections={active_connections}"
                        )
                    if errors <= 3:
                        print(f"  ⚠ Error: {type(e).__name__}: {e}")

            tasks = [single_call(i) for i in range(total_requests)]

            t0         = time.perf_counter()
            await tqdm_asyncio.gather(*tasks)
            total_time = time.perf_counter() - t0

        return {
            "total_requests" : total_requests,
            "concurrency"    : concurrency,
            "total_time_s"   : round(total_time, 2),
            "avg_latency_s"  : round(sum(latencies) / len(latencies), 3) if latencies else None,
            "max_latency_s"  : round(max(latencies), 3) if latencies else None,
            "errors"         : errors,
            "success_rate"   : round((total_requests - errors) / total_requests, 3)
        }


def _setup_concurrency_logger(output_dir: str, concurrency: int, timestamp: str) -> tuple:
    """
    Creates a dedicated logger and output subdirectory for a single concurrency level.

    Parameters:
        output_dir  : Base output directory for the benchmark run
        concurrency : Concurrency level being tested
        timestamp   : Run timestamp string

    Returns:
        Tuple of (logger, log_path, concurrency_dir)
    """
    concurrency_dir = os.path.join(output_dir, f"concurrency_{concurrency}")
    os.makedirs(concurrency_dir, exist_ok=True)

    log_path = os.path.join(concurrency_dir, f"stress_test_c{concurrency}_{timestamp}.log")

    # Use a unique logger name per concurrency to avoid handler conflicts
    logger = logging.getLogger(f"stress_test_c{concurrency}")
    logger.setLevel(logging.INFO)

    # Avoid duplicate handlers if function is called multiple times
    if not logger.handlers:
        handler = logging.FileHandler(log_path)
        handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
        logger.addHandler(handler)

        # Forward httpx logs to this file as well
        httpx_logger = logging.getLogger("httpx")
        httpx_logger.setLevel(logging.INFO)
        httpx_logger.addHandler(handler)

    logger.info(f"--- Starting sweep: concurrency={concurrency} ---")

    return logger, log_path, concurrency_dir


async def concurrency_sweep(
    evaluator: InfrastructureEvaluator,
    prompt: str,
    total_requests: int = 200,
    concurrency_values: tuple = (1, 2, 5, 10, 15, 20),
    output_dir: str = None,
    timestamp: str = None,
    sleep_between_s: int = 30,
) -> pd.DataFrame:
    """
    Runs a series of stress tests across different concurrency levels.
    Each concurrency level gets its own subdirectory, log file and visualizations.
    Returns a single summary DataFrame with one row per concurrency value.

    Parameters:
        evaluator          : InfrastructureEvaluator instance
        prompt             : Prompt to use in all requests
        total_requests     : Number of requests per concurrency level
        concurrency_values : Tuple of concurrency levels to test
        output_dir         : Base output directory for the benchmark run
        timestamp          : Run timestamp string used in filenames
        sleep_between_s    : Seconds to wait between concurrency levels
                             to allow the system to drain (default 30)

    Returns:
        DataFrame with columns:
            total_requests, concurrency, total_time_s, avg_latency_s,
            max_latency_s, errors, success_rate, requests_per_second
    """
    results = []

    for c in concurrency_values:
        print(f"\nTesting concurrency = {c}")

        # Create per-concurrency logger and output directory
        logger, log_path, concurrency_dir = _setup_concurrency_logger(output_dir, c, timestamp)

        r = await evaluator.run_stress_test(
            prompt=prompt,
            total_requests=total_requests,
            concurrency=c,
            logger=logger
        )

        successful = total_requests - r["errors"]
        r["requests_per_second"] = round(
            successful / r["total_time_s"], 3
        ) if successful > 0 else 0

        results.append(r)

        # Generate visualizations for this concurrency level
        visualizer = BenchmarkVisualizer(log_path=log_path, output_dir=concurrency_dir)
        visualizer.generate_all()

        # Allow system to drain before next concurrency level
        if c != concurrency_values[-1]:
            print(f"\n[sweep] Waiting {sleep_between_s}s for system to drain before next level...")
            await asyncio.sleep(sleep_between_s)

    return pd.DataFrame(results)