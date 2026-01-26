#!/bin/bash

# =============================================================================
# MikroTik Manager - Simple Linux Installer
# Installs pre-built executable (no build required)
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}============================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}============================================${NC}"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Error handling
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "Error occurred on line $line_number (exit code: $exit_code)"
    cleanup_on_error
    exit $exit_code
}

cleanup_on_error() {
    print_step "Cleaning up after error..."
    systemctl stop network-map 2>/dev/null || true
    systemctl disable network-map 2>/dev/null || true
    rm -f /etc/systemd/system/network-map.service
    rm -rf /opt/network_map
    systemctl daemon-reload 2>/dev/null || true
    print_warning "Installation rolled back due to error"
}

trap 'handle_error $LINENO' ERR

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This installer must be run as root"
        echo "Please run: sudo $0"
        exit 1
    fi
}

# Check system requirements
check_requirements() {
    print_step "Checking system requirements..."
    
    # Check if systemd is available
    if ! command -v systemctl >/dev/null 2>&1; then
        print_error "systemd is required but not found"
        exit 1
    fi
    
    # Check if we're on Linux
    if [ "$(uname -s)" != "Linux" ]; then
        print_error "This installer is for Linux only"
        exit 1
    fi
    
    # Check architecture (allow aarch64 and x86_64)
    ARCH=$(uname -m)
    if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "aarch64" ]; then
        print_warning "This installer is designed for x86_64/aarch64, but detected: $ARCH"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "System requirements check passed"
}

# Initialize database
initialize_database() {
    print_step "Initializing database..."
    
    # Create a simple database initialization script
    cat > /tmp/init_db.py << 'EOF'
import sqlite3
import os

# Change to application directory
os.chdir('/opt/network_map')

# Database path
DB_PATH = 'mapping.db'

def init_db():
    with sqlite3.connect(DB_PATH) as conn:
        # Create nodes table
        conn.execute('''CREATE TABLE IF NOT EXISTS nodes 
            (id TEXT PRIMARY KEY, alias TEXT, x REAL, y REAL, parent_id TEXT, profile TEXT)''')
        
        # Create hotspot users table
        conn.execute('''CREATE TABLE IF NOT EXISTS hotspot_users 
            (username TEXT PRIMARY KEY, password TEXT, profile TEXT, comment TEXT, 
             is_active INTEGER DEFAULT 0, last_seen TIMESTAMP, ip_address TEXT)''')
        
        # Create mikrotik settings table
        conn.execute('''CREATE TABLE IF NOT EXISTS mikrotik_settings 
            (id INTEGER PRIMARY KEY, host TEXT NOT NULL, username TEXT NOT NULL, 
             password TEXT NOT NULL, port INTEGER DEFAULT 22, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)''')
        
        # Insert SERVER node
        conn.execute("""INSERT OR IGNORE INTO nodes (id, alias, x, y, parent_id, profile) 
                       VALUES ('SERVER', 'PUSAT DATA', 50.0, 50.0, NULL, NULL)""")
        
        conn.commit()
        print("Database initialized successfully")

if __name__ == "__main__":
    init_db()
EOF
    
    # Run database initialization
    if command -v python3 >/dev/null 2>&1; then
        python3 /tmp/init_db.py
        rm -f /tmp/init_db.py
        print_success "Database initialized"
    else
        print_warning "Python3 not found, database will be initialized on first run"
    fi
}

# Check for port conflicts
check_port_conflict() {
    print_step "Checking port 5000 availability..."
    
    # Check if port 5000 is in use
    if command -v netstat >/dev/null 2>&1; then
        if netstat -tlnp | grep -q ":5000 "; then
            print_warning "Port 5000 is already in use"
            
            # Show what's using the port
            PROCESS=$(netstat -tlnp | grep ":5000 " | awk '{print $7}')
            print_warning "Process using port 5000: $PROCESS"
            
            read -p "Kill the process using port 5000? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Extract PID and kill it
                PID=$(echo $PROCESS | cut -d'/' -f1)
                if [ ! -z "$PID" ] && [ "$PID" != "-" ]; then
                    kill -9 $PID 2>/dev/null || true
                    sleep 2
                    print_success "Process killed"
                else
                    print_error "Could not extract PID to kill process"
                    exit 1
                fi
            else
                print_error "Cannot continue with port 5000 in use"
                exit 1
            fi
        fi
    elif command -v ss >/dev/null 2>&1; then
        if ss -tlnp | grep -q ":5000 "; then
            print_warning "Port 5000 is already in use"
            PROCESS=$(ss -tlnp | grep ":5000 " | awk '{print $6}')
            print_warning "Process using port 5000: $PROCESS"
            
            read -p "Kill the process using port 5000? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Try to extract PID from ss output
                PID=$(echo $PROCESS | grep -o 'pid=[0-9]*' | cut -d'=' -f2)
                if [ ! -z "$PID" ]; then
                    kill -9 $PID 2>/dev/null || true
                    sleep 2
                    print_success "Process killed"
                else
                    print_error "Could not extract PID to kill process"
                    exit 1
                fi
            else
                print_error "Cannot continue with port 5000 in use"
                exit 1
            fi
        fi
    fi
    
    print_success "Port 5000 is available"
}

# Initialize database
initialize_database() {
    print_step "Initializing database..."
    
    # Create a simple database initialization script
    cat > /tmp/init_db.py << 'EOF'
import sqlite3
import os

# Change to application directory
os.chdir('/opt/network_map')

# Database path
DB_PATH = 'mapping.db'

def init_db():
    with sqlite3.connect(DB_PATH) as conn:
        # Create nodes table
        conn.execute('''CREATE TABLE IF NOT EXISTS nodes 
            (id TEXT PRIMARY KEY, alias TEXT, x REAL, y REAL, parent_id TEXT, profile TEXT)''')
        
        # Create hotspot users table
        conn.execute('''CREATE TABLE IF NOT EXISTS hotspot_users 
            (username TEXT PRIMARY KEY, password TEXT, profile TEXT, comment TEXT, 
             is_active INTEGER DEFAULT 0, last_seen TIMESTAMP, ip_address TEXT)''')
        
        # Create mikrotik settings table
        conn.execute('''CREATE TABLE IF NOT EXISTS mikrotik_settings 
            (id INTEGER PRIMARY KEY, host TEXT NOT NULL, username TEXT NOT NULL, 
             password TEXT NOT NULL, port INTEGER DEFAULT 22, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)''')
        
        # Insert SERVER node
        conn.execute("""INSERT OR IGNORE INTO nodes (id, alias, x, y, parent_id, profile) 
                       VALUES ('SERVER', 'PUSAT DATA', 50.0, 50.0, NULL, NULL)""")
        
        conn.commit()
        print("Database initialized successfully")

if __name__ == "__main__":
    init_db()
EOF
    
    # Run database initialization
    if command -v python3 >/dev/null 2>&1; then
        python3 /tmp/init_db.py
        rm -f /tmp/init_db.py
        print_success "Database initialized"
    else
        print_warning "Python3 not found, database will be initialized on first run"
    fi
}
download_executable() {
    if [ -f "network_map" ]; then
        print_success "Executable found locally"
        return 0
    fi
    
    print_step "Downloading executable from GitHub..."
    
    # GitHub raw URL - replace with your actual repository
    GITHUB_URL="https://github.com/coolq4s/server-lnx/raw/refs/heads/main/network-mapping/network_map"
    
    # Try to download
    if command -v curl >/dev/null 2>&1; then
        curl -L -o network_map "$GITHUB_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -O network_map "$GITHUB_URL"
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
    
    # Check if download was successful
    if [ ! -f "network_map" ]; then
        print_error "Failed to download executable"
        print_error "Please ensure the executable is in the same directory as this installer"
        exit 1
    fi
    
    # Make executable
    chmod +x network_map
    print_success "Executable downloaded and made executable"
}

# Test binary compatibility
test_binary_compatibility() {
    print_step "Testing binary compatibility..."
    
    if [ ! -f "network_map" ]; then
        print_error "Binary not found for testing"
        return 1
    fi
    
    # Test if binary can run
    if timeout 5s ./network_map --help >/dev/null 2>&1; then
        print_success "Binary compatibility test passed"
        return 0
    else
        # Check for GLIBC error specifically
        ERROR_OUTPUT=$(timeout 5s ./network_map 2>&1 || true)
        if echo "$ERROR_OUTPUT" | grep -q "GLIBC"; then
            print_error "GLIBC compatibility issue detected"
            print_warning "Binary requires newer GLIBC than available on this system"
            return 2
        else
            print_warning "Binary test failed, but may still work"
            return 1
        fi
    fi
}

# Build locally if compatibility fails
build_locally_if_needed() {
    local test_result=$1
    
    if [ $test_result -eq 2 ]; then
        print_step "Attempting local build for compatibility..."
        
        # Check if we have source files
        if [ ! -f "app.py" ] || [ ! -f "requirements.txt" ]; then
            print_error "Source files not available for local build"
            print_error "Please use the universal build script on a compatible system"
            exit 1
        fi
        
        # Check if python3 and pip are available
        if ! command -v python3 >/dev/null 2>&1; then
            print_error "Python3 not found - cannot build locally"
            exit 1
        fi
        
        # Try local build
        print_step "Building compatible binary locally..."
        
        # Create virtual environment
        python3 -m venv /tmp/network_map_build
        source /tmp/network_map_build/bin/activate
        
        # Install dependencies
        pip install --upgrade pip
        pip install pyinstaller==5.13.2
        pip install -r requirements.txt
        
        # Build
        pyinstaller \
            --onefile \
            --name network_map_local \
            --add-data templates:templates \
            --add-data static:static \
            --add-data mapping.db:. \
            --hidden-import mikrotik_manager \
            --hidden-import license_manager \
            --hidden-import flask \
            --hidden-import paramiko \
            --hidden-import requests \
            --hidden-import pytz \
            --hidden-import PIL \
            --collect-all flask \
            --collect-all paramiko \
            --collect-all requests \
            --collect-all PIL \
            --exclude-module tkinter \
            --exclude-module matplotlib \
            --exclude-module numpy \
            --exclude-module pandas \
            --clean \
            --noconfirm \
            --strip \
            app.py
        
        # Check if local build succeeded
        if [ -f "dist/network_map_local" ]; then
            cp dist/network_map_local network_map
            chmod +x network_map
            
            # Test the locally built binary
            if timeout 5s ./network_map --help >/dev/null 2>&1; then
                print_success "Local build successful and compatible"
                
                # Cleanup
                rm -rf /tmp/network_map_build build dist __pycache__ *.spec
                return 0
            else
                print_error "Local build also failed compatibility test"
                rm -rf /tmp/network_map_build build dist __pycache__ *.spec
                exit 1
            fi
        else
            print_error "Local build failed"
            rm -rf /tmp/network_map_build build dist __pycache__ *.spec
            exit 1
        fi
    fi
}

# Install application
install_application() {
    print_step "Installing Network Map..."
    
    # Stop all related services first
    print_step "Stopping existing services..."
    systemctl stop network-map 2>/dev/null || true
    systemctl stop mikrotik-manage 2>/dev/null || true
    systemctl disable network-map 2>/dev/null || true
    systemctl disable mikrotik-manage 2>/dev/null || true
    
    # Kill all related processes
    print_step "Stopping all Network Map processes..."
    pkill -f "network_map" 2>/dev/null || true
    pkill -f "mikrotik_manage" 2>/dev/null || true
    pkill -f "mikrotik_manager" 2>/dev/null || true
    sleep 2
    
    # Force kill if still running
    pkill -9 -f "network_map" 2>/dev/null || true
    pkill -9 -f "mikrotik_manage" 2>/dev/null || true
    pkill -9 -f "mikrotik_manager" 2>/dev/null || true
    sleep 1
    
    print_success "All processes stopped"
    
    # Create application directory
    mkdir -p /opt/network_map
    
    # Remove old binaries to prevent "text busy" error
    if [ -f "/opt/network_map/network_map" ]; then
        print_step "Removing old binary..."
        rm -f /opt/network_map/network_map
        print_success "Old binary removed"
    fi
    
    # Remove old mikrotik_manage installation if exists
    if [ -d "/opt/mikrotik_manage" ]; then
        print_step "Removing old mikrotik_manage installation..."
        rm -rf /opt/mikrotik_manage
        print_success "Old installation removed"
    fi
    
    # Copy new executable
    print_step "Installing new binary..."
    cp network_map /opt/network_map/
    chmod +x /opt/network_map/network_map
    
    # Test the new binary
    if timeout 5s /opt/network_map/network_map --help >/dev/null 2>&1; then
        print_success "Binary test passed"
    else
        print_warning "Could not test binary, but installation completed"
    fi
    
    print_success "Application installed to /opt/network_map/"
}

# Create systemd service
create_service() {
    print_step "Creating systemd service..."
    
    # Remove old service files
    rm -f /etc/systemd/system/mikrotik-manage.service 2>/dev/null || true
    rm -f /etc/systemd/system/mikrotik_manage.service 2>/dev/null || true
    
    # Create new service file
    cat > /etc/systemd/system/network-map.service << 'EOF'
[Unit]
Description=Network Map Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/network_map
ExecStart=/opt/network_map/network_map
Restart=always
RestartSec=10
Environment=PYTHONPATH=/opt/network_map

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd and enable service
    systemctl daemon-reload
    systemctl enable network-map
    
    print_success "Systemd service created and enabled"
}

# Configure firewall
configure_firewall() {
    print_step "Configuring firewall..."
    
    # Try different firewall systems
    if command -v ufw >/dev/null 2>&1; then
        ufw --force enable >/dev/null 2>&1 || true
        ufw allow ssh >/dev/null 2>&1 || true
        ufw allow 5000/tcp >/dev/null 2>&1 || true
        print_success "UFW firewall configured"
    elif command -v firewall-cmd >/dev/null 2>&1; then
        systemctl start firewalld 2>/dev/null || true
        systemctl enable firewalld 2>/dev/null || true
        firewall-cmd --permanent --add-port=5000/tcp >/dev/null 2>&1 || true
        firewall-cmd --reload >/dev/null 2>&1 || true
        print_success "Firewalld configured"
    elif command -v iptables >/dev/null 2>&1; then
        iptables -A INPUT -p tcp --dport 5000 -j ACCEPT 2>/dev/null || true
        print_success "Iptables rule added"
        print_warning "Note: iptables rules may not persist after reboot"
    else
        print_warning "No supported firewall found. Please configure manually."
        print_warning "Allow port 5000: ufw allow 5000 or firewall-cmd --add-port=5000/tcp"
    fi
}

# Start service
start_service() {
    print_step "Starting Network Map service..."
    
    # Start the service
    systemctl start network-map
    
    # Wait for startup
    sleep 5
    
    # Check if service is running
    if systemctl is-active --quiet network-map; then
        print_success "Service started successfully"
        
        # Test if application is responding
        print_step "Testing application response..."
        local max_attempts=10
        local attempt=1
        
        while [ $attempt -le $max_attempts ]; do
            if command -v curl >/dev/null 2>&1; then
                if curl -s -o /dev/null -w "%{http_code}" http://localhost:5000 2>/dev/null | grep -q "200\|302"; then
                    print_success "Application is responding on port 5000"
                    break
                fi
            else
                # If no curl, just assume it's working after service start
                print_success "Service is running (curl not available for testing)"
                break
            fi
            
            if [ $attempt -eq $max_attempts ]; then
                print_warning "Application may not be responding properly"
                print_warning "Check logs with: journalctl -u network-map -f"
            else
                sleep 2
                attempt=$((attempt + 1))
            fi
        done
    else
        print_error "Service failed to start"
        print_step "Checking service logs..."
        journalctl -u network-map --no-pager -n 20
        exit 1
    fi
}

# Show final information
show_info() {
    print_header "🎉 INSTALLATION COMPLETED!"
    
    SERVER_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "YOUR_SERVER_IP")
    
    echo
    echo -e "${GREEN}📋 Application Information:${NC}"
    echo "   🌐 Local URL: http://localhost:5000"
    if [ "$SERVER_IP" != "YOUR_SERVER_IP" ]; then
        echo "   🌍 Network URL: http://$SERVER_IP:5000"
    fi
    
    echo
    echo -e "${GREEN}🔧 Service Management:${NC}"
    echo "   Start:   systemctl start network-map"
    echo "   Stop:    systemctl stop network-map"
    echo "   Restart: systemctl restart network-map"
    echo "   Status:  systemctl status network-map"
    echo "   Logs:    journalctl -u network-map -f"
    
    echo
    echo -e "${GREEN}📁 File Locations:${NC}"
    echo "   Application: /opt/network_map/network_map"
    echo "   Service:     /etc/systemd/system/network-map.service"
    echo "   Database:    /opt/network_map/mapping.db (created on first run)"
    
    echo
    echo -e "${GREEN}🚀 Your Network Map is ready to use!${NC}"
    echo
}

# Main installation process
main() {
    print_header "🚀 Network Map - Linux Installer"
    
    check_root
    check_requirements
    check_port_conflict
    download_executable
    
    # Test binary compatibility and build locally if needed
    test_binary_compatibility
    COMPAT_RESULT=$?
    build_locally_if_needed $COMPAT_RESULT
    
    install_application
    initialize_database
    create_service
    configure_firewall
    start_service
    show_info
    
    print_success "Installation completed successfully!"
}

# Uninstall function
uninstall() {
    print_header "🗑️ Network Map - Uninstaller"
    
    check_root
    
    print_step "Stopping service..."
    systemctl stop network-map 2>/dev/null || true
    systemctl disable network-map 2>/dev/null || true
    
    print_step "Removing service file..."
    rm -f /etc/systemd/system/network-map.service
    systemctl daemon-reload
    
    read -p "Remove application directory /opt/network_map? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf /opt/network_map
        print_success "Application directory removed"
    else
        print_warning "Application directory kept"
    fi
    
    print_success "Uninstallation completed!"
}

# Check command line arguments
case "${1:-}" in
    "uninstall"|"--uninstall"|"-u")
        uninstall
        exit 0
        ;;
    "help"|"--help"|"-h")
        echo "Network Map - Linux Installer"
        echo "==============================="
        echo
        echo "Usage: $0 [option]"
        echo
        echo "Options:"
        echo "  (no option)  - Install Network Map"
        echo "  uninstall    - Uninstall Network Map"
        echo "  help         - Show this help"
        echo
        echo "Requirements:"
        echo "  - Linux x86_64"
        echo "  - systemd"
        echo "  - Root privileges"
        echo
        echo "Installation will:"
        echo "  1. Download executable (if not present)"
        echo "  2. Install to /opt/network_map/"
        echo "  3. Create systemd service"
        echo "  4. Configure firewall (port 5000)"
        echo "  5. Start the service"
        echo
        echo "Access: http://localhost:5000"
        exit 0
        ;;
    *)
        main
        ;;
esac

exit 0