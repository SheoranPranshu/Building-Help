#!/bin/bash

# --- 1. LOCATE AND LOAD CONFIGURATION FILE ---

# Find the directory where this script is located to find rbe.conf
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/rbe.conf"

# If config file doesn't exist, create a template and exit.
if [ ! -f "$CONFIG_FILE" ]; then
    echo "📄 'rbe.conf' not found."
    echo "   Creating a template for you at: ${CONFIG_FILE}"
    # Use a heredoc to create the template file
    cat > "$CONFIG_FILE" << EOF
# RBE Configuration File for setup_rbe.sh
# Please fill in the values below.

RBE_RECLIENT_DIR="path/to/reclient"
BB_INSTANCE="your-instance.buildbuddy.io"
BB_API_KEY="xxx"
NINJA_REMOTE_NUM_JOBS=72
EOF
    echo "   Please edit the new 'rbe.conf' file with your details and source this script again."
    return 1
fi

# Source the configuration file to load the variables
# shellcheck source=/dev/null
source "$CONFIG_FILE"


# --- 2. VALIDATE LOADED CONFIGURATION ---

# Check if the user has updated the placeholder values from the config file.
if [[ -z "$RBE_RECLIENT_DIR" || "$RBE_RECLIENT_DIR" == "path/to/reclient" || \
      -z "$BB_INSTANCE" || "$BB_INSTANCE" == "your-instance.buildbuddy.io" || \
      -z "$BB_API_KEY" || "$BB_API_KEY" == "xxx" ]]; then
  echo "❌ ERROR: Please edit the configuration file with your details:"
  echo "          ${CONFIG_FILE}"
  echo "          - Set RBE_RECLIENT_DIR"
  echo "          - Set BB_INSTANCE"
  echo "          - Set BB_API_KEY"
  return 1
fi

# Check if the reclient directory actually exists
if [ ! -d "$RBE_RECLIENT_DIR" ]; then
    echo "❌ ERROR: The reclient directory does not exist at the specified path:"
    echo "          $RBE_RECLIENT_DIR"
    echo "          Please correct the RBE_RECLIENT_DIR path in '${CONFIG_FILE}'."
    return 1
fi


# --- 3. RBE ENVIRONMENT SETUP (DO NOT EDIT) ---

# --- Enable RBE and General Settings ---
export USE_RBE=1
export RBE_DIR="$RBE_RECLIENT_DIR"
export NINJA_REMOTE_NUM_JOBS=${NINJA_REMOTE_NUM_JOBS:-72} # Use default if not set

# --- BuildBuddy Connection Settings ---
export RBE_service="${BB_INSTANCE}:443"
export RBE_remote_headers="x-buildbuddy-api-key=${BB_API_KEY}"
export RBE_use_rpc_credentials=false
export RBE_service_no_auth=true

# --- Unified Downloads/Uploads (Recommended) ---
export RBE_use_unified_downloads=true
export RBE_use_unified_uploads=true

# --- Execution Strategies (remote_local_fallback is generally best) ---
export RBE_R8_EXEC_STRATEGY=remote_local_fallback
export RBE_D8_EXEC_STRATEGY=remote_local_fallback
export RBE_JAVAC_EXEC_STRATEGY=remote_local_fallback
export RBE_JAR_EXEC_STRATEGY=remote_local_fallback
export RBE_ZIP_EXEC_STRATEGY=remote_local_fallback
export RBE_TURBINE_EXEC_STRATEGY=remote_local_fallback
export RBE_SIGNAPK_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_LINKS_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_LINKER_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_DUMPER_EXEC_STRATEGY=    # Intentionally blank to force local execution.
export RBE_CLANG_TIDY_EXEC_STRATEGY=remote_local_fallback
export RBE_METALAVA_EXEC_STRATEGY=remote_local_fallback
export RBE_LINT_EXEC_STRATEGY=remote_local_fallback

# --- Enable RBE for Specific Tools ---
export RBE_R8=1
export RBE_D8=1
export RBE_JAVAC=1
export RBE_JAR=1
export RBE_ZIP=1
export RBE_TURBINE=1
export RBE_SIGNAPK=1
export RBE_CXX_LINKS=1
export RBE_CXX=1
export RBE_ABI_LINKER=1
export RBE_ABI_DUMPER=    # Intentionally blank to force local execution.
export RBE_CLANG_TIDY=1
export RBE_METALAVA=1
export RBE_LINT=1

# --- Resource Pools ---
export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default


# --- 4. SUCCESS MESSAGE ---
echo "✅ RBE environment configured by reading '${CONFIG_FILE}'"
echo "   - BuildBuddy Instance: ${BB_INSTANCE}"
echo "   - Remote Parallelism:  ${NINJA_REMOTE_NUM_JOBS}"
echo "   - Reclient Directory:  ${RBE_RECLIENT_DIR}"
echo "   You can now start your build."
