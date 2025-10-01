#!/usr/bin/env python3

"""
Terminal Logger Viewer - Simple Version
View and search terminal session logs (.log files)
"""

import os
import sys
import argparse
from datetime import datetime
from pathlib import Path

def list_logs(log_dir, log_type="all"):
    """List all log files with metadata"""
    log_path = Path(log_dir)
    
    if not log_path.exists():
        print(f"Log directory {log_dir} does not exist")
        return []
    
    logs = []
    
    # Determine which directories to search
    if log_type == "raw":
        search_dirs = [log_path / "raw"]
    elif log_type == "clean":
        search_dirs = [log_path / "clean"]
    else:  # all
        search_dirs = [log_path / "raw", log_path / "clean"]
    
    for search_dir in search_dirs:
        if not search_dir.exists():
            continue
            
        for log_file in sorted(search_dir.glob("*.log"), reverse=True):
            try:
                stat = log_file.stat()
                size = stat.st_size
                mtime = datetime.fromtimestamp(stat.st_mtime)
                
                # Determine log type from path
                log_type_name = "raw" if "raw" in str(log_file) else "clean"
                
                logs.append({
                    'file': log_file.name,
                    'path': str(log_file),
                    'size': size,
                    'modified': mtime,
                    'size_mb': round(size / (1024 * 1024), 2),
                    'type': log_type_name
                })
            except OSError as e:
                print(f"Error reading {log_file}: {e}")
    
    return logs

def show_log(log_file, lines=None):
    """Show log file content"""
    try:
        with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
            if lines:
                # Show last N lines
                all_lines = f.readlines()
                for line in all_lines[-lines:]:
                    print(line.rstrip())
            else:
                # Show entire file
                for line in f:
                    print(line.rstrip())
    except IOError as e:
        print(f"Error reading {log_file}: {e}")

def search_logs(log_dir, query, max_results=50, log_type="all"):
    """Search for text in all log files"""
    log_path = Path(log_dir)
    results = []
    
    if not log_path.exists():
        print(f"Log directory {log_dir} does not exist")
        return results
    
    query_lower = query.lower()
    
    # Determine which directories to search
    if log_type == "raw":
        search_dirs = [log_path / "raw"]
    elif log_type == "clean":
        search_dirs = [log_path / "clean"]
    else:  # all
        search_dirs = [log_path / "raw", log_path / "clean"]
    
    for search_dir in search_dirs:
        if not search_dir.exists():
            continue
            
        for log_file in search_dir.glob("*.log"):
            try:
                with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
                    for line_num, line in enumerate(f, 1):
                        if query_lower in line.lower():
                            # Determine log type from path
                            log_type_name = "raw" if "raw" in str(log_file) else "clean"
                            
                            results.append({
                                'file': log_file.name,
                                'line': line_num,
                                'content': line.rstrip(),
                                'type': log_type_name
                            })
                            if len(results) >= max_results:
                                break
            except IOError as e:
                print(f"Error reading {log_file}: {e}")
    
    return results

def main():
    parser = argparse.ArgumentParser(description='Terminal Logger Viewer')
    parser.add_argument('--log-dir', default='~/ttylogs', 
                       help='Log directory (default: ~/ttylogs)')
    parser.add_argument('--list', action='store_true', 
                       help='List all log files')
    parser.add_argument('--show', type=str, 
                       help='Show specific log file')
    parser.add_argument('--search', type=str, 
                       help='Search for text in all logs')
    parser.add_argument('--tail', type=int, 
                       help='Show last N lines of log file')
    parser.add_argument('--recent', type=int, default=5, 
                       help='Show recent N log files (default: 5)')
    parser.add_argument('--type', choices=['raw', 'clean', 'all'], default='all',
                       help='Log type to show: raw, clean, or all (default: all)')
    
    args = parser.parse_args()
    
    # Expand log directory
    log_dir = os.path.expanduser(args.log_dir)
    
    if args.list:
        logs = list_logs(log_dir, args.type)
        if not logs:
            print("No log files found")
            return
        
        print(f"Terminal Session Logs ({args.type}):")
        print("-" * 90)
        print(f"{'File':<30} {'Type':<8} {'Size':<10} {'Modified':<20}")
        print("-" * 90)
        for log in logs:
            print(f"{log['file']:<30} {log['type']:<8} {log['size_mb']:<8}MB {log['modified'].strftime('%Y-%m-%d %H:%M:%S'):<20}")
    
    elif args.show:
        log_file = os.path.join(log_dir, args.show)
        if not os.path.exists(log_file):
            print(f"Log file {log_file} not found")
            return
        
        show_log(log_file, args.tail)
    
    elif args.search:
        results = search_logs(log_dir, args.search, log_type=args.type)
        if not results:
            print(f"No matches found for '{args.search}'")
            return
        
        print(f"Found {len(results)} matches for '{args.search}' ({args.type}):")
        print("-" * 90)
        for result in results:
            print(f"{result['file']} ({result['type']}):{result['line']} - {result['content']}")
    
    else:
        # Show recent log files
        logs = list_logs(log_dir, args.type)
        if not logs:
            print("No log files found")
            return
        
        print(f"Recent {min(args.recent, len(logs))} terminal sessions ({args.type}):")
        print("-" * 90)
        for log in logs[:args.recent]:
            print(f"{log['file']} ({log['type']}) - {log['size_mb']}MB - {log['modified'].strftime('%Y-%m-%d %H:%M:%S')}")
        
        print(f"\nTo view a log file:")
        print(f"  python3 viewer.py --show {logs[0]['file']}")
        print(f"\nTo search logs:")
        print(f"  python3 viewer.py --search 'git commit'")
        print(f"\nTo view only clean logs:")
        print(f"  python3 viewer.py --type clean")
        print(f"\nTo view only raw logs:")
        print(f"  python3 viewer.py --type raw")

if __name__ == '__main__':
    main()
