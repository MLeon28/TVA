import re
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates


class BenchmarkVisualizer:
    """
    Generates visualizations from a stress test log file.
    Parses connection and latency events and produces three plots:
        1. Active connections vs latency over time
        2. Latency by completion order with trend line
        3. Throughput per minute
    """

    def __init__(self, log_path: str, output_dir: str):
        """
        Parameters:
            log_path   : Path to the stress test log file
            output_dir : Directory where plots will be saved
        """
        self.log_path   = log_path
        self.output_dir = output_dir

        self.df_conn = None  # connection events (entry + exit)
        self.df_lat  = None  # latency events (completions)

        self._parse_log()

    # ── private ────────────────────────────────────────────────────────────────

    def _parse_log(self):
        """
        Parses the log file and extracts connection and latency events
        into separate DataFrames.
        """
        connections_events = []
        latency_events     = []

        with open(self.log_path, 'r') as f:
            for line in f:

                # Connection entry/exit events
                m = re.search(
                    r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d+) - INFO - '
                    r'request=(\d+) concurrency=(\d+) active_connections=(\d+)$',
                    line
                )
                if m:
                    connections_events.append({
                        'timestamp'          : pd.to_datetime(m.group(1), format='%Y-%m-%d %H:%M:%S,%f'),
                        'request'            : int(m.group(2)),
                        'concurrency'        : int(m.group(3)),
                        'active_connections' : int(m.group(4))
                    })

                # Latency completion events
                m2 = re.search(
                    r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d+) - INFO - '
                    r'request=(\d+) concurrency=(\d+) latency=([\d.]+)s active_connections=(\d+)',
                    line
                )
                if m2:
                    latency_events.append({
                        'timestamp'          : pd.to_datetime(m2.group(1), format='%Y-%m-%d %H:%M:%S,%f'),
                        'request'            : int(m2.group(2)),
                        'concurrency'        : int(m2.group(3)),
                        'latency_s'          : float(m2.group(4)),
                        'active_connections' : int(m2.group(5))
                    })

        self.df_conn = pd.DataFrame(connections_events).sort_values('timestamp').reset_index(drop=True)
        self.df_lat  = pd.DataFrame(latency_events).sort_values('timestamp').reset_index(drop=True)

        print(f"[visualizer] Parsed {len(self.df_conn)} connection events, "
              f"{len(self.df_lat)} latency events")

    # ── public methods ─────────────────────────────────────────────────────────

    def plot_active_connections_vs_latency(self):
        """
        Dual-axis plot showing active connections as a step area (left axis)
        and individual request latency as scatter points (right axis) over time.
        Helps visualize the relationship between concurrency and response time.
        """
        fig, ax1 = plt.subplots(figsize=(14, 6))

        # Active connections — step area
        ax1.step(self.df_conn['timestamp'], self.df_conn['active_connections'],
                 where='post', color='steelblue', linewidth=1.5, label='Active connections')
        ax1.fill_between(self.df_conn['timestamp'], self.df_conn['active_connections'],
                         step='post', alpha=0.25, color='steelblue')
        ax1.set_ylabel('Active Connections', color='steelblue')
        ax1.set_ylim(0, self.df_conn['active_connections'].max() + 2)
        ax1.tick_params(axis='y', labelcolor='steelblue')
        ax1.set_xlabel('Time')

        # Latency — scatter on secondary axis
        ax2 = ax1.twinx()
        ax2.scatter(self.df_lat['timestamp'], self.df_lat['latency_s'],
                    color='tomato', s=50, zorder=5, label='Latency per request')
        ax2.set_ylabel('Latency (s)', color='tomato')
        ax2.tick_params(axis='y', labelcolor='tomato')

        # Format x axis
        ax1.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
        plt.xticks(rotation=45)

        # Combined legend
        lines1, labels1 = ax1.get_legend_handles_labels()
        lines2, labels2 = ax2.get_legend_handles_labels()
        ax1.legend(lines1 + lines2, labels1 + labels2, loc='upper right')

        ax1.spines['top'].set_visible(False)
        ax2.spines['top'].set_visible(False)
        ax1.grid(color='grey', linestyle='-.', linewidth=0.3, alpha=0.5)

        concurrency = self.df_conn['concurrency'].iloc[0]
        total       = len(self.df_lat)
        plt.title(f'Active Connections vs Latency over Time (concurrency={concurrency}, total={total})')
        plt.tight_layout()

        path = f"{self.output_dir}/active_connections_vs_latency.png"
        plt.savefig(path, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"[visualizer] Saved: {path}")

    def plot_latency_by_completion_order(self):
        """
        Line plot of latency per request ordered by completion time.
        Includes a linear trend line to detect latency degradation over the test run.
        A rising trend suggests Ollama queue buildup under sustained load.
        """
        df = self.df_lat.copy()
        df['completion_order'] = range(1, len(df) + 1)

        fig, ax = plt.subplots(figsize=(14, 5))

        ax.plot(df['completion_order'], df['latency_s'],
                color='tomato', linewidth=1.5, marker='o', markersize=3,
                label='Latency per request')

        # Linear trend line
        z = np.polyfit(df['completion_order'], df['latency_s'], 1)
        p = np.poly1d(z)
        ax.plot(df['completion_order'], p(df['completion_order']),
                color='darkred', linewidth=1, linestyle='--', label='Trend')

        ax.set_xlabel('Completion order')
        ax.set_ylabel('Latency (s)')
        ax.legend()
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.grid(color='grey', linestyle='-.', linewidth=0.3, alpha=0.5)

        concurrency = self.df_conn['concurrency'].iloc[0]
        total       = len(self.df_lat)
        ax.set_title(f'Latency by Completion Order (concurrency={concurrency}, total={total})')
        plt.tight_layout()

        path = f"{self.output_dir}/latency_by_completion_order.png"
        plt.savefig(path, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"[visualizer] Saved: {path}")

    def plot_throughput_per_minute(self):
        """
        Bar chart showing the number of completed requests per minute window.
        Useful for identifying warm-up periods and peak throughput phases.
        """
        df = self.df_lat.set_index('timestamp')
        throughput = df['latency_s'].resample('1min').count()

        fig, ax = plt.subplots(figsize=(12, 5))

        ax.bar(throughput.index, throughput.values,
               width=0.0006, color='steelblue', alpha=0.8)
        ax.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
        ax.set_xlabel('Time (1 min windows)')
        ax.set_ylabel('Requests completed')
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.grid(color='grey', linestyle='-.', linewidth=0.3, alpha=0.5)

        concurrency = self.df_conn['concurrency'].iloc[0]
        total       = len(self.df_lat)
        ax.set_title(f'Throughput per Minute (concurrency={concurrency}, total={total})')
        plt.tight_layout()

        path = f"{self.output_dir}/throughput_per_minute.png"
        plt.savefig(path, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"[visualizer] Saved: {path}")

    def generate_all(self):
        """
        Runs all three plots in sequence and saves them to output_dir.
        """
        self.plot_active_connections_vs_latency()
        self.plot_latency_by_completion_order()
        self.plot_throughput_per_minute()
        print(f"[visualizer] All plots saved to: {self.output_dir}")
