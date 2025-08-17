#!/usr/bin/env bash

# NixOS Deployment Script
# This script provides convenient commands for deploying with deploy-rs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(dirname "$SCRIPT_DIR")"

usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

COMMANDS:
    deploy [node]               - Deploy configuration using deploy-rs
    check                       - Check flake configuration
    build [system]              - Build system configuration
    help                        - Show this help

EXAMPLES:
    $0 deploy quasar            - Deploy to quasar node
    $0 deploy                   - Deploy to all nodes
    $0 check                    - Validate configurations
    $0 build quasar             - Build quasar system

NOTES:
    - Update hostnames/IPs in the universe.deployment.hostname configuration
    - Make sure secrets are properly configured before deployment
    - The disko module will handle disk formatting if configured

EOF
}

deploy_system() {
    local node=${1:-}
    
    cd "$FLAKE_DIR"
    
    if [[ -n "$node" ]]; then
        echo "🚀 Deploying to node: $node"
        deploy ".#$node"
    else
        echo "🚀 Deploying to all nodes"
        deploy
    fi
    
    echo "✅ Deployment completed!"
}

check_config() {
    cd "$FLAKE_DIR"
    echo "🔍 Checking flake configuration..."
    nix flake check
    echo "✅ Configuration is valid!"
}

build_system() {
    local system=${1:-quasar}
    
    cd "$FLAKE_DIR"
    echo "🔨 Building system: $system"
    nix build ".#nixosConfigurations.$system.config.system.build.toplevel"
    echo "✅ Build completed!"
}

main() {
    case "${1:-help}" in
        deploy)
            deploy_system "${2:-}"
            ;;
        check)
            check_config
            ;;
        build)
            build_system "${2:-}"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            echo "Unknown command: ${1:-}"
            echo
            usage
            exit 1
            ;;
    esac
}

main "$@"