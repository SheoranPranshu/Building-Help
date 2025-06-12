#!/bin/bash

# --- Color Codes for Better Output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Script Header ---
echo -e "${GREEN}--- RBE Environment Setup Script ---${NC}"
echo

# --- CRITICAL: Check how the script is being run ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${RED}ERROR: This script must be sourced, not executed directly.${NC}"
    echo -e "Please run it like this: ${CYAN}source ${0##*/}${NC}"
    exit 1
fi

# --- Step 1: Load Configuration ---
# Assumes rbe.conf is in the same directory as this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/rbe.conf"

echo -e "${YELLOW}Step 1: Loading configuration from '$CONFIG_FILE'...${NC}"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file '$CONFIG_FILE' not found!${NC}"
    echo "Please create it and place it next to this script."
    return 1 # Use 'return' because the script is sourced
fi
source "$CONFIG_FILE"
echo -e "${GREEN}  > Configuration loaded.${NC}"

# --- Step 2: Validate Configuration ---
echo -e "\n${YELLOW}Step 2: Validating configuration...${NC}"
has_error=false

# Check if RBE_DIR is set and exists
if [[ "$RBE_DIR" == "path/to/reclient" || -z "$RBE_DIR" ]]; then
    echo -e "${RED}  [FAIL] RBE_DIR is not set in '$CONFIG_FILE'. Please specify the path to your reclient directory.${NC}"
    has_error=true
elif [ ! -d "$RBE_DIR" ]; then
    echo -e "${RED}  [FAIL] RBE_DIR directory not found at '$RBE_DIR'. Please check the path.${NC}"
    has_error=true
else
    echo -e "${GREEN}  [OK]   RBE_DIR is set to: $RBE_DIR${NC}"
fi

# Check if RBE_SERVICE is set
if [[ "$RBE_SERVICE" == "your-instance.buildbuddy.io:443" || -z "$RBE_SERVICE" ]]; then
    echo -e "${RED}  [FAIL] RBE_SERVICE is not set in '$CONFIG_FILE'. Please provide your BuildBuddy instance URL.${NC}"
    has_error=true
else
    echo -e "${GREEN}  [OK]   RBE Service is set to: $RBE_SERVICE${NC}"
fi

# Check if API Key is set
if [[ "$USE_API_KEY_AUTH" = true && ("$RBE_API_KEY" == "xxx" || -z "$RBE_API_KEY") ]]; then
    echo -e "${RED}  [FAIL] RBE_API_KEY is not set in '$CONFIG_FILE'. Please provide your BuildBuddy API key.${NC}"
    has_error=true
elif [ "$USE_API_KEY_AUTH" = true ]; then
    echo -e "${GREEN}  [OK]   BuildBuddy API key is set.${NC}"
fi

if [ "$has_error" = true ]; then
    echo -e "\n${RED}Configuration has errors. Please fix '$CONFIG_FILE' and source this script again.${NC}"
    return 1
fi

# --- Step 3: Pre-flight Checks ---
echo -e "\n${YELLOW}Step 3: Performing pre-flight checks...${NC}"

# Check if reproxy is running. This is the most common user error.
if ! pgrep -x reproxy > /dev/null; then
    echo -e "${YELLOW}  [WARN] 'reproxy' process is not running. RBE will not work.${NC}"
    echo -e "         You can start it by running this command in a separate terminal:"
    echo -e "         ${CYAN}(cd \"$RBE_DIR\" && ./reproxy -log_dir=. -alsologtostderr &)${NC}"
else
    echo -e "${GREEN}  [OK]   'reproxy' process is running.${NC}"
fi

# --- Step 4: Exporting Environment Variables ---
echo -e "\n${YELLOW}Step 4: Setting up build environment...${NC}"

export USE_RBE=1
export RBE_DIR
export NINJA_REMOTE_NUM_JOBS

# BuildBuddy Connection Settings
export RBE_service="$RBE_SERVICE"
if [ "$USE_API_KEY_AUTH" = true ]; then
    export RBE_remote_headers="x-buildbuddy-api-key=$RBE_API_KEY"
    export RBE_use_rpc_credentials=false
    export RBE_service_no_auth=true
fi

# Unified I/O
if [ "$USE_UNIFIED_IO" = true ]; then
    export RBE_use_unified_downloads=true
    export RBE_use_unified_uploads=true
fi

# Execution Strategies
export RBE_CXX_EXEC_STRATEGY="$CXX_EXEC_STRATEGY"
export RBE_CXX_LINKS_EXEC_STRATEGY="$CXX_LINKS_EXEC_STRATEGY"
export RBE_JAVAC_EXEC_STRATEGY="$JAVA_EXEC_STRATEGY"
export RBE_D8_EXEC_STRATEGY="$JAVA_EXEC_STRATEGY"
export RBE_R8_EXEC_STRATEGY="$JAVA_EXEC_STRATEGY"
export RBE_JAR_EXEC_STRATEGY="$JAVA_EXEC_STRATEGY"
export RBE_ZIP_EXEC_STRATEGY="$JAVA_EXEC_STRATEGY"
export RBE_TURBINE_EXEC_STRATEGY="$JAVA_EXEC_STRATEGY"
export RBE_SIGNAPK_EXEC_STRATEGY="$JAVA_EXEC_STRATEGY"
export RBE_ABI_LINKER_EXEC_STRATEGY="$CXX_EXEC_STRATEGY"
export RBE_CLANG_TIDY_EXEC_STRATEGY="$CXX_EXEC_STRATEGY"
export RBE_METALAVA_EXEC_STRATEGY="$JAVA_EXEC_STRATEGY"
export RBE_LINT_EXEC_STRATEGY="$JAVA_EXEC_STRATEGY"

# Enable RBE for specific tools based on true/false config
[[ "$RBE_CXX" = true ]] && export RBE_CXX=1
[[ "$RBE_CXX_LINKS" = true ]] && export RBE_CXX_LINKS=1
[[ "$RBE_JAVAC" = true ]] && export RBE_JAVAC=1
[[ "$RBE_D8" = true ]] && export RBE_D8=1
[[ "$RBE_R8" = true ]] && export RBE_R8=1
[[ "$RBE_JAR" = true ]] && export RBE_JAR=1
[[ "$RBE_ZIP" = true ]] && export RBE_ZIP=1
[[ "$RBE_TURBINE" = true ]] && export RBE_TURBINE=1
[[ "$RBE_SIGNAPK" = true ]] && export RBE_SIGNAPK=1
[[ "$RBE_ABI_LINKER" = true ]] && export RBE_ABI_LINKER=1
[[ "$RBE_ABI_DUMPER" = true ]] && export RBE_ABI_DUMPER=1 || unset RBE_ABI_DUMPER
[[ "$RBE_CLANG_TIDY" = true ]] && export RBE_CLANG_TIDY=1
[[ "$RBE_METALAVA" = true ]] && export RBE_METALAVA=1
[[ "$RBE_LINT" = true ]] && export RBE_LINT=1

# Resource Pools
export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default

echo -e "${GREEN}  > All RBE environment variables have been exported.${NC}"

# --- Final Confirmation ---
echo -e "\n${GREEN}✅ RBE environment is ready!${NC}"
echo -e "   - Remote jobs: ${CYAN}$NINJA_REMOTE_NUM_JOBS${NC}"
echo -e "   - C++ Link Strategy: ${CYAN}$CXX_LINKS_EXEC_STRATEGY${NC}"
echo -e "   - Invocation URL will appear at: ${CYAN}https://app.buildbuddy.io/invocation/...${NC}"
echo -e "You can now start your build (e.g., ${CYAN}mka bacon${NC})."
