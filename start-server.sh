#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Node.js 是否安装
check_nodejs() {
    if ! command -v node &> /dev/null; then
        print_error "Node.js 未安装"
        print_info "请访问 https://nodejs.org 安装 Node.js"
        exit 1
    fi
}

# 检查 http-server 是否安装
check_http_server() {
    if ! command -v http-server &> /dev/null; then
        print_info "正在安装 http-server..."
        npm install -g http-server
        if [ $? -ne 0 ]; then
            print_error "http-server 安装失败"
            exit 1
        fi
        print_success "http-server 安装成功"
    fi
}

# 启动服务器
start_server() {
    local port=$1
    local cors=$2
    local cache=$3
    
    # 构建命令
    local cmd="http-server -p $port"
    if [ "$cors" = "true" ]; then
        cmd="$cmd --cors"
    fi
    if [ "$cache" = "false" ]; then
        cmd="$cmd --no-cache"
    fi
    
    print_info "启动 HTTP 服务器..."
    print_info "地址: http://localhost:$port"
    print_info "目录: $(pwd)"
    print_info "CORS: $([ "$cors" = "true" ] && echo "启用" || echo "禁用")"
    print_info "缓存: $([ "$cache" = "true" ] && echo "启用" || echo "禁用")"
    print_info "按 Ctrl+C 停止服务器"
    echo
    
    eval $cmd
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项] [端口]"
    echo "选项:"
    echo "  -h, --help      显示帮助信息"
    echo "  -c, --cors      启用 CORS 支持"
    echo "  -n, --no-cache  禁用缓存"
    echo ""
    echo "端口: 可选，默认为 8000"
    echo ""
    echo "示例:"
    echo "  $0 8080        在端口 8080 启动服务器"
    echo "  $0 -c 3000     在端口 3000 启动服务器并启用 CORS"
    echo "  $0 -n          在默认端口启动服务器并禁用缓存"
}

# 主程序
main() {
    local port=8000
    local cors=false
    local cache=true
    
    # 检查依赖
    check_nodejs
    check_http_server
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--cors)
                cors=true
                shift
                ;;
            -n|--no-cache)
                cache=false
                shift
                ;;
            *)
                if [[ $1 =~ ^[0-9]+$ ]]; then
                    port=$1
                else
                    print_error "无效的参数: $1"
                    show_help
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # 验证端口号
    if [[ $port -lt 0 || $port -gt 65535 ]]; then
        print_error "端口号必须在 0-65535 之间"
        exit 1
    fi

    # 启动服务器
    start_server $port $cors $cache
}

# 运行主程序
main "$@" 