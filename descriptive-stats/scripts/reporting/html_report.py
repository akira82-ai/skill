"""HTML report generation module.

Creates interactive HTML reports with embedded Plotly charts
and business-friendly insights.
"""

import json
from pathlib import Path
from typing import Any, Dict, List, Optional
from datetime import datetime
import pandas as pd
from jinja2 import Environment, FileSystemLoader, Template

from visualization.plotly_charts import (
    figure_to_html,
    create_histogram,
    create_boxplot,
    create_qqplot,
    create_correlation_heatmap,
    create_outlier_plot,
)
from core.business_interpreter import (
    interpret_basic_stats,
    interpret_distribution,
    interpret_outliers,
    interpret_group_comparison,
    generate_executive_summary,
    BusinessInsight,
)


def generate_html_report(
    df: pd.DataFrame,
    results: Dict[str, Any],
    output_path: str,
    title: str = "Descriptive Statistics Report",
    metadata: Optional[Dict[str, Any]] = None
):
    """Generate a complete HTML report.

    Args:
        df: Input DataFrame
        results: Analysis results dictionary
        output_path: Path to save HTML report
        title: Report title
        metadata: Optional metadata (date, analyst, etc.)
    """
    # Get template directory
    template_dir = Path(__file__).parent / 'templates'

    # Create Jinja2 environment
    env = Environment(loader=FileSystemLoader(template_dir))

    # Load template
    try:
        template = env.get_template('report.html')
    except Exception:
        # If template doesn't exist, use embedded template
        template = Template(_get_default_template())

    # Prepare context
    context = {
        'title': title,
        'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'metadata': metadata or {},
        'data_info': {
            'rows': len(df),
            'columns': len(df.columns),
            'column_names': list(df.columns),
        },
        'results': results,
    }

    # Render template
    html_content = template.render(**context)

    # Write to file
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html_content)


def embed_plotly_figure(fig, div_id: str = "chart") -> str:
    """Convert Plotly figure to HTML div.

    Args:
        fig: Plotly Figure object
        div_id: ID for the div element

    Returns:
        HTML string with embedded chart
    """
    return fig.to_html(
        include_plotlyjs=False,
        config={'displayModeBar': True, 'displaylogo': False},
        div_id=div_id
    )


def create_summary_table_html(
    stats: Dict[str, Dict[str, float]]
) -> str:
    """Create HTML table for summary statistics.

    Args:
        stats: Dictionary mapping column names to their statistics

    Returns:
        HTML string with table
    """
    df = pd.DataFrame(stats).T

    # Format for display
    html = df.to_html(
        classes='table table-striped table-hover',
        float_format=lambda x: f'{x:.4f}' if not pd.isna(x) else '—',
        border=0
    )

    return html


def create_charts_html(
    series: pd.Series,
    charts: Dict[str, Any]
) -> str:
    """Create HTML section with embedded charts.

    Args:
        series: Data series
        charts: Dictionary of chart names to Plotly figures

    Returns:
        HTML string with embedded charts
    """
    html_parts = []

    for chart_name, fig in charts.items():
        chart_div = embed_plotly_figure(fig, div_id=f"chart-{chart_name}")
        html_parts.append(f'<div class="chart-container">{chart_div}</div>')

    return '\n'.join(html_parts)


def _get_default_template() -> str:
    """Get default HTML template as string.

    Returns:
        HTML template string
    """
    return '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ title }}</title>
    <script src="https://cdn.plot.ly/plotly-2.27.0.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            color: #333;
            background: #f5f5f5;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px 0;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }

        header .meta {
            font-size: 0.9em;
            opacity: 0.9;
        }

        .section {
            background: white;
            border-radius: 8px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .section h2 {
            color: #667eea;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }

        .section h3 {
            color: #764ba2;
            margin-top: 20px;
            margin-bottom: 15px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .info-card {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            border-left: 4px solid #667eea;
        }

        .info-card .label {
            font-size: 0.85em;
            color: #666;
            margin-bottom: 5px;
        }

        .info-card .value {
            font-size: 1.5em;
            font-weight: bold;
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }

        table th,
        table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        table th {
            background: #667eea;
            color: white;
            font-weight: 600;
        }

        table tr:hover {
            background: #f8f9fa;
        }

        .chart-container {
            margin: 20px 0;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 6px;
        }

        .warning {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 10px 0;
            border-radius: 4px;
        }

        .error {
            background: #f8d7da;
            border-left: 4px solid #dc3545;
            padding: 15px;
            margin: 10px 0;
            border-radius: 4px;
        }

        .success {
            background: #d4edda;
            border-left: 4px solid #28a745;
            padding: 15px;
            margin: 10px 0;
            border-radius: 4px;
        }

        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }

        .stat-box {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
        }

        .stat-box .stat-name {
            font-size: 0.85em;
            color: #666;
            margin-bottom: 5px;
        }

        .stat-box .stat-value {
            font-size: 1.3em;
            font-weight: bold;
            color: #667eea;
        }

        .footer {
            text-align: center;
            padding: 20px;
            color: #666;
            font-size: 0.9em;
        }

        @media (max-width: 768px) {
            .info-grid,
            .stat-grid {
                grid-template-columns: 1fr;
            }

            table {
                font-size: 0.9em;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>{{ title }}</h1>
            <div class="meta">
                Generated on {{ date }}
                {% if metadata.analyst %} by {{ metadata.analyst }}{% endif %}
            </div>
        </div>
    </header>

    <div class="container">
        <!-- Data Overview Section -->
        <div class="section">
            <h2>Data Overview</h2>
            <div class="info-grid">
                <div class="info-card">
                    <div class="label">Total Rows</div>
                    <div class="value">{{ "{:,}".format(data_info.rows) }}</div>
                </div>
                <div class="info-card">
                    <div class="label">Total Columns</div>
                    <div class="value">{{ data_info.columns }}</div>
                </div>
                <div class="info-card">
                    <div class="label">Analyzed Columns</div>
                    <div class="value">{{ results.num_analyzed | default(0) }}</div>
                </div>
            </div>
        </div>

        {% if results.summary_stats %}
        <!-- Summary Statistics Section -->
        <div class="section">
            <h2>Summary Statistics</h2>
            {{ results.summary_stats_table | safe }}
        </div>
        {% endif %}

        {% if results.distribution %}
        <!-- Distribution Analysis Section -->
        <div class="section">
            <h2>Distribution Analysis</h2>
            {% for col, dist_data in results.distribution.items() %}
            <h3>{{ col }}</h3>
            {% if dist_data.normality_tests %}
            <p><strong>Normality Test Results:</strong></p>
            <ul>
                {% for test_name, test_result in dist_data.normality_tests.items() %}
                <li>{{ test_name }}: {{ test_result.interpretation }} (p={{ "%.4f"|format(test_result.p_value) if test_result.p_value else "N/A" }})</li>
                {% endfor %}
            </ul>
            {% endif %}
            {% if dist_data.chart %}
            <div class="chart-container">
                {{ dist_data.chart | safe }}
            </div>
            {% endif %}
            {% endfor %}
        </div>
        {% endif %}

        {% if results.outliers %}
        <!-- Outlier Detection Section -->
        <div class="section">
            <h2>Outlier Detection</h2>
            {% for col, outlier_data in results.outliers.items() %}
            <h3>{{ col }}</h3>
            <div class="stat-grid">
                <div class="stat-box">
                    <div class="stat-name">Method</div>
                    <div class="stat-value" style="font-size: 1em;">{{ outlier_data.method }}</div>
                </div>
                <div class="stat-box">
                    <div class="stat-name">Outliers Found</div>
                    <div class="stat-value">{{ outlier_data.outlier_count }}</div>
                </div>
                <div class="stat-box">
                    <div class="stat-name">Percentage</div>
                    <div class="stat-value">{{ "%.2f"|format(outlier_data.outlier_percentage) }}%</div>
                </div>
            </div>
            {% if outlier_data.chart %}
            <div class="chart-container">
                {{ outlier_data.chart | safe }}
            </div>
            {% endif %}
            {% endfor %}
        </div>
        {% endif %}

        {% if results.group_comparison %}
        <!-- Group Comparison Section -->
        <div class="section">
            <h2>Group Comparison</h2>
            <p><strong>Variable:</strong> {{ results.group_comparison.value_col }}</p>
            <p><strong>Grouping:</strong> {{ results.group_comparison.group_col }}</p>

            {% if results.group_comparison.test_result %}
            <h3>Statistical Test Results</h3>
            <div class="stat-grid">
                <div class="stat-box">
                    <div class="stat-name">Test</div>
                    <div class="stat-value" style="font-size: 1em;">{{ results.group_comparison.test_result.test_name }}</div>
                </div>
                <div class="stat-box">
                    <div class="stat-name">Statistic</div>
                    <div class="stat-value">{{ "%.4f"|format(results.group_comparison.test_result.statistic) }}</div>
                </div>
                <div class="stat-box">
                    <div class="stat-name">p-value</div>
                    <div class="stat-value">{{ "%.4f"|format(results.group_comparison.test_result.p_value) }}</div>
                </div>
            </div>
            <p><strong>Result:</strong> {{ results.group_comparison.test_result.interpretation }}</p>
            {% endif %}

            {% if results.group_comparison.chart %}
            <div class="chart-container">
                {{ results.group_comparison.chart | safe }}
            </div>
            {% endif %}
        </div>
        {% endif %}

        {% if results.correlation %}
        <!-- Correlation Analysis Section -->
        <div class="section">
            <h2>Correlation Analysis</h2>
            <div class="chart-container">
                {{ results.correlation.chart | safe }}
            </div>
        </div>
        {% endif %}
    </div>

    <div class="footer">
        <p>Generated by Descriptive Statistics Skill | Claude Code</p>
    </div>
</body>
</html>'''


def create_single_column_report(
    series: pd.Series,
    output_path: str,
    column_name: Optional[str] = None
):
    """Create a focused report for a single column.

    Args:
        series: pandas Series with data
        output_path: Path to save HTML report
        column_name: Name for the column (defaults to series.name)
    """
    if column_name is None:
        column_name = series.name if series.name else "Value"

    title = f"Analysis Report: {column_name}"

    # Calculate statistics
    from core.statistics import compute_basic_stats
    from core.distribution import test_normality
    from core.outliers import detect_outliers_iqr

    stats = compute_basic_stats(series)
    normality = test_normality(series)
    outliers = detect_outliers_iqr(series)

    # Create charts
    hist_fig = create_histogram(series, title=f"Distribution of {column_name}")
    qq_fig = create_qqplot(series, title=f"Q-Q Plot: {column_name}")
    outlier_fig = create_outlier_plot(series, outliers.outlier_indices, title=f"Outliers: {column_name}")

    # Prepare results
    results = {
        'summary_stats_table': _create_single_column_stats_table(stats),
        'distribution': {
            column_name: {
                'normality_tests': normality,
                'chart': figure_to_html(hist_fig),
            }
        },
        'outliers': {
            column_name: {
                'method': outliers.method,
                'outlier_count': outliers.outlier_count,
                'outlier_percentage': outliers.outlier_percentage,
                'chart': figure_to_html(outlier_fig),
            }
        },
        'num_analyzed': 1,
    }

    # Generate report
    df = pd.DataFrame({column_name: series})
    generate_html_report(df, results, output_path, title)


def _create_single_column_stats_table(stats: Dict[str, float]) -> str:
    """Create HTML table for single column statistics.

    Args:
        stats: Statistics dictionary

    Returns:
        HTML table string
    """
    table_html = '<table>'

    rows = [
        ('Count', stats.get('count', 0)),
        ('Mean', stats.get('mean')),
        ('Median', stats.get('median')),
        ('Mode', stats.get('mode')),
        ('Std Dev', stats.get('std')),
        ('Variance', stats.get('variance')),
        ('Minimum', stats.get('min')),
        ('Q1 (25%)', stats.get('q1')),
        ('Q3 (75%)', stats.get('q3')),
        ('Maximum', stats.get('max')),
        ('Range', stats.get('range')),
        ('IQR', stats.get('iqr')),
        ('Skewness', stats.get('skewness')),
        ('Kurtosis', stats.get('kurtosis')),
        ('CV (%)', stats.get('cv')),
    ]

    for label, value in rows:
        if isinstance(value, float):
            formatted = f'{value:.4f}'
        elif isinstance(value, int):
            formatted = f'{value:,}'
        else:
            formatted = '—'

        table_html += f'<tr><td><strong>{label}</strong></td><td>{formatted}</td></tr>'

    table_html += '</table>'

    return table_html
